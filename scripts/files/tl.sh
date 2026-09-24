#!/bin/zsh

DIR="$HOME/$1/github/$2"

cd $DIR

session_name="$2"

tmux new-session -d -s "$session_name" -n "editor"

tmux send-keys -t "$session_name:1" "nvim ." C-m

tmux new-window -t "$session_name:2"
tmux new-window -t "$session_name:3"

tmux new-window -t "$session_name:4" -n "ai"

if [[ "$WORK" == "true" ]]; then
  # omp needs to start first to open socket
  tmux send-keys -t "$session_name:4" "omp" C-m
else
  # omp needs to start first to open socket
  tmux send-keys -t "$session_name:4" "omp" C-m
fi
