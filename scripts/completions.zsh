# zsh completions for scripts in scripts/files. sourced by scripts.zsh after compinit.

# tlg <repo|owner/repo> [branch]
_tlg() {
  local github_dir="$HOME/github"

  # repo dirs, minus worktree checkouts ({repo}.wt.{name})
  local -a repo_dirs=("$github_dir"/*/*(N/))
  repo_dirs=(${repo_dirs:#*.wt.*})

  # the main checkout for the repo already typed, if it resolves to exactly one
  local repo_dir target="${words[2]}"
  if (( CURRENT > 2 )); then
    if [[ "$target" == */* ]]; then
      [[ -d "$github_dir/$target" ]] && repo_dir="$github_dir/$target"
    else
      local -a matches=(${(M)repo_dirs:#*/$target})
      (( ${#matches} == 1 )) && repo_dir="${matches[1]}"
    fi
  fi

  _tlg_repos() {
    local -a names=(${repo_dirs:t}) qualified=(${repo_dirs#$github_dir/})
    # bare names only when unique; owner/repo always
    local -a unique=(${(u)names})
    local name
    for name in $unique; do
      (( ${#${(M)names:#$name}} > 1 )) && unique=(${unique:#$name})
    done
    _describe -t repos 'repo' unique
    _describe -t qualified-repos 'owner/repo' qualified
  }

  # branches already checked out somewhere (main checkout or worktree) first, then the rest
  _tlg_branches() {
    [[ -n "$repo_dir" ]] || return 1
    local -a open=() open_names=() rest=() remote=()
    local line name wt_path
    for line in "${(@f)$(git -C "$repo_dir" for-each-ref --format=$'%(refname:short)\t%(worktreepath)' refs/heads 2>/dev/null)}"; do
      [[ -n "$line" ]] || continue
      name="${line%%$'\t'*}"
      wt_path="${line#*$'\t'}"
      if [[ -n "$wt_path" ]]; then
        open+=("${name//:/\\:}:${wt_path:t}")
        open_names+=("$name")
      else
        rest+=("$name")
      fi
    done
    remote=(${${(f)"$(git -C "$repo_dir" for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null)"}#origin/})
    remote=(${remote:#(origin|HEAD)})
    rest=(${rest} ${remote:|rest})
    rest=(${rest:|open_names})
    _describe -t open-branches 'checked out' open
    _describe -t branches 'branch' rest
  }

  _arguments \
    '(-)-h[show usage]' \
    '1:repo:_tlg_repos' \
    '2:branch:_tlg_branches'
}

compdef _tlg tlg tlg.sh
