#!/bin/bash

set -euo pipefail

base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD) || {
  echo "Cannot determine origin's default branch. Set it with: git remote set-head origin -a" >&2
  exit 1
}

echo "Soft-resetting to $base; changes will remain staged."
git reset --soft "$base"
