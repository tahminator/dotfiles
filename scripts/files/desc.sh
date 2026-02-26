if git show-ref --verify --quiet refs/heads/main; then
	DEFAULT_BRANCH="main"
elif git show-ref --verify --quiet refs/heads/master; then
	DEFAULT_BRANCH="master"
else
	DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

	if [ -z "$DEFAULT_BRANCH" ]; then
		echo "Error: Could not determine default branch (main or master)" >&2
		exit 1
	fi
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Comparing $CURRENT_BRANCH with $DEFAULT_BRANCH..."
echo ""

git log $DEFAULT_BRANCH..$CURRENT_BRANCH --pretty=format:"COMMIT_START%n%s%nBODY_START%n%b%nCOMMIT_END" --reverse |
	while IFS= read -r line; do
		if [ "$line" = "COMMIT_START" ]; then
			read -r subject
			read -r body_marker

			body=""
			while IFS= read -r body_line; do
				if [ "$body_line" = "COMMIT_END" ]; then
					break
				fi
				if [ -n "$body_line" ]; then
					if [ -z "$body" ]; then
						body="$body_line"
					else
						body="$body"$'\n'"$body_line"
					fi
				fi
			done

			echo "- $subject"
			if [ -n "$body" ]; then
				echo "$body" | sed 's/^/  - /'
			fi
		fi
	done
