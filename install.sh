#!/bin/sh
# Layers CLI installer
# Usage: curl -fsSL https://raw.githubusercontent.com/layers/cli/main/install.sh | sh

set -e

REPO="layers/cli"
BINARY="layers"
INSTALL_DIR="/usr/local/bin"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
  darwin|linux) ;;
  *) echo "Unsupported OS: $OS. Use Scoop on Windows: scoop install layers"; exit 1 ;;
esac

# Get latest release tag
echo "Fetching latest release..."
LATEST=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST" ]; then
  echo "Failed to fetch latest release"
  exit 1
fi

VERSION=$(echo "$LATEST" | sed 's/^cli\///' | sed 's/^v//')
echo "Latest version: ${VERSION}"

# Build download URL
ARCHIVE="${BINARY}_${VERSION}_${OS}_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST}/${ARCHIVE}"
CHECKSUMS_URL="https://github.com/${REPO}/releases/download/${LATEST}/checksums.txt"

# Download binary and checksums
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading ${ARCHIVE}..."
curl -fsSL -o "${TMPDIR}/${ARCHIVE}" "$DOWNLOAD_URL"
curl -fsSL -o "${TMPDIR}/checksums.txt" "$CHECKSUMS_URL"

# Verify checksum
echo "Verifying checksum..."
EXPECTED=$(grep "${ARCHIVE}" "${TMPDIR}/checksums.txt" | awk '{print $1}')
if [ -z "$EXPECTED" ]; then
  echo "Checksum not found for ${ARCHIVE}"
  exit 1
fi

if command -v sha256sum > /dev/null 2>&1; then
  ACTUAL=$(sha256sum "${TMPDIR}/${ARCHIVE}" | awk '{print $1}')
elif command -v shasum > /dev/null 2>&1; then
  ACTUAL=$(shasum -a 256 "${TMPDIR}/${ARCHIVE}" | awk '{print $1}')
else
  echo "Warning: sha256sum not found, skipping checksum verification"
  ACTUAL="$EXPECTED"
fi

if [ "$EXPECTED" != "$ACTUAL" ]; then
  echo "Checksum mismatch!"
  echo "  Expected: $EXPECTED"
  echo "  Got:      $ACTUAL"
  exit 1
fi

# Extract and install
echo "Installing to ${INSTALL_DIR}..."
tar -xzf "${TMPDIR}/${ARCHIVE}" -C "$TMPDIR"

# Find the binary (GoReleaser may wrap in subdirectory)
BINARY_PATH=$(find "$TMPDIR" -name "$BINARY" -type f | head -1)
if [ -z "$BINARY_PATH" ]; then
  echo "Binary not found in archive"
  exit 1
fi

chmod +x "$BINARY_PATH"

if [ -w "$INSTALL_DIR" ]; then
  mv "$BINARY_PATH" "${INSTALL_DIR}/${BINARY}"
else
  echo "Need sudo to install to ${INSTALL_DIR}"
  sudo mv "$BINARY_PATH" "${INSTALL_DIR}/${BINARY}"
fi

echo ""
echo "Layers CLI ${VERSION} installed successfully!"
echo ""
"${INSTALL_DIR}/${BINARY}" version
echo ""
echo "Get started:"
echo "  layers login"
echo "  cd your-app && layers setup"
