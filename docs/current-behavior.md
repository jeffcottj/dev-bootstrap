# Current Behavior

What `dev-bootstrap` does today on a fresh Ubuntu 24.04 install.

## System-level (requires sudo)

1. `apt update && apt upgrade -y && apt autoremove -y`
2. Installs baseline apt packages:
   - Build tools: `build-essential`, `unzip`, `zip`
   - Networking: `apt-transport-https`, `ca-certificates`, `curl`, `wget`, `gnupg`, `software-properties-common`
   - CLI utilities: `git`, `jq`, `ripgrep`, `fd-find`, `fzf`, `tmux`, `tree`, `htop`, `bat`, `shellcheck`, `lsb-release`
   - Python: `python3-pip`, `python3-venv`, `pipx`
   - Desktop: `flatpak`
   - Security/power: `unattended-upgrades`, `ufw`, `tlp`
   - Shell: `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
3. Enables UFW firewall (`ufw --force enable`)
4. Enables unattended-upgrades (`dpkg-reconfigure -f noninteractive`)
5. Enables TLP laptop power management
6. Adds Docker official apt repo (key + sources list)
7. Adds Microsoft apt repo (key + sources for Azure CLI and VS Code)
8. Adds Google Chrome apt repo (amd64 only)
9. Installs: `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`, `azure-cli`, `code`, `gh`, and `google-chrome-stable` (amd64 only)
10. Enables Docker services (`containerd`, `docker`, `docker.socket`)
11. Adds current user to `docker` group

## User-level (no sudo)

1. Runs `pipx ensurepath`
2. Installs via pipx: `poetry`, `ruff`, `pre-commit`
3. Installs OpenCode to `~/.local/bin`
4. Installs Bun (JavaScript runtime required by oh-my-opencode)
5. Installs oh-my-opencode via `bunx oh-my-opencode install`
6. Smoke-tests OpenCode (`opencode --version`)
7. Symlinks dotfiles:
   - `zsh/zshrc` -> `~/.zshrc`
   - `git/gitconfig` -> `~/.gitconfig`

## Known gaps (addressed by the refactor)

- **No `~/.zprofile`**: zsh login shells don't source `~/.profile`, so `~/.local/bin` may not be on PATH
- **OpenCode not installed**: `zsh/zshrc` adds `~/.opencode/bin` to PATH but nothing installs OpenCode
- **Placeholder git identity**: `git/gitconfig` ships `Your Name` / `you@example.com`
- **No phase separation**: system and user setup are interleaved in one script
- **No verification**: no way to confirm bootstrap succeeded
- **Default shell not changed**: zsh is installed but `chsh` is never run
