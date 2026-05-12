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
# 1. Detect OS / arch (informational; bundle is JS so the same artifact
#    works on every platform with Node 16+)
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

if [ "$OS" = "unknown" ]; then
  echo "✗ Unsupported OS: $(uname -s)" >&2
  exit 1
fi

# --------------------------------------------------------------------
# 2. Require Node.js 16+
# --------------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
  echo "✗ Node.js is required but was not found in PATH." >&2
  echo "  Install Node 16+ from https://nodejs.org and retry." >&2
  exit 1
fi

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 16 ]; then
  echo "✗ Node $NODE_MAJOR is too old. QaLabs needs Node 16+." >&2
  exit 1
fi

# --------------------------------------------------------------------
# 3. Resolve install directory
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
# 4. Resolve download URL
# --------------------------------------------------------------------
if [ -n "${QALABS_BUNDLE_URL:-}" ]; then
  ASSET_URL="$QALABS_BUNDLE_URL"
elif [ "$VERSION" = "latest" ]; then
  ASSET_URL="https://github.com/$REPO/releases/latest/download/qalabs.cjs"
else
  ASSET_URL="https://github.com/$REPO/releases/download/$VERSION/qalabs.cjs"
fi

# --------------------------------------------------------------------
# 5. Download bundle and write launcher
# --------------------------------------------------------------------
TMP_BUNDLE="$(mktemp)"
trap 'rm -f "$TMP_BUNDLE"' EXIT

echo "→ Detected: $OS/$ARCH, Node $(node -v)"
echo "→ Downloading qalabs.cjs from $ASSET_URL"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$ASSET_URL" -o "$TMP_BUNDLE"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$ASSET_URL" -O "$TMP_BUNDLE"
else
  echo "✗ Need curl or wget to download." >&2
  exit 1
fi

# Sanity check (avoid installing a 404 HTML page)
if ! head -c 100 "$TMP_BUNDLE" | grep -q "^#!.*node"; then
  echo "✗ Downloaded file does not look like the qalabs bundle." >&2
  echo "  Check that release $VERSION exists at https://github.com/$REPO/releases" >&2
  exit 1
fi

BUNDLE_PATH="$INSTALL_DIR/qalabs.cjs"
LAUNCHER_PATH="$INSTALL_DIR/qalabs"

install -m 755 "$TMP_BUNDLE" "$BUNDLE_PATH"

cat > "$LAUNCHER_PATH" <<EOF
#!/usr/bin/env sh
exec node "$BUNDLE_PATH" "\$@"
EOF
chmod +x "$LAUNCHER_PATH"

# --------------------------------------------------------------------
# 6. Verify
# --------------------------------------------------------------------
echo "→ Installed:"
echo "   $BUNDLE_PATH"
echo "   $LAUNCHER_PATH"

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
