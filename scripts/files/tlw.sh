#!/bin/zsh

source ~/scripts/scripts.zsh

# tlw - tmux launch [session] work

if [[ -n "$1" ]]; then
	tl work "$1"
else
	echo "Pass in a project name. e.g. tlw project123"
fi
