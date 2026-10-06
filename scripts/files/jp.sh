#!/bin/zsh

# jp - jira parse (extract the issue key from a Jira URL)
# e.g. jp https://jira-integralads.atlassian.net/browse/PRPL-3747 -> PRPL-3747

if [[ -z "$1" ]]; then
  echo "Pass in a Jira URL. e.g. jp https://jira-integralads.atlassian.net/browse/PRPL-3747"
  exit 1
fi

echo "$1" | grep -oE '[A-Z][A-Z0-9]*-[0-9]+' | head -1
