#!/usr/bin/env sh
# QaLabs installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/agentlabs_cli/main/install.sh | sh
#
# Environment overrides:
#   QALABS_VERSION      Release tag to install (default: latest)
#   QALABS_INSTALL_DIR  Directory to install into (default: /usr/local/bin or ~/.local/bin)
#   QALABS_REPO         GitHub repo path (default: Qiscus-Integration/agentlabs_cli)

set -eu

REPO="${QALABS_REPO:-Qiscus-Integration/agentlabs_cli}"
VERSION="${QALABS_VERSION:-latest}"

# --------------------------------------------------------------------
# 1. Detect OS / arch and pick the matching asset
# --------------------------------------------------------------------
detect_os() {
  case "$(uname -s)" in
    Darwin)            echo "macos" ;;
    Linux)             echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)                 echo "unknown" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "x64" ;;
    arm64|aarch64) echo "arm64" ;;
    *)             echo "unknown" ;;
  esac
}

OS="$(detect_os)"
ARCH="$(detect_arch)"

case "$OS-$ARCH" in
  macos-arm64)   ASSET="qalabs-macos-arm64" ;;
  macos-x64)     ASSET="qalabs-macos-x64" ;;
  linux-x64)     ASSET="qalabs-linux-x64" ;;
  linux-arm64)   ASSET="qalabs-linux-arm64" ;;
  windows-x64)   ASSET="qalabs-windows-x64.exe" ;;
  *)
    echo "✗ Unsupported platform: $OS/$ARCH" >&2
    echo "  Supported: macos-arm64, macos-x64, linux-x64, linux-arm64, windows-x64" >&2
    exit 1
    ;;
esac

# --------------------------------------------------------------------
# 2. Resolve install directory
# --------------------------------------------------------------------
if [ -n "${QALABS_INSTALL_DIR:-}" ]; then
  INSTALL_DIR="$QALABS_INSTALL_DIR"
elif [ -w "/usr/local/bin" ]; then
  INSTALL_DIR="/usr/local/bin"
elif [ -w "/usr/local" ]; then
  INSTALL_DIR="/usr/local/bin"
else
  INSTALL_DIR="$HOME/.local/bin"
fi
mkdir -p "$INSTALL_DIR"

# --------------------------------------------------------------------
# 3. Resolve download URL
# --------------------------------------------------------------------
if [ "$VERSION" = "latest" ]; then
  ASSET_URL="https://github.com/$REPO/releases/latest/download/$ASSET"
else
  ASSET_URL="https://github.com/$REPO/releases/download/$VERSION/$ASSET"
fi

# --------------------------------------------------------------------
# 4. Download the native binary
# --------------------------------------------------------------------
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

echo "→ Detected: $OS/$ARCH"
echo "→ Downloading $ASSET_URL"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$ASSET_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$ASSET_URL" -O "$TMP_FILE"
else
  echo "✗ Need curl or wget to download." >&2
  exit 1
fi

# Sanity check (native binary is at least a few MB)
SIZE="$(wc -c < "$TMP_FILE" | tr -d ' ')"
if [ "$SIZE" -lt 1000000 ]; then
  echo "✗ Downloaded file is too small (${SIZE} bytes). Likely a 404 page." >&2
  echo "  Check that release $VERSION exists at https://github.com/$REPO/releases" >&2
  exit 1
fi

# --------------------------------------------------------------------
# 5. Install
# --------------------------------------------------------------------
if [ "$OS" = "windows" ]; then
  TARGET="$INSTALL_DIR/qalabs.exe"
else
  TARGET="$INSTALL_DIR/qalabs"
fi

install -m 755 "$TMP_FILE" "$TARGET"

# --------------------------------------------------------------------
# 6. Verify
# --------------------------------------------------------------------
echo "→ Installed: $TARGET"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo
    echo "! $INSTALL_DIR is not in your PATH. Add this to your shell rc:"
    echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac

echo
echo "✓ Done. Try: qalabs --version"
