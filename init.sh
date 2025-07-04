read -p "What is your personal Git email? (type s to skip) " PERSONAL_GIT_EMAIL

if [ $PERSONAL_GIT_EMAIL != "s" ]; then
	if [[ ! -f ~/templates/.gitconfig ]]; then
		echo "Error: ~/templates/.gitconfig not found"
		return 1
	fi

	sed "s/\$PERSONAL_GIT_EMAIL/$PERSONAL_GIT_EMAIL/g" ~/templates/.gitconfig >~/.gitconfig

	echo "Personal email: $PERSONAL_GIT_EMAIL"
	echo "~/.gitconfig created successfully!"
fi

read -p "What is your work Git email? (type s to skip) " WORK_GIT_EMAIL

if [ "$WORK_GIT_EMAIL" != "s" ]; then
	if [[ ! -f ~/templates/work/.gitconfig ]]; then
		echo "Error: ~/templates/work/.gitconfig not found"
		return 1
	fi

	sed "s/\$WORK_GIT_EMAIL/$WORK_GIT_EMAIL/g" ~/templates/work/.gitconfig >~/work/.gitconfig
	echo "Work email: $WORK_GIT_EMAIL"
	echo "~/work/.gitconfig created successfully!"
	echo "NOTE: Work email may not show as overriden until inside of a git repo inside of ~/work/*"
fi

if ! which brew &>/dev/null; then
	echo "Error: homebrew not found. Install homebrew from https://brew.sh"
	return 1
fi

echo "Downloading dependencies from .Brewfile"
brew bundle install

touch ~/personal/.zshrc
touch ~/work/.zshrc
