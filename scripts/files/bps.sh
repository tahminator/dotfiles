#!/usr/bin/env bash

set -e

TEMP_BREWFILE=$(mktemp)
trap 'rm -f "$TEMP_BREWFILE"' EXIT

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
