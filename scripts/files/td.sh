#!/bin/zsh

# tmux delete (kill) session

alias path="~/scripts/files/path.sh"

base_name="$(path)"

if [[ -n "$1" ]]; then
  session_name="${base_name}-$1"
else
  session_name="${base_name}"
fi

tmux kill-session -t "=$session_name"
