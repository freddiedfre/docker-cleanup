#!/usr/bin/env bash
set -euo pipefail

if ! command -v bats &>/dev/null; then
  echo "Installing bats..."
  if [[ "$(uname)" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get install -y bats
  elif [[ "$(uname)" == "Darwin" ]]; then
    brew install bats-core
  fi
fi

echo ">> Running bats tests..."
bats tests/
