#!/bin/bash

# return the last path.
# i just use this mainly for naming tmux sessions.

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	git_root=$(git rev-parse --show-toplevel 2>/dev/null)
	repo_name=$(basename "$git_root")
	remote_url=$(git remote get-url origin 2>/dev/null || echo "")

	if [[ "$remote_url" == *"dotfiles"* ]]; then
		echo "~" # override
	else
		echo "$repo_name"
	fi
else
	echo "${PWD##*/}"
fi
