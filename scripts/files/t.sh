#!/bin/zsh

# tmux new or attach

source ~/.zshrc

if [[ -n "$1" ]]; then
	if tmux has-session -t "=$1" 2>/dev/null; then
		tmux attach -t "=$1"
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

if tmux has-session -t "=$session_name" 2>/dev/null; then
	tmux attach -t "=$session_name"
else
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

	tmux select-window -t "$session_name:1"
	tmux attach -t "=$session_name"
fi
