#!/bin/bash

# gcw - git clone work

if [[ -n "$1" ]]; then
	mkdir -p "$HOME"/github/integralads
	cd "$HOME"/github/integralads
	if [[ -n "$2" ]]; then
		git clone git@github.com:integralads/"$1".git "$2"
	else
		git clone git@github.com:integralads/"$1".git
	fi
else
	echo "Pass in a project name. e.g. gcw project123"
fi
