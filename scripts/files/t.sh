#!/bin/zsh

# tmux new or attach

source ~/.zshrc

base_name="$(path)"

if [[ -n "$1" ]]; then
  session_name="${base_name}-$1"
else
  session_name="${base_name}"
fi

if tmux has-session -t "=$session_name" 2>/dev/null; then
  tmux attach -t "=$session_name"
else
  tmux new -s "$session_name"
fi
