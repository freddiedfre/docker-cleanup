#!/usr/bin/env bash
set -euo pipefail

SCRIPT="scripts/docker-cleanup.sh"

if ! command -v shellcheck &>/dev/null; then
  echo "Installing shellcheck..."
  if [[ "$(uname)" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get install -y shellcheck
  elif [[ "$(uname)" == "Darwin" ]]; then
    brew install shellcheck
  fi
fi

echo ">> Running shellcheck..."
shellcheck "$SCRIPT"
