#!/bin/zsh

# rex-reload - run `source ~/.zshrc` in every terminal of every window of every session
# (rex version of tmux-reload)
# only terminals sitting at a zsh prompt get it; terminals running nvim, omp, or any other
# foreground program are skipped so the keys don't land inside that program.

sessions=("${(@f)$(rex --autostart=false ls -q --short=false 2>/dev/null)}") ||
  { echo "No rex server running" >&2; exit 1; }

blocks=()
for session in "${sessions[@]}"; do
  [[ -n "$session" ]] || continue
  blocks+=("${(@f)$(rex block ls -s "$session" --json |
    jq -r '.blocks[] | select(.creator_name == "com.superlogical.terminal") | .block_id')}")
done

reloaded=0
skipped=0
for block in "${blocks[@]}"; do
  [[ -n "$block" ]] || continue
  cmd=$(rex block call -b "$block" process 2>/dev/null | jq -r '.foreground.name // empty')
  if [[ "$cmd" == zsh ]]; then
    rex send -b "$block" $'source ~/.zshrc\r'
    (( reloaded++ ))
  else
    (( skipped++ ))
  fi
done

echo "Reloaded $reloaded terminal(s), skipped $skipped busy terminal(s)"
