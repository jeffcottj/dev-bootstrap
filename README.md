# dev-bootstrap (Ubuntu 24.04)

Opinionated but minimal dev workstation bootstrap for Ubuntu 24.04 (noble).

## What it does

### System-level (requires sudo)

- **Base packages**: build-essential, curl, wget, git, jq, ripgrep, fd-find, fzf, tmux, tree, htop, bat, flatpak
- **Shell**: zsh + zsh-autosuggestions + zsh-syntax-highlighting
- **Python**: python3-venv, python3-pip, pipx
- **Security/power**: UFW firewall, unattended-upgrades, TLP
- **Docker Engine**: official repo with buildx + compose plugin
- **Dev tools**: GitHub CLI (gh), Azure CLI (az), VS Code, Google Chrome

### User-level (no sudo)

- **pipx tools**: poetry, ruff, pre-commit
- **OpenCode**: installed to `~/.local/bin`
- **Dotfiles**: zprofile, zshrc, gitconfig symlinked from this repo
- **Git identity**: interactive prompt writes `~/.gitconfig.local` (skipped if file exists)
- **Default shell**: changed to zsh via `chsh`

## Quick start

```bash
git clone <this-repo-url> ~/repos/dev-bootstrap
cd ~/repos/dev-bootstrap
./scripts/bootstrap-ubuntu-24.04.sh
```

Log out and back in, then verify:

```bash
./scripts/verify.sh
./scripts/shell-parity-check.sh
```

## Phase flags

Run system or user setup independently:

```bash
./scripts/bootstrap-ubuntu-24.04.sh --system-only   # apt, repos, Docker, services
./scripts/bootstrap-ubuntu-24.04.sh --user-only     # pipx, OpenCode, dotfiles, shell
```

## Shell parity

bash and zsh login shells share the same PATH. The strategy:

```
bash login:  ~/.profile  (adds ~/.local/bin)  ->  ~/.bashrc
zsh  login:  ~/.zprofile (sources ~/.profile)  ->  ~/.zshrc
```

`~/.profile` is the single source of truth. `zsh/zprofile` sources it via `emulate sh -c` so both shells find pipx tools and OpenCode in `~/.local/bin`.

See [docs/shell-parity.md](docs/shell-parity.md) for details.

## Safe re-runs

The bootstrap is idempotent:

- apt repos are only added if their sources file doesn't exist
- pipx installs skip or upgrade existing packages
- OpenCode install is skipped if `opencode` is already on PATH
- Dotfile symlinks are only updated if they point elsewhere
- Git identity prompt is skipped if `~/.gitconfig.local` exists
- `chsh` is skipped if the default shell is already zsh

## Docker notes

- Docker is installed from the official Docker repo (not Ubuntu's `docker.io`)
- Your user is added to the `docker` group (requires logout/login to take effect)
- Includes buildx and compose plugin (`docker compose`, not `docker-compose`)

## Git and auth onboarding

The bootstrap prompts for your name and email and writes `~/.gitconfig.local`. The main `git/gitconfig` includes this file via `[include] path = ~/.gitconfig.local`.

To authenticate with GitHub:

```bash
gh auth login
```

This also configures the git credential helper for HTTPS.

## Verification

Two verification scripts are provided:

- **`scripts/verify.sh`** — checks all expected commands exist, dotfile symlinks are correct, git identity is set, and default shell is zsh
- **`scripts/shell-parity-check.sh`** — verifies that `~/.local/bin` is on PATH in both bash and zsh, and that user-installed commands resolve identically

## Customization

- **Additional apt packages**: add them to `scripts/bootstrap-system.sh`
- **Additional pipx tools**: add them to `scripts/bootstrap-user.sh`
- **Zsh config**: edit `zsh/zshrc` (aliases, prompt, plugins)
- **Git config**: edit `git/gitconfig` for shared settings; use `~/.gitconfig.local` for per-machine settings (identity, signing key)

## File inventory

```
scripts/
  bootstrap-ubuntu-24.04.sh   # orchestrator (--system-only / --user-only)
  bootstrap-system.sh          # system packages, repos, Docker, services
  bootstrap-user.sh            # pipx, OpenCode, dotfiles, git identity, chsh
  apply-dotfiles.sh            # symlinks dotfiles into ~/
  verify.sh                    # post-bootstrap verification
  shell-parity-check.sh        # bash/zsh PATH parity check

zsh/
  zprofile                     # sources ~/.profile for PATH
  zshrc                        # aliases, prompt, plugins

git/
  gitconfig                    # shared git config (includes ~/.gitconfig.local)

docs/
  current-behavior.md          # documents what the repo does
  expected-commands.md          # lists every expected command
  shell-parity.md              # defines the bash/zsh parity contract

.github/workflows/
  ci.yml                       # shellcheck + full bootstrap + verify
```
