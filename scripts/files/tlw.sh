#!/bin/zsh

alias tl="~/scripts/files/tl.sh"

# tlw - tmux launch [session] work

if [[ -n "$1" ]]; then
  tl work "$1"
else
  echo "Pass in a project name. e.g. tlw project123"
fi
