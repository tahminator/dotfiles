SCRIPTS_DIR=$(eval echo "~/scripts/files")

# the rex CLI, for the r* scripts; the Rex app doesn't put it on PATH
(( $+commands[rex] )) ||
  path+=("$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS")

# no extensions, just filenames
SCRIPTS=(
  "gradle-fix"
  "string-printer"
  "recursive-git-pull"
  "latex-compile"
  "spotless"
  "path"
  "t"
  "td"
  "tk"
  "tlg"
  "tlprune"
  "tspot"
  "ts"
  "launcher"
  "gcw"
  "desc"
  "gradlek"
  "bp"
  "bw"
  "bps"
  "bws"
  "tla"
  "memk"
  "jp"
  "tmux-reload"
  "tmux-agents"
  "omp-restart"
  "rt"
  "rd"
  "rk"
  "rlg"
  "rlprune"
  "rspot"
  "rs"
  "rla"
  "rex-reload"
)

for script in "${SCRIPTS[@]}"; do
  alias "$script"="$SCRIPTS_DIR/$script.sh"
done

for script in "${SCRIPTS[@]}"; do
  chmod +x "$SCRIPTS_DIR/$script.sh"
done

source "${0:A:h}/completions.zsh"

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
