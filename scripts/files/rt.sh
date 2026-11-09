#!/bin/zsh

# rex new or attach (rex version of t)

alias path="~/scripts/files/path.sh"

# show the session in the Rex app, like tmux attach
attach() {
  local session_id
  session_id=$(rex session inspect "$1" --json | jq -r .session_id) || exit 1
  if ! rex do session.select session_id="$session_id" >/dev/null 2>&1; then
    echo "Session $1 is ready; pick it with cmd+k." >&2
    echo "To switch to it automatically, turn on Remote Control in Rex Settings > Rex Server." >&2
  fi
}

if [[ -n "$1" ]]; then
  if rex session inspect "$1" >/dev/null 2>&1; then
    attach "$1"
    exit 0
  else
    echo "Invalid project"
    exit 1
  fi
else
  base_name="$(path)"
fi

if [[ -n "$1" ]]; then
  session_name="${base_name}-$1"
else
  session_name="${base_name}"
fi

if rex session inspect "$session_name" >/dev/null 2>&1; then
  attach "$session_name"
else
  rex new "$session_name" --window "editor" -c "$PWD" >/dev/null || exit 1

  rex send -s "$session_name" -w 1 $'nvim .\r'

  # --focus=false keeps window 1 active, like tmux select-window -t 1
  rex window new -s "$session_name" -c "$PWD" --focus=false >/dev/null
  rex window new -s "$session_name" -c "$PWD" --focus=false >/dev/null

  rex window new -s "$session_name" "ai" -c "$PWD" --focus=false >/dev/null

  if [[ "$WORK" == "true" ]]; then
    # omp needs to start first to open socket
    rex send -s "$session_name" -w 4 $'omp\r'
  else
    # omp needs to start first to open socket
    rex send -s "$session_name" -w 4 $'omp\r'
  fi

  attach "$session_name"
fi
