#!/usr/bin/env bash

set -e

echo "Installing common packages..."
brew bundle install --file ~/.Brewfile.common --verbose

echo "Installing work packages..."
brew bundle install --file ~/.Brewfile.work --verbose
