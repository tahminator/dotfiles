#!/usr/bin/env bash

set -e

TEMP_BREWFILE=$(mktemp)
trap 'rm -f "$TEMP_BREWFILE"' EXIT

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
