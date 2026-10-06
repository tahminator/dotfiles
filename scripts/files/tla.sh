#!/bin/zsh

# tla - tmux launch [session] app
# unlike tl/tlp/tlw, this just launches a single window running a single binary

if [[ -z "$1" ]]; then
  echo "Pass in a binary name. e.g. tla htop"
  exit 1
fi

binary="$1"
session_name="$binary"

tmux new-session -d -s "$session_name" -n "$binary"

tmux send-keys -t "$session_name:1" "$binary" C-m
