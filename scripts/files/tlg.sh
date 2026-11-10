#!/bin/zsh

# tlg - tmux launch [session] git repo in ~/github/{owner}/{repo}
#
# usage: tlg <repo|owner/repo> [branch]
#
#   tlg repo         open the main checkout as-is (owner/repo clones it if missing)
#   tlg repo branch  open the checkout that has branch checked out (the main
#                    checkout or any worktree); if none does, create worktree
#                    ~/github/{owner}/{repo}.wt.{branch, / replaced by -} first
#
# a new worktree's branch is resolved as:
#   - the local branch if it exists
#   - else a new branch tracking origin/{branch} if it exists
#   - else a new branch off the freshly fetched origin default branch
# and it gets every path listed in the main checkout's .copy file
# (one path or zsh glob per line, relative to the repo root, # comments allowed).

setopt extended_glob

GITHUB_DIR="$HOME/github"

die() {
  echo "$1" >&2
  exit 1
}

usage="usage: tlg <repo|owner/repo> [branch]"

[[ "$1" == (-h|--help) ]] && { echo "$usage"; exit 0; }
[[ -n "$1" && $# -le 2 && "$1" != -* && "$2" != -* ]] || die "$usage"

target="$1"
branch="$2"

# resolve the main checkout
if [[ "$target" == */* ]]; then
  repo_dir="$GITHUB_DIR/$target"
  if [[ ! -d "$repo_dir" ]]; then
    echo "Cloning $target..."
    mkdir -p "${repo_dir:h}" || die "Could not create ${repo_dir:h}"
    gh repo clone "$target" "$repo_dir" || die "Clone of $target failed"
  fi
else
  matches=("$GITHUB_DIR"/*/"$target"(N/))

  (( ${#matches} == 0 )) && die "No repo named $target in $GITHUB_DIR"
  if (( ${#matches} > 1 )); then
    echo "Multiple repos named $target, pass owner/repo instead:" >&2
    for dir in "${matches[@]}"; do echo "  ${dir:h:t}/$target" >&2; done
    exit 1
  fi
  repo_dir="${matches[1]}"
fi

g() { git -C "$repo_dir" "$@"; }

dir="$repo_dir"

if [[ -n "$branch" ]]; then
  g rev-parse --git-dir >/dev/null 2>&1 || die "$repo_dir is not a git repo"

  # reuse whichever checkout already has the branch
  dir=""
  wt_path=""
  for line in "${(@f)$(g worktree list --porcelain)}"; do
    case "$line" in
    "worktree "*) wt_path="${line#worktree }" ;;
    "branch refs/heads/$branch") dir="$wt_path"; break ;;
    esac
  done

  if [[ -z "$dir" ]]; then
    dir="$repo_dir.wt.${branch//\//-}"
    [[ -e "$dir" ]] && die "$dir exists but does not have $branch checked out"

    has_origin=false
    if g remote get-url origin >/dev/null 2>&1; then
      has_origin=true
      echo "Fetching origin..."
      g fetch origin --quiet || die "git fetch failed"
    fi

    if g show-ref --verify --quiet "refs/heads/$branch"; then
      g worktree add "$dir" "$branch" || exit 1
    elif $has_origin && g show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      g worktree add --track -b "$branch" "$dir" "origin/$branch" || exit 1
    else
      base="HEAD"
      if $has_origin; then
        g remote set-head origin --auto >/dev/null 2>&1
        base=$(g symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) ||
          die "Could not determine origin default branch"
      fi
      g worktree add --no-track -b "$branch" "$dir" "$base" || exit 1
    fi

    if [[ -f "$repo_dir/.copy" ]]; then
      cd "$repo_dir"
      while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%\#*}"
        line="${${line##[[:space:]]#}%%[[:space:]]#}"
        line="${line%%/#}"
        [[ -z "$line" ]] && continue

        srcs=(${~line}(N))
        if (( ${#srcs} == 0 )); then
          echo ".copy: no match for $line"
          continue
        fi

        for src in "${srcs[@]}"; do
          mkdir -p "$dir/${src:h}"
          # -c clones on APFS (instant, no extra disk); fall back to a plain copy
          if /bin/cp -Rc "$src" "$dir/${src:h}/" 2>/dev/null || /bin/cp -R "$src" "$dir/${src:h}/"; then
            echo ".copy: $src"
          else
            echo ".copy: failed to copy $src"
          fi
        done
      done <"$repo_dir/.copy"
    fi
  fi
fi

# session is owner/repo (dirs live in ~/github/{owner}/); tmux treats . and : as target separators
session_name="${dir:h:t}/${dir:t}"
session_name="${session_name//[.:]/_}"

if tmux has-session -t "=$session_name" 2>/dev/null; then
  echo "Session $session_name already exists"
  exit 0
fi

tmux new-session -d -s "$session_name" -n "editor" -c "$dir"

tmux send-keys -t "$session_name:1" "nvim ." C-m

tmux new-window -t "$session_name:2" -c "$dir"
tmux new-window -t "$session_name:3" -c "$dir"

tmux new-window -t "$session_name:4" -n "ai" -c "$dir"

if [[ "$WORK" == "true" ]]; then
  # omp needs to start first to open socket
  tmux send-keys -t "$session_name:4" "omp" C-m
else
  # omp needs to start first to open socket
  tmux send-keys -t "$session_name:4" "omp" C-m
fi
