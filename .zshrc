# uncomment next line (and last line) to check performance timings when ~/.zshrc is sourced
# zmodload zsh/zprof

# oh my zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  fluxcd
  gh
  # git clone https://github.com/romkatv/zsh-defer.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-defer
  # zsh-defer
)

source $ZSH/oh-my-zsh.sh

# Sane defaults for MacOS

# Disable hold on key to show accents
defaults write -g ApplePressAndHoldEnabled -bool false
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
defaults write com.apple.dock expose-group-apps -bool true
# https://www.reddit.com/r/MacOS/comments/1ccfycq/why_is_inserting_an_emoji_so_slow/
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
# https://wezterm.org/faq.html#how-do-i-enable-undercurl-curly-underlines
# export TERM=wezterm  # use Ghostty now, not needed anymore
# resolve cases where gpg passphrase may not show up in certain environments.
export GPG_TTY=$(tty)
# configure shell to append to history, not overwrite.
setopt inc_append_history
setopt share_history
# per-repo history: inside ~/github/<owner>/<repo>/** use that repo's own history,
# everywhere else fall back to the global $HISTFILE (~/.zsh_history).
_repo_hist_root=${${:-$HOME/github}:A}
_repo_hist_dir=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/repo-history
_repo_hist_file=  # empty = global history active
_repo_hist_global_file=$HISTFILE
_repo_hist_switch() {
  local cwd=${PWD:A} target=
  if [[ $cwd/ == $_repo_hist_root/*/*/* ]]; then
    local -a parts=(${(s:/:)${cwd#$_repo_hist_root/}})
    target=$_repo_hist_dir/$parts[1]/$parts[2]
  fi
  [[ $target == $_repo_hist_file ]] && return  # same scope, keep current list
  [[ -n $_repo_hist_file ]] && fc -P           # save repo list, restore global
  if [[ -n $target ]]; then
    mkdir -p ${target:h}
    fc -p $target $HISTSIZE $SAVEHIST          # no -a: must outlive this function
  fi
  _repo_hist_file=$target
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _repo_hist_switch
_repo_hist_switch
# autosuggestions: try the active (repo) history first, then fall back to global.
# Global entries are cached and only re-read at the prompt when ~/.zsh_history changes.
zmodload -F zsh/stat b:zstat
typeset -ga _repo_hist_global
_repo_hist_global_stamp=
_repo_hist_global_refresh() {
  [[ -n $_repo_hist_file ]] || return  # global list is already $history
  local -A st
  zstat -H st -- $_repo_hist_global_file 2>/dev/null || return
  [[ $st[mtime]:$st[size] == $_repo_hist_global_stamp ]] && return
  fc -ap /dev/null $HISTSIZE 0         # scratch list, popped on return, never saved
  fc -R $_repo_hist_global_file
  _repo_hist_global=("${(@v)history}")  # newest first
  _repo_hist_global_stamp=$st[mtime]:$st[size]
}
add-zsh-hook precmd _repo_hist_global_refresh
_zsh_autosuggest_strategy_global_history() {
  emulate -L zsh
  setopt EXTENDED_GLOB
  [[ -n $_repo_hist_file ]] || return
  local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"  # same escaping as the `history` strategy
  local pattern="$prefix*"
  [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]] && pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
  typeset -g suggestion="${_repo_hist_global[(r)$pattern]}"
}
ZSH_AUTOSUGGEST_STRATEGY=(history global_history)
# Stop showing the annoying zsh update msg so frequently
export UPDATE_ZSH_DAYS=5
# so your fingers dont fall off
alias k='kubectl'
complete -o default -F __start_kubectl k
# graphite autocmp
source <(gt completion)
# easier git
alias g='git'
# use nvim as default text editor
export EDITOR="nvim"
# remove annoying brew formulae trusting, all go through Brewfiles anyways
export HOMEBREW_NO_REQUIRE_TAP_TRUST=1

eval "$(/opt/homebrew/bin/brew shellenv)"
fpath+=$(brew --prefix)/share/zsh/site-functions
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$PATH:$HOME/.docker/bin"
eval "$(fnm env --use-on-cd --shell zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=180'
export PATH="/opt/homebrew/opt/tomcat@9/bin:$PATH"
export PATH="/opt/homebrew/opt/trash/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$PATH:/Users/tahminator/Library/Application Support/Coursier/bin"
export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

# pnpm
export PNPM_HOME="/Users/tahminator/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# show current git branch if in a git repo.
function parse_git_branch() {
  git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/%F{blue}[\1]%f/p'
}

# shows the currently set git email to ensure you aren't using the wrong email.
function get_git_user_email() {
  git config user.email 2>/dev/null
}

setopt PROMPT_SUBST
export PROMPT='%F{magenta}$(get_git_user_email)%f %1~ $(parse_git_branch) %F{red}$%f '

source ~/scripts/scripts.zsh

# commit work specific config here
source "$HOME/work/.zshrc"

# commit personal specific config here
source "$HOME/personal/.zshrc"

# commit ~/github specific config here
source "$HOME/github/.zshrc"

# direnv
eval "$(direnv hook zsh)"

# uncomment next line & commit inline secrets if you REALLY need to (would not recommend)
# source ~/.zshrc-local

# for lazyjira
export LAZYJIRA_CONFIG_DIR=~/.config/lazyjira

autoload -Uz compinit

# zprof
