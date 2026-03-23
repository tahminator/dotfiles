#!/bin/zsh

source ~/scripts/scripts.zsh

# tlp - tmux launch [session] personal

if [[ -n "$1" ]]; then
	tl personal "$1"
else
	echo "Pass in a project name. e.g. tlp project123"
fi
