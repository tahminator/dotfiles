#!/bin/bash

# gcw - git clone work

if [[ -n "$1" ]]; then
	cd "$HOME"/work/github
	if [[ -n "$2" ]]; then
		git clone git@github.com:integralads/"$1".git "$2"
	else
		git clone git@github.com:integralads/"$1".git
	fi
else
	echo "Pass in a project name. e.g. tlp project123"
fi
