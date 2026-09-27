#!/bin/zsh

# can pt anywhere
DIR="$1"

cd $DIR

session_name="$2"

if [[ ! -v 2 ]]; then
  echo "2nd argument must be passed in and it must be the name of the session"
  return 1
fi

tmux new-session -d -s "$session_name" -n "editor"

tmux send-keys -t "$session_name:1" "nvim ." C-m

tmux new-window -t "$session_name:2"
tmux new-window -t "$session_name:3"

tmux new-window -t "$session_name:4" -n "ai"

if [[ "$WORK" == "true" ]]; then
  # pi needs to start first to open socket
  tmux send-keys -t "$session_name:4" "pi" C-m
else
  # pi needs to start first to open socket
  tmux send-keys -t "$session_name:4" "pi" C-m
fi
