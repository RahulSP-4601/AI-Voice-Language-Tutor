#!/usr/bin/env sh

set -eu

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Initialize a Git repository before installing hooks."
  exit 1
}

git config core.hooksPath .githooks
chmod +x .githooks/pre-commit scripts/guardian.sh scripts/install-hooks.sh
echo "Git hooks installed from .githooks."
