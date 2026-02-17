#!/usr/bin/env bash
set -euo pipefail

# bootstrap-user.sh — user-level setup (no sudo required except for chsh).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Ensure pipx PATH is set"
pipx ensurepath || true

echo "==> Installing pipx tools (poetry, ruff, pre-commit)"
pipx install poetry || pipx upgrade poetry
pipx install ruff || pipx upgrade ruff
pipx install pre-commit || pipx upgrade pre-commit

echo "==> Installing OpenCode"
if command -v opencode &>/dev/null; then
  echo "OpenCode already installed: $(command -v opencode)"
else
  XDG_BIN_DIR="$HOME/.local/bin" curl -fsSL https://opencode.ai/install | bash
fi

echo "==> Installing Bun"
if command -v bun &>/dev/null; then
  echo "Bun already installed: $(bun --version)"
else
  curl -fsSL https://bun.sh/install | bash
  # Source into current session so bunx is available immediately
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

echo "==> Installing oh-my-opencode"
if bunx oh-my-opencode --version &>/dev/null; then
  echo "oh-my-opencode already installed."
else
  bunx oh-my-opencode install --no-tui --claude=no --gemini=no --copilot=no --openai=no
  echo "oh-my-opencode installed. Run 'opencode auth login' to configure API keys."
fi

echo "==> Smoke-testing OpenCode"
if opencode --version &>/dev/null; then
  echo "  OK   opencode $(opencode --version 2>/dev/null)"
else
  echo "  WARN opencode installed but failed to run"
fi

echo "==> Applying dotfiles (zsh, git)"
bash "$SCRIPT_DIR/apply-dotfiles.sh"

echo "==> Setting up git identity"
if [[ -f "$HOME/.gitconfig.local" ]]; then
  echo "Git identity already configured in ~/.gitconfig.local, skipping."
else
  # In non-interactive mode (CI), skip the prompt
  if [[ ! -t 0 ]]; then
    echo "WARNING: No ~/.gitconfig.local found and stdin is not a terminal."
    echo "Create ~/.gitconfig.local manually with your [user] name and email."
  else
    echo "No ~/.gitconfig.local found. Let's set up your git identity."
    read -rp "  Full name: " git_name
    read -rp "  Email: " git_email
    cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = ${git_name}
	email = ${git_email}
EOF
    echo "Wrote ~/.gitconfig.local"
  fi
fi

echo "==> Setting default shell to zsh"
if [[ "$(basename "$SHELL")" == "zsh" ]]; then
  echo "Default shell is already zsh."
else
  if sudo chsh -s "$(which zsh)" "$USER" 2>/dev/null; then
    echo "Default shell changed to zsh. Log out and back in for it to take effect."
  else
    echo "WARNING: chsh failed (this is normal in containers/CI). Change your shell manually:"
    echo "  chsh -s \$(which zsh)"
  fi
fi

echo "==> User-level setup complete."
