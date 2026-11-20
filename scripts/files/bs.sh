#!/usr/bin/env bash

set -e

if [[ "$WORK" == "true" ]]; then
  echo "mode: work"
  BREWFILES=(~/.Brewfile.common ~/.Brewfile.work ~/.Brewfile.worksecret)
else
  echo "mode: personal"
  BREWFILES=(~/.Brewfile.common ~/.Brewfile.personal)
fi
echo ""

if [ -z "${SUDO_KEEPALIVE_PID:-}" ]; then
  sudo -v
  (set +e; while true; do sudo -n -v 2>/dev/null || sudo -v; sleep 60; kill -0 "$$" 2>/dev/null || exit; done) &
  export SUDO_KEEPALIVE_PID=$!
fi

TEMP_BREWFILE=$(mktemp)
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null; rm -f "$TEMP_BREWFILE"' EXIT

cat "${BREWFILES[@]}" >"$TEMP_BREWFILE"

echo "checking for packages to cleanup..."
echo ""
brew bundle cleanup --file "$TEMP_BREWFILE"
