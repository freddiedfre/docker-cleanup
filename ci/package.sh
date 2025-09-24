#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Version required}"

echo ">> Packaging for release: $VERSION"
mkdir -p dist
cp -r dist/* "dist/${VERSION}/"
