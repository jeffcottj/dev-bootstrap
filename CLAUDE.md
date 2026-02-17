# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Does

Bootstrap scripts for an Ubuntu 24.04 dev workstation. Installs system packages, Docker, dev tools (gh, az, code), pipx tools (poetry, ruff, pre-commit), OpenCode with oh-my-opencode, and configures zsh with dotfile symlinks. Targets physical machines and CI — not containers in production.

## Common Commands

```bash
# Lint all scripts
shellcheck scripts/*.sh

# Syntax-check all scripts (no shellcheck needed)
bash -n scripts/*.sh

# Run the full bootstrap (requires Ubuntu 24.04 + sudo)
./scripts/bootstrap-ubuntu-24.04.sh

# Run only system or user phase
./scripts/bootstrap-ubuntu-24.04.sh --system-only
./scripts/bootstrap-ubuntu-24.04.sh --user-only

# Post-bootstrap verification
./scripts/verify.sh
./scripts/shell-parity-check.sh
```

## Architecture

**Two-phase bootstrap** orchestrated by `scripts/bootstrap-ubuntu-24.04.sh`:

1. **`bootstrap-system.sh`** — apt packages, repo keys, Docker, services, UFW, TLP (requires sudo, refuses root)
2. **`bootstrap-user.sh`** — pipx tools, OpenCode, dotfile symlinks, git identity prompt, `chsh` to zsh

**Dotfile symlink flow** (`apply-dotfiles.sh`): repo files are symlinked into `~/`, existing non-symlink files are backed up with timestamps. Symlinks are idempotent — re-running skips correct links.

**Shell parity**: `zsh/zprofile` sources `~/.profile` via `emulate sh -c` so both bash and zsh login shells get `~/.local/bin` on PATH. The zshrc does NOT modify PATH.

**Git identity**: `git/gitconfig` uses `[include] path = ~/.gitconfig.local` — the bootstrap prompts for name/email and writes `~/.gitconfig.local` (skipped if file exists, skipped non-interactively in CI).

## Key Conventions

- All scripts use `set -euo pipefail` and `#!/usr/bin/env bash`
- Architecture-specific packages (Chrome = amd64 only) are gated with `ARCH="$(dpkg --print-architecture)"`
- Apt repos/keys check for file existence before adding (`if [[ ! -f ... ]]`)
- Tool installs use skip-or-upgrade pattern: `pipx install X || pipx upgrade X`
- Status output: `==>` for section headers; `OK`/`FAIL`/`WARN`/`SKIP` for verification checks
- CI pre-seeds `~/.gitconfig.local` to avoid interactive prompts; `chsh` failure is non-fatal

## CI

`.github/workflows/ci.yml` runs on ubuntu-24.04: shellcheck first, then full bootstrap + verify + shell-parity-check. ShellCheck must pass before bootstrap runs.
