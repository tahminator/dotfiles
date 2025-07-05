eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(jenv init -)"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=180'
export PATH="/opt/homebrew/opt/tomcat@9/bin:$PATH"
export PATH="/opt/homebrew/opt/trash/bin:$PATH"

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
source ~/work/.zshrc

# commit personal specific config here
source ~/personal/.zshrc

# uncomment next line & commit inline secrets if you REALLY need to (would not recommend)
# source ~/.zshrc-local
