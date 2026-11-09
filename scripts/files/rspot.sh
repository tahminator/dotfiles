#!/bin/zsh

# rspot - rex launch spotify tui (spotatui) (rex version of tspot)

DIR="$HOME"

cd $DIR

session_name="spotify"

# rex allows duplicate labels, tmux refused them
if rex session inspect "$session_name" >/dev/null 2>&1; then
  echo "duplicate session: $session_name" >&2
  exit 1
fi

rex new "$session_name" --window "spotify" -c "$DIR" >/dev/null || exit 1

rex send -s "$session_name" -w 1 $'spotatui\r'
