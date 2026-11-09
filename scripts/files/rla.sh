#!/bin/zsh

# rla - rex launch [session] app (rex version of tla)
# unlike rlg, this just launches a single window running a single binary

if [[ -z "$1" ]]; then
  echo "Pass in a binary name. e.g. rla htop"
  exit 1
fi

binary="$1"
session_name="$binary"

# rex allows duplicate labels, tmux refused them
if rex session inspect "$session_name" >/dev/null 2>&1; then
  echo "duplicate session: $session_name" >&2
  exit 1
fi

rex new "$session_name" --window "$binary" -c "$PWD" >/dev/null || exit 1

rex send -s "$session_name" -w 1 "$binary"$'\r'
