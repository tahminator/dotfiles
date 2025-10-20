zmodload zsh/zprof

# Sane defaults for MacOS 

# Disable hold on key to show accents
defaults write -g ApplePressAndHoldEnabled -bool false
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
defaults write com.apple.dock expose-group-apps -bool true
# https://www.reddit.com/r/MacOS/comments/1ccfycq/why_is_inserting_an_emoji_so_slow/
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
# https://wezterm.org/faq.html#how-do-i-enable-undercurl-curly-underlines
export TERM=wezterm


eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(jenv init -)"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=180'
export PATH="/opt/homebrew/opt/tomcat@9/bin:$PATH"
export PATH="/opt/homebrew/opt/trash/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$PATH:/Users/tahminator/Library/Application Support/Coursier/bin"

# pnpm
export PNPM_HOME="/Users/tahminator/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# show current git branch if in a git repo.
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/%F{blue}[\1]%f/p'
}

# shows the currently set git email to ensure you aren't using the wrong email.
function get_git_user_email() {
    git config user.email 2> /dev/null
}

setopt PROMPT_SUBST
export PROMPT='%F{magenta}$(get_git_user_email)%f %1~ $(parse_git_branch) %F{red}$%f '

source ~/scripts/scripts.zsh

# commit work specific config here
source "$HOME/work/.zshrc"

# commit personal specific config here
source "$HOME/personal/.zshrc"

# uncomment next line & commit inline secrets if you REALLY need to (would not recommend)
# source ~/.zshrc-local

zprof
