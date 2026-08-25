#!/usr/bin/env bash

set -e

if [ -z "${SUDO_KEEPALIVE_PID:-}" ]; then
  sudo -v
  (set +e; while true; do sudo -n -v 2>/dev/null || sudo -v; sleep 60; kill -0 "$$" 2>/dev/null || exit; done) &
  export SUDO_KEEPALIVE_PID=$!
fi

TEMP_BREWFILE=$(mktemp)
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null; rm -f "$TEMP_BREWFILE"' EXIT

cat ~/.Brewfile.common ~/.Brewfile.work ~/.Brewfile.worksecret >"$TEMP_BREWFILE"

echo "checking for packages to install..."
echo ""
brew bundle check --file "$TEMP_BREWFILE" --verbose || true

echo ""
while true; do
  read -p "proceed with install? (y/n) " response
  case "$response" in
  [Yy])
    echo ""
    echo "installing packages..."
    brew bundle install --file "$TEMP_BREWFILE" --verbose

    echo ""
    echo "install complete"
    exec "$(dirname "$0")/bws.sh"
    ;;
  [Nn])
    echo "install cancelled"
    exit 0
    ;;
  esac
done
