#!/bin/zsh

# tspot - tmux launch spotify tui (spotatui)

DIR="$HOME"

cd $DIR

session_name="spotify"

tmux new-session -d -s "$session_name" -n "spotify"

tmux send-keys -t "$session_name:1" "spotatui" C-m
