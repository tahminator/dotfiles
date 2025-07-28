SCRIPTS_DIR=$(eval echo "~/scripts/files")

# no extensions, just filenames
SCRIPTS=(
  "gradle-fix"
  "string-printer"
  "recursive-git-pull"
  "bitwarden"
  "latex-compile"
  "spotless"
)

for script in "${SCRIPTS[@]}"; do
    alias "$script"="$SCRIPTS_DIR/$script.sh"
done

for script in "${SCRIPTS[@]}"; do
    chmod +x "$SCRIPTS_DIR/$script.sh"
done

# extra short aliases below here
alias lc=latex-compile
