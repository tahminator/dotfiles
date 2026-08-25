#!/usr/bin/env bash

set -e

if [ -z "${SUDO_KEEPALIVE_PID:-}" ]; then
  sudo -v
  (set +e; while true; do sudo -n -v 2>/dev/null || sudo -v; sleep 60; kill -0 "$$" 2>/dev/null || exit; done) &
  export SUDO_KEEPALIVE_PID=$!
fi

TEMP_BREWFILE=$(mktemp)
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null; rm -f "$TEMP_BREWFILE"' EXIT

cat ~/.Brewfile.common ~/.Brewfile.personal >"$TEMP_BREWFILE"

echo "checking for packages to cleanup..."
echo ""
brew bundle cleanup --file "$TEMP_BREWFILE" || true

echo ""
while true; do
  read -p "proceed with cleanup? (y/n) " response
  case "$response" in
  [Yy])
    echo ""
    echo "cleaning up packages..."
    brew bundle cleanup --file "$TEMP_BREWFILE" --force

    echo ""
    echo "cleanup complete"
    break
    ;;
  [Nn])
    echo "cleanup cancelled"
    exit 0
    ;;
  esac
done
