# Expected Commands

Every command that should be available after a full bootstrap. Used by `scripts/verify.sh`.

## From apt packages

| Command | Package |
|---------|---------|
| `git` | git |
| `curl` | curl |
| `wget` | wget |
| `jq` | jq |
| `rg` | ripgrep |
| `fdfind` | fd-find |
| `fzf` | fzf |
| `tmux` | tmux |
| `tree` | tree |
| `htop` | htop |
| `batcat` | bat |
| `make` | build-essential |
| `zsh` | zsh |
| `python3` | python3 |
| `pipx` | pipx |
| `docker` | docker-ce-cli |
| `gh` | gh |
| `az` | azure-cli |
| `code` | code |
| `google-chrome-stable` | google-chrome-stable (amd64 only) |
| `lsb_release` | lsb-release |
| `flatpak` | flatpak |

## From pipx

| Command | pipx package |
|---------|-------------|
| `poetry` | poetry |
| `ruff` | ruff |
| `pre-commit` | pre-commit |

## From direct install

| Command | Install method |
|---------|---------------|
| `opencode` | opencode.ai install script -> `~/.local/bin` (smoke-tested during bootstrap) |
| `bun` | bun.sh install script -> `~/.bun/bin` |

## Verified but not required (warnings only)

| Check | How |
|-------|-----|
| oh-my-opencode | `bunx oh-my-opencode --version` |
| OpenCode auth | `opencode auth list` |
