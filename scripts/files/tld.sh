#!/bin/zsh

# tld - tmux launch [session] delete: tear down the git worktree containing the cwd
#
# usage: tld   (run from anywhere inside a worktree, e.g. one made by tlg)
#
#   - refuses if the worktree has uncommitted or untracked changes (gitignored files don't count)
#   - git worktree remove (deletes the dir)
#   - kills its tlg tmux session; if that is the session you're in, asks first
# the branch is kept, so committed work is never lost.

die() {
  echo "$1" >&2
  exit 1
}

usage="usage: tld"

[[ "$1" == (-h|--help) ]] && { echo "$usage"; exit 0; }
[[ $# -eq 0 ]] || die "$usage"

dir=$(git rev-parse --show-toplevel 2>/dev/null) || die "$PWD is not in a git repo"

# a linked worktree has its own git dir; the main checkout's is the common one
git_dir=$(git rev-parse --path-format=absolute --git-dir)
common_dir=$(git rev-parse --path-format=absolute --git-common-dir)
[[ "$git_dir" != "$common_dir" ]] || die "$dir is the main checkout, not a worktree"

# the main checkout is always listed first
repo_dir=""
for line in "${(@f)$(git worktree list --porcelain)}"; do
  case "$line" in
  "worktree "*) repo_dir="${line#worktree }"; break ;;
  esac
done
[[ -d "$repo_dir" ]] || die "Could not find the main checkout of $dir"

[[ -z "$(git -C "$dir" status --porcelain 2>&1)" ]] ||
  die "$dir has uncommitted or untracked changes, not removing"

# same naming as tlg
session_name="${dir:h:t}/${dir:t}"
session_name="${session_name//[.:]/_}"

has_session=false
tmux has-session -t "=$session_name" 2>/dev/null && has_session=true

if $has_session && [[ -n "$TMUX" && "$(tmux display-message -p '#S')" == "$session_name" ]]; then
  echo "warning: you are in tmux session $session_name, removing it will kick you out"
  read -r "response?continue? (y/n) "
  [[ "$response" == [Yy] ]] || { echo "tld cancelled"; exit 0; }
fi

branch=$(git -C "$dir" branch --show-current 2>/dev/null)

# get out of the dir before deleting it
cd "$repo_dir" || die "Could not cd to $repo_dir"
git worktree remove "$dir" || die "git worktree remove failed, $dir left in place"
echo "removed $dir${branch:+ (branch $branch kept)}"

# last: when run from inside the session, this kills this script too
if $has_session; then
  echo "killing tmux session $session_name"
  tmux kill-session -t "=$session_name"
fi
