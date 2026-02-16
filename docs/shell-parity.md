# Shell Parity Contract

bash and zsh login shells must resolve the same set of user-installed commands.

## PATH strategy

```
bash login:  ~/.profile  (adds ~/.local/bin)  ->  ~/.bashrc
zsh  login:  ~/.zprofile (sources ~/.profile)  ->  ~/.zshrc
```

- `~/.profile` is the single source of truth for user PATH additions
- Ubuntu 24.04's default `~/.profile` already adds `$HOME/.local/bin` to PATH
- `zsh/zprofile` sources `~/.profile` via `emulate sh -c` so zsh login shells inherit the same PATH
- `zsh/zshrc` does NOT modify PATH

## What lands in `~/.local/bin`

- pipx-installed tools (`poetry`, `ruff`, `pre-commit`)
- OpenCode (installed with `XDG_BIN_DIR=$HOME/.local/bin`)

## Verification

`scripts/shell-parity-check.sh` confirms that key commands resolve identically:

```bash
bash -lc "command -v <cmd>"
zsh  -lc "command -v <cmd>"
```

Both must succeed for every command listed in `docs/expected-commands.md` that installs to a user-writable location (`~/.local/bin`).

## Why this matters

Without `~/.zprofile`, a zsh login shell (e.g., a new terminal tab, SSH session, or tmux pane) would miss `~/.local/bin` and fail to find pipx tools and OpenCode.
