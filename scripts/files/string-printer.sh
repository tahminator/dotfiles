#!/bin/bash

# replace \n inside of strings with actual newlines.
if [ -z "$1" ]; then
	echo "Usage: $0 \"your string with \\n or \\t\""
	exit 1
fi

echo -e "$1"
