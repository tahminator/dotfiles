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
  tmux new-session -d -s "$session_name" -n "editor" "nvim ."
  tmux new-window -t "$session_name:2"
  tmux new-window -t "$session_name:3"
  if [[ "$WORK" == "true" ]]; then
    tmux new-window -t "$session_name:4" -n "ai" "claude"
  else
    tmux new-window -t "$session_name:4" -n "ai" "copilot"
  fi
  tmux select-window -t "$session_name:1"
  tmux attach -t "$session_name"
fi
