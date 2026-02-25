# dev-bootstrap (Ubuntu 24.04)

One-command setup for the most effective vibe coding environment available on Ubuntu 24.04. Puts non-developers behind the wheel of [OpenCode](https://opencode.ai) + [oh-my-opencode](https://github.com/nichochar/oh-my-opencode) for rapid natural language prototyping — no prior dev experience required.

Everything follows a "latest stable" model: nothing is version-pinned, and the specific tools and plugins included are subject to change as better options become available.

## What it does

### System-level (requires sudo)

- **Base packages**: build-essential, curl, wget, git, jq, ripgrep, fd-find, fzf, tmux, tree, htop, bat, lsb-release, flatpak
- **Shell**: zsh + zsh-autosuggestions + zsh-syntax-highlighting
- **Python**: python3-venv, python3-pip, pipx
- **Security/power**: UFW firewall, unattended-upgrades, TLP
- **Docker Engine**: official repo with buildx + compose plugin
- **Dev tools**: GitHub CLI (gh), Azure CLI (az), VS Code, Google Chrome (amd64 only)

### User-level (no sudo)

- **pipx tools**: poetry, ruff, pre-commit
- **Bun**: JavaScript runtime used by oh-my-opencode
- **OpenCode + oh-my-opencode**: OpenCode installed to `~/.local/bin` (smoke-tested during bootstrap), oh-my-opencode provides batteries-included agents, MCPs, and hooks
- **Dotfiles**: zprofile, zshrc, gitconfig symlinked from this repo
- **Git identity**: interactive prompt writes `~/.gitconfig.local` (skipped if file exists)
- **Default shell**: changed to zsh via `chsh`

## Quick start

If the repo is already on this machine (e.g., from a USB stick):

    cd ~/repos/dev-bootstrap
    ./scripts/bootstrap-ubuntu-24.04.sh

Starting from scratch:

    git clone <this-repo-url> ~/repos/dev-bootstrap && ~/repos/dev-bootstrap/scripts/bootstrap-ubuntu-24.04.sh

Log out and back in, then verify:

    ./scripts/verify.sh
    ./scripts/shell-parity-check.sh

## Getting started after install

See **[docs/getting-started.md](docs/getting-started.md)** for a short walkthrough: set up your AI provider key, launch OpenCode, and start building with natural language.

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
- Google Chrome is installed from Google's apt repo only on `amd64` (it is skipped on other CPU architectures)
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

- **`scripts/verify.sh`** — checks all expected commands exist (including architecture-specific ones), dotfile symlinks are correct, git identity is set, and default shell is zsh
- **`scripts/shell-parity-check.sh`** — verifies that `~/.local/bin` is on PATH in both bash and zsh, and that user-installed commands resolve identically

## Customization

- **Additional apt packages**: add them to `scripts/bootstrap-system.sh`
- **Additional pipx tools**: add them to `scripts/bootstrap-user.sh`
- **OpenCode plugins**: oh-my-opencode manages agents, MCPs, and hooks — run `bunx oh-my-opencode` to reconfigure
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
  getting-started.md           # non-dev quick start guide
  current-behavior.md          # documents what the repo does
  expected-commands.md          # lists every expected command
  shell-parity.md              # defines the bash/zsh parity contract

.github/workflows/
  ci.yml                       # shellcheck + full bootstrap + verify
```
