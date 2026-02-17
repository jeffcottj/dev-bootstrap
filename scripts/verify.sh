#!/usr/bin/env bash
set -euo pipefail

# verify.sh — post-bootstrap verification.
# Checks that expected commands exist, dotfile symlinks are correct,
# git identity is configured, and default shell is zsh.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

errors=0
ARCH="$(dpkg --print-architecture)"

check_command() {
  local cmd="$1"
  if command -v "$cmd" &>/dev/null; then
    echo "  OK   $cmd ($(command -v "$cmd"))"
  else
    echo "  FAIL $cmd — not found"
    ((errors++))
  fi
}

check_symlink() {
  local link="$1"
  local expected_target="$2"
  if [[ -L "$link" ]]; then
    local actual
    actual="$(readlink -f "$link")"
    local expected
    expected="$(readlink -f "$expected_target")"
    if [[ "$actual" == "$expected" ]]; then
      echo "  OK   $link -> $expected_target"
    else
      echo "  FAIL $link -> $actual (expected $expected_target)"
      ((errors++))
    fi
  else
    echo "  FAIL $link — not a symlink"
    ((errors++))
  fi
}

echo "=== Command checks ==="

# apt packages
apt_commands=(git curl wget jq rg fdfind fzf tmux tree htop batcat make zsh python3 pipx docker gh az code flatpak)
if [[ "$ARCH" == "amd64" ]]; then
  apt_commands+=(google-chrome-stable)
fi

for cmd in "${apt_commands[@]}"; do
  check_command "$cmd"
done

# pipx tools
for cmd in poetry ruff pre-commit; do
  check_command "$cmd"
done

# direct installs
check_command opencode
check_command bun

echo ""
echo "=== OpenCode + oh-my-opencode checks ==="

# OMO installed check
if bunx oh-my-opencode --version &>/dev/null; then
  echo "  OK   oh-my-opencode ($(bunx oh-my-opencode --version 2>/dev/null))"
else
  echo "  WARN oh-my-opencode — not detected (run: bunx oh-my-opencode install)"
fi

# Auth configured check
if opencode auth list &>/dev/null 2>&1; then
  echo "  OK   OpenCode auth configured"
else
  echo "  WARN OpenCode auth not configured (run: opencode auth login)"
fi

echo ""
echo "=== Dotfile symlink checks ==="
check_symlink "$HOME/.zprofile" "$REPO_ROOT/zsh/zprofile"
check_symlink "$HOME/.zshrc" "$REPO_ROOT/zsh/zshrc"
check_symlink "$HOME/.gitconfig" "$REPO_ROOT/git/gitconfig"

echo ""
echo "=== Git identity check ==="
if [[ -f "$HOME/.gitconfig.local" ]]; then
  git_name="$(git config --get user.name 2>/dev/null || true)"
  git_email="$(git config --get user.email 2>/dev/null || true)"
  if [[ -n "$git_name" && -n "$git_email" ]]; then
    echo "  OK   Git identity: $git_name <$git_email>"
  else
    echo "  FAIL Git identity not fully set (name='$git_name', email='$git_email')"
    ((errors++))
  fi
else
  echo "  FAIL ~/.gitconfig.local does not exist"
  ((errors++))
fi

echo ""
echo "=== Default shell check ==="
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" == *zsh* ]]; then
  echo "  OK   Default shell: $current_shell"
else
  echo "  WARN Default shell is $current_shell (expected zsh)"
  echo "       This may be expected in CI/containers where chsh is restricted."
fi

echo ""
echo "========================================="
if [[ "$errors" -eq 0 ]]; then
  if opencode auth list &>/dev/null 2>&1; then
    echo "  Ready to vibe code!"
    echo ""
    echo "  Start building:  opencode"
    echo "  Need help?       See docs/getting-started.md"
  else
    echo "  All tools installed. One more step:"
    echo ""
    echo "  Run:  opencode auth login"
    echo "  Then: opencode"
  fi
else
  echo "  Not ready yet — $errors check(s) failed above."
  echo "  Fix the FAIL items and re-run this script."
fi
echo "========================================="
if [[ "$errors" -gt 0 ]]; then
  exit 1
fi
