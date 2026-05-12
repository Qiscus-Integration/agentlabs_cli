# QaLabs

Install the QaLabs CLI (Qiscus Agent Copilot bot manager).

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/agentlabs_cli/main/install.sh | sh
```

Requirements: **Node.js 16+**.

The installer detects your OS, verifies Node is installed, then downloads the latest single-file bundle from this repository's GitHub Releases into your PATH (`/usr/local/bin` or `~/.local/bin`).

Environment overrides:

```bash
QALABS_VERSION=v1.2.0 sh install.sh           # pin a release
QALABS_INSTALL_DIR=~/.local/bin sh install.sh # custom install dir
```

## Usage

```bash
qalabs --help
```

Documentation, source code, and issues live elsewhere (private). Reach out to the Qiscus team for access.

## What's in this repo

- `install.sh` — one-shot installer
- GitHub Releases — pre-built `qalabs.cjs` bundle (Node 16+, ~0.6 MB)

This repo intentionally does **not** contain product source code.

## License

MIT
