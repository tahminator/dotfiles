#!/bin/zsh

# rex delete (kill) session (rex version of td)

alias path="~/scripts/files/path.sh"

base_name="$(path)"

if [[ -n "$1" ]]; then
  session_name="${base_name}-$1"
else
  session_name="${base_name}"
fi

rex --autostart=false kill "$session_name"
