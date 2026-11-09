#!/bin/zsh

# rlprune - remove rlg worktrees (~/github/{owner}/{repo}.wt.*) (rex version of tlprune)
#
# usage: rlprune [worktree]
#
#   rlprune                 every worktree
#   rlprune repo.wt.name    just that one (owner/repo.wt.name if the bare name is ambiguous)
#
# lists them, asks for confirmation, then for each one:
#   - skips it if it has uncommitted or untracked changes (gitignored files don't count)
#   - kills its rlg rex session
#   - git worktree remove
# branches are kept, so committed work is never lost.

GITHUB_DIR="$HOME/github"

die() {
  echo "$1" >&2
  exit 1
}

usage="usage: rlprune [worktree]"

[[ "$1" == (-h|--help) ]] && { echo "$usage"; exit 0; }
[[ $# -le 1 && "$1" != -* ]] || die "$usage"

if [[ -n "$1" ]]; then
  [[ "$1" == *.wt.* ]] || die "Not a worktree name: $1 (expected repo.wt.name)"
  if [[ "$1" == */* ]]; then
    worktrees=("$GITHUB_DIR/$1"(N/))
  else
    worktrees=("$GITHUB_DIR"/*/"$1"(N/))
  fi

  (( ${#worktrees} == 0 )) && die "No worktree named $1 in $GITHUB_DIR"
  if (( ${#worktrees} > 1 )); then
    echo "Multiple worktrees named $1, pass owner/$1 instead:" >&2
    for dir in "${worktrees[@]}"; do echo "  ${dir#$GITHUB_DIR/}" >&2; done
    exit 1
  fi
else
  worktrees=("$GITHUB_DIR"/*/*.wt.*(N/))
fi

if (( ${#worktrees} == 0 )); then
  echo "No worktrees to prune"
  exit 0
fi

for dir in "${worktrees[@]}"; do
  session_name="${dir:t}"
  open=""
  rex --autostart=false session inspect "$session_name" >/dev/null 2>&1 && open=" (rex session $session_name open, killed on removal)"
  echo "  ${dir#$GITHUB_DIR/} [$(git -C "$dir" branch --show-current 2>/dev/null)]$open"
done

echo ""
read -r "response?remove ${#worktrees} worktree(s)? (y/n) "
[[ "$response" == [Yy] ]] || { echo "prune cancelled"; exit 0; }
echo ""

skipped=()
for dir in "${worktrees[@]}"; do
  name="${dir#$GITHUB_DIR/}"

  if [[ -n "$(git -C "$dir" status --porcelain 2>&1)" ]]; then
    skipped+=("$name")
    continue
  fi

  session_name="${dir:t}"
  rex --autostart=false kill "$session_name" 2>/dev/null

  if git -C "$dir" worktree remove "$dir"; then
    echo "removed $name"
  else
    skipped+=("$name")
  fi
done

if (( ${#skipped} )); then
  echo ""
  echo "skipped (uncommitted changes or git refused):"
  for name in "${skipped[@]}"; do echo "  $name"; done
fi
