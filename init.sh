backup_if_exists() {
	local target="$1"
	if [[ -e "$target" ]]; then
		local backup="${target}.bak"
		local counter=1

		# Find a unique backup name if .bak already exists
		while [[ -e "$backup" ]]; do
			backup="${target}.bak.${counter}"
			((counter++))
		done

		echo "Backing up existing $target to $backup"
		mv "$target" "$backup"
	fi
}

if ! which brew &>/dev/null; then
	echo "Error: homebrew not found. Install homebrew from https://brew.sh"
	return 1
fi

cd ~
if [[ -d ~/dotfiles ]]; then
    echo "Removing existing ~/dotfiles directory..."
    rm -rf ~/dotfiles
fi

git clone https://github.com/tahminator/dotfiles.git ~/dotfiles

backup_failed=0
conflicts_found=0

for item in ~/dotfiles/.[^.]* ~/dotfiles/*; do
	[[ -e "$item" ]] || continue

	basename_item=$(basename "$item")
	target="$HOME/$basename_item"

	if [[ -e "$target" ]]; then
		conflicts_found=$((conflicts_found + 1))
		echo "Conflict found: $basename_item"

		if ! backup_if_exists "$target"; then
			backup_failed=$((backup_failed + 1))
		fi
	fi
done

if [[ $backup_failed -gt 0 ]]; then
	echo "Error: $backup_failed backup operations failed. Aborting copy operation."
	exit 1
fi

if [[ $conflicts_found -gt 0 ]]; then
	echo "Successfully backed up $conflicts_found conflicting files/directories."
else
	echo "No conflicts found."
fi

copy_failed=0

for item in ~/dotfiles/.[^.]* ~/dotfiles/*; do
	[[ -e "$item" ]] || continue # Skip if glob doesn't match anything

	basename_item=$(basename "$item")
	target="$HOME/$basename_item"

	if cp -r "$item" "$target"; then
		echo "Copied $basename_item"
	else
		echo "Failed to copy $basename_item"
		copy_failed=$((copy_failed + 1))
	fi
done

# Final status
if [[ $copy_failed -eq 0 ]]; then
	echo "Successfully copied over all files that were expected to be copied!"
else
	echo "Failed to copy $copy_failed files from ~/dotfiles to ~"
	exit 1
fi

echo "Downloading dependencies from .Brewfile"
brew bundle install

touch ~/personal/.zshrc
touch ~/work/.zshrc

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
