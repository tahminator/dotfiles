SCRIPTS_DIR=$(eval echo "~/scripts/files")

# no extensions, just filenames
SCRIPTS=(
	"gradle-fix"
	"string-printer"
	"recursive-git-pull"
	"bitwarden"
	"latex-compile"
	"spotless"
	"path"
	"t"
	"td"
	"tk"
	"tl"
	"tlp"
	"tlw"
	"ts"
	"launcher"
	"gcw"
	"desc"
	"gradlek"
)

for script in "${SCRIPTS[@]}"; do
	alias "$script"="$SCRIPTS_DIR/$script.sh"
done

for script in "${SCRIPTS[@]}"; do
	chmod +x "$SCRIPTS_DIR/$script.sh"
done

# extra short aliases below here
alias lc=latex-compile

# move special binaries to bin
BINARIES=(
	# https://github.com/nkleemann/ascii-rain
	"rain"
)

for binary in "${BINARIES[@]}"; do
	if ! command -v "$binary" &>/dev/null; then
		sudo cp "$SCRIPTS_DIR/$binary" "/usr/local/bin/$binary"
	fi
done
