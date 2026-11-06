#!/bin/zsh

# tlprune - remove every tlg worktree (~/github/{owner}/{repo}.wt.*)
#
# lists them, asks for confirmation, then for each one:
#   - skips it if it has uncommitted or untracked changes (gitignored files don't count)
#   - kills its tlg tmux session
#   - git worktree remove
# branches are kept, so committed work is never lost.

GITHUB_DIR="$HOME/github"

worktrees=("$GITHUB_DIR"/*/*.wt.*(N/))

if (( ${#worktrees} == 0 )); then
  echo "No worktrees to prune"
  exit 0
fi

for dir in "${worktrees[@]}"; do
  session_name="${${dir:t}//[.:]/_}"
  open=""
  tmux has-session -t "=$session_name" 2>/dev/null && open=" (tmux session $session_name open, killed on removal)"
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

  session_name="${${dir:t}//[.:]/_}"
  tmux kill-session -t "=$session_name" 2>/dev/null

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
