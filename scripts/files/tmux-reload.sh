#!/bin/zsh

# tmux-reload - run `source ~/.zshrc` in every pane of every window of every session
# only panes sitting at a zsh prompt get it; panes running nvim, omp, or any other
# foreground program are skipped so the keys don't land inside that program.

panes=("${(@f)$(tmux list-panes -a -F '#{pane_id} #{pane_current_command} #{pane_in_mode}' 2>/dev/null)}") ||
  { echo "No tmux server running" >&2; exit 1; }

reloaded=0
skipped=0
for line in "${panes[@]}"; do
  read -r pane_id cmd in_mode <<<"$line"
  # login shells report as -zsh; copy/view mode would swallow the keys
  if [[ "${cmd#-}" == zsh && "$in_mode" == 0 ]]; then
    tmux send-keys -t "$pane_id" "source ~/.zshrc" C-m
    (( reloaded++ ))
  else
    (( skipped++ ))
  fi
done

echo "Reloaded $reloaded pane(s), skipped $skipped busy pane(s)"
