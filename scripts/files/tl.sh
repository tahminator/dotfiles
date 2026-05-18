#!/bin/zsh

DIR="$HOME/$1/github/$2"

cd $DIR

session_name="$2"

tmux new-session -d -s "$session_name" -n "editor"

tmux send-keys -t "$session_name:1" "nvim ." C-m

tmux new-window -t "$session_name:2"
tmux new-window -t "$session_name:3"

tmux new-window -t "$session_name:4" -n "ai"

# wait for nvim to launch
sleep 2.5
tmux send-keys -t "$session_name:4" "claude --ide" C-m

# if [[ "$WORK" == "true" ]]; then
#   # wait for nvim to launch
#   sleep 2500
#   tmux send-keys -t "$session_name:4" "claude --ide" C-m
# else
#   tmux send-keys -t "$session_name:4" "opencode --port" C-m
fi
