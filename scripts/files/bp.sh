#!/usr/bin/env bash

set -e

echo "Installing common packages..."
brew bundle install --file ~/.Brewfile.common --verbose

echo "Installing personal packages..."
brew bundle install --file ~/.Brewfile.personal --verbose
