# QaLabs

Install the QaLabs CLI (Qiscus Agent Copilot bot manager).

This distribution repo is **private**, so the installer uses the GitHub CLI for both fetch and updates.

```bash
gh release download --repo Qiscus-Integration/agentlabs_cli \
  --pattern install.sh -O- | sh
```

Requirements:

- **Node.js 16+**
- **`gh` CLI** authenticated with `repo` scope (`gh auth login`)

The installer pulls the latest single-file bundle (`qalabs.cjs`) into your PATH (`/usr/local/bin` or `~/.local/bin`) and writes a small `qalabs` shell launcher.

Environment overrides:

```bash
QALABS_VERSION=v1.2.0 sh install.sh             # pin a release
QALABS_INSTALL_DIR=~/.local/bin sh install.sh   # custom install dir
```

## Usage

```bash
qalabs --help
qalabs configure       # interactive credential setup
qalabs update          # pull the latest release via gh CLI
qalabs uninstall       # remove the binary
```

Documentation, source code, and issues live elsewhere (private Bitbucket). Reach out to the Qiscus team for access.

## What's in this repo

- `install.sh` — one-shot installer (uses `gh release download`)
- GitHub Releases — pre-built `qalabs.cjs` bundle (Node 16+, ~0.6 MB)

This repo intentionally does **not** contain product source code.

## License

MIT
