# QaLabs

> Git-like CLI untuk mengelola Qiscus Agent Copilot — edit `interaction_rules` & `organization_description` sebagai markdown, versioning lokal, push/pull ke server.

## Install

```sh
gh release download --repo Qiscus-Integration/agentlabs_cli --pattern install.sh -O- | sh
```

Setelah selesai, jalankan:

```sh
qalabs --version
```

Selesai. Kalau direktori install (`/usr/local/bin` atau `~/.local/bin`) belum ada di `PATH`, installer akan kasih satu baris untuk dimasukkan ke shell rc.

### Prasyarat

- **Node.js 16+** — `node --version`
- **GitHub CLI** — `gh --version` (sekali `gh auth login`)

## Pakai

### 1. Setup proyek

```sh
mkdir my-bot && cd my-bot
qalabs init               # bikin .qalabs/ (mirip git init)
qalabs configure          # masukkan App ID, App Secret (masked), Admin Email
```

`configure` selalu interaktif — secret tidak akan terlihat di shell history.

### 2. Pilih bot, pull konten

```sh
qalabs list                       # daftar bot di server
qalabs use 123 --name "My Bot"    # pilih bot
qalabs pull                       # download → rules.md, organization.md, bot.json, tools/
```

Setelah `pull`:

```text
my-bot/
├── rules.md              # interaction_rules (editable)
├── organization.md       # organization_description (editable)
├── bot.json              # field pendek (model, vendor, args.*, foa_status, ...)
├── tools/                # satu folder per tipe tool
│   ├── http_api/
│   ├── markdown/
│   ├── pdf/
│   └── ...
└── .qalabs/              # snapshot history (jangan disentuh)
```

### 3. Edit, cek perubahan, push

```sh
$EDITOR rules.md
qalabs status                     # ringkasan apa yang berubah
qalabs diff                       # full unified diff
qalabs push -m "tighten greeting" # PATCH ke server + snapshot baru
```

`push` cuma kirim field yang berubah. Kalau bot di server di-update orang lain setelah `pull`-mu, push akan ditolak — `qalabs pull` dulu, atau pakai `qalabs push --force`.

### 4. History & undo

```sh
qalabs log                  # daftar snapshot (newest first)
qalabs diff <ts1> <ts2>     # bandingkan dua snapshot
qalabs restore <timestamp>  # tarik working files ke snapshot tertentu
qalabs doctor               # diagnostic lengkap (auth, snapshots, sync state)
```

## Update & uninstall

```sh
qalabs update --check     # cek versi terbaru
qalabs update             # download + replace binary
qalabs uninstall          # hapus binary; tanya konfirmasi sebelum hapus ~/.qalabs
```

## Environment variables

```sh
# Non-interactive `configure` untuk CI (tidak pernah dibaca dari argv supaya
# secret tidak nyangkut di shell history / ps aux).
QALABS_APP_ID=...
QALABS_APP_SECRET=...
QALABS_ADMIN_EMAIL=...
QALABS_SERVER=https://chatgpt.qiscus.com

# Override install dir / versi installer
QALABS_INSTALL_DIR="$HOME/.local/bin"
QALABS_VERSION=v1.2.0
```

## Security

Session credential (`~/.qalabs/session/*/session.json`) disimpan **terenkripsi** (AES-256-GCM, key derived dari fingerprint mesin) dengan permission `0600`. Backup yang tidak sengaja ke-share atau `git add` tidak bisa dipakai di mesin lain. Detail lengkap & escape hatch ada di dokumentasi internal tim.

## Bantuan

```sh
qalabs --help
qalabs <command> --help
```

Dokumentasi & source code internal — hubungi tim Qiscus.

## License

MIT
