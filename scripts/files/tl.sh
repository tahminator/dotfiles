#!/bin/zsh

DIR="$HOME/$1/github/$2"

cd $DIR

session_name="$2"

tmux new-session -d -s "$session_name" -n "editor"

tmux send-keys -t "$session_name:1" "nvim ." C-m

tmux new-window -t "$session_name:2"
tmux new-window -t "$session_name:3"

tmux new-window -t "$session_name:4" -n "ai"
# if [[ "$WORK" == "true" ]]; then
#   tmux send-keys -t "$session_name:4" "claude" C-m
# else
#   tmux send-keys -t "$session_name:4" "copilot" C-m
# fi

# opencode experiment
if [[ "$WORK" == "true" ]]; then
	tmux send-keys -t "$session_name:4" "bash ~/work/github/dev-scripts/opencode/run-opencode-aws.sh" C-m
else
	tmux send-keys -t "$session_name:4" "opencode --port" C-m
fi
