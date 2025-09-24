#!/usr/bin/env bash
set -euo pipefail

VERSION="${GITHUB_REF_NAME:-dev}"
OUTPUT_DIR="build/${VERSION}"
BIN_NAME="docker-cleanup"

mkdir -p "$OUTPUT_DIR"

echo ">> Preparing bin/${BIN_NAME}"
cp scripts/docker-cleanup.sh "bin/${BIN_NAME}"
chmod +x "bin/${BIN_NAME}"

echo ">> Creating tarballs..."
mkdir -p dist
tar -czf "dist/${BIN_NAME}-${VERSION}-linux-amd64.tar.gz" -C bin "$BIN_NAME"
tar -czf "dist/${BIN_NAME}-${VERSION}-darwin-amd64.tar.gz" -C bin "$BIN_NAME"
tar -czf "dist/${BIN_NAME}-${VERSION}-windows-amd64.tar.gz" -C bin "$BIN_NAME"

echo ">> Build complete. Artifacts in dist/"
ls -lh dist/
