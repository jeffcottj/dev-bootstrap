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
- `zsh/zshrc` also adds `~/.local/bin` to PATH — most terminal emulators open non-login shells where `~/.zprofile` is never sourced

## What lands where

- `~/.local/bin`: pipx-installed tools (`poetry`, `ruff`, `pre-commit`), OpenCode

## Verification

`scripts/shell-parity-check.sh` confirms that key commands resolve identically:

```bash
bash -lc "command -v <cmd>"
zsh  -lc "command -v <cmd>"
```

Both must succeed for every command listed in `docs/expected-commands.md` that installs to a user-writable location (`~/.local/bin`).

## Why this matters

Without PATH setup in both `~/.zprofile` and `~/.zshrc`, user tools would be missing depending on whether the terminal opens a login shell (SSH, tmux) or non-login shell (most GUI terminal emulators like GNOME Terminal).
