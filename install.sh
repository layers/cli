#!/bin/sh
# Layers CLI installer
# Usage: curl -fsSL https://layers.com/install.sh | sh

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
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "Downloading ${ARCHIVE}..."
curl -fsSL -o "${WORK_DIR}/${ARCHIVE}" "$DOWNLOAD_URL"
curl -fsSL -o "${WORK_DIR}/checksums.txt" "$CHECKSUMS_URL"

# Verify checksum (mandatory — refuse to install without verification)
echo "Verifying checksum..."
EXPECTED=$(grep -F "${ARCHIVE}" "${WORK_DIR}/checksums.txt" | awk '{print $1}')
if [ -z "$EXPECTED" ]; then
  echo "Checksum not found for ${ARCHIVE}"
  exit 1
fi

if command -v sha256sum > /dev/null 2>&1; then
  ACTUAL=$(sha256sum "${WORK_DIR}/${ARCHIVE}" | awk '{print $1}')
elif command -v shasum > /dev/null 2>&1; then
  ACTUAL=$(shasum -a 256 "${WORK_DIR}/${ARCHIVE}" | awk '{print $1}')
else
  echo "Error: No SHA256 tool found (need sha256sum or shasum). Cannot verify binary integrity."
  exit 1
fi

if [ "$EXPECTED" != "$ACTUAL" ]; then
  echo "Checksum mismatch!"
  echo "  Expected: $EXPECTED"
  echo "  Got:      $ACTUAL"
  exit 1
fi

# Extract and install
echo "Installing to ${INSTALL_DIR}..."
tar -xzf "${WORK_DIR}/${ARCHIVE}" -C "$WORK_DIR"

# Find the binary (GoReleaser may wrap in subdirectory)
BINARY_PATH=$(find "$WORK_DIR" -name "$BINARY" -type f | head -1)
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
