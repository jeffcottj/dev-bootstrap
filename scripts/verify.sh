#!/usr/bin/env bash
set -euo pipefail

# verify.sh — post-bootstrap verification.
# Checks that expected commands exist, dotfile symlinks are correct,
# git identity is configured, and default shell is zsh.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

errors=0

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
for cmd in git curl wget jq rg fdfind fzf tmux tree htop batcat make zsh python3 pipx docker gh az code google-chrome-stable flatpak; do
  check_command "$cmd"
done

# pipx tools
for cmd in poetry ruff pre-commit; do
  check_command "$cmd"
done

# direct installs
check_command opencode

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
if [[ "$errors" -eq 0 ]]; then
  echo "All checks passed."
else
  echo "$errors check(s) failed."
  exit 1
fi
