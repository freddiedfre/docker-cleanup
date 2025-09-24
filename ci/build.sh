#!/usr/bin/env bash
set -euo pipefail

VERSION="${GITHUB_REF_NAME:-dev}"
OUTPUT_DIR="build/${VERSION}"
BIN_NAME="docker-cleanup"

mkdir -p "$OUTPUT_DIR"
mkdir -p dist

echo ">> Preparing bin/${BIN_NAME}"
cp scripts/docker-cleanup.sh "bin/${BIN_NAME}"
chmod +x "bin/${BIN_NAME}"

# Create tarballs for Linux/macOS/Windows
for OS_NAME in linux darwin windows; do
  TAR_NAME="dist/${BIN_NAME}-${VERSION}-${OS_NAME}-amd64.tar.gz"
  echo ">> Creating tarball: $TAR_NAME"
  tar -czf "$TAR_NAME" -C bin "$BIN_NAME"
done

echo ">> Build complete. Artifacts in dist/"
ls -lh dist/
