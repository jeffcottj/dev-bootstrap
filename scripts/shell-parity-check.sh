#!/usr/bin/env bash
set -euo pipefail

# shell-parity-check.sh — verify that bash and zsh login shells resolve
# the same user-installed commands and share ~/.local/bin on PATH.

errors=0

echo "=== PATH check: ~/.local/bin ==="
for shell in bash zsh; do
  # shellcheck disable=SC2016 # $PATH must expand inside the spawned shell, not here
  if $shell -lc 'echo "$PATH"' 2>/dev/null | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
    echo "  OK   $shell login shell has ~/.local/bin on PATH"
  else
    echo "  FAIL $shell login shell is missing ~/.local/bin on PATH"
    ((errors++))
  fi
done

echo ""
echo "=== PATH check: ~/.bun/bin ==="
for shell in bash zsh; do
  # shellcheck disable=SC2016 # $PATH must expand inside the spawned shell, not here
  if $shell -lc 'echo "$PATH"' 2>/dev/null | tr ':' '\n' | grep -qx "$HOME/.bun/bin"; then
    echo "  OK   $shell login shell has ~/.bun/bin on PATH"
  else
    echo "  WARN $shell login shell is missing ~/.bun/bin on PATH"
  fi
done

echo ""
echo "=== Command resolution parity ==="

# Commands that install to user-writable locations (~/.local/bin)
user_commands=(poetry ruff pre-commit opencode bun)

for cmd in "${user_commands[@]}"; do
  bash_path="$(bash -lc "command -v $cmd" 2>/dev/null || true)"
  zsh_path="$(zsh -lc "command -v $cmd" 2>/dev/null || true)"

  if [[ -z "$bash_path" && -z "$zsh_path" ]]; then
    echo "  SKIP $cmd — not installed"
  elif [[ -z "$bash_path" ]]; then
    echo "  FAIL $cmd — found in zsh ($zsh_path) but not bash"
    ((errors++))
  elif [[ -z "$zsh_path" ]]; then
    echo "  FAIL $cmd — found in bash ($bash_path) but not zsh"
    ((errors++))
  elif [[ "$bash_path" == "$zsh_path" ]]; then
    echo "  OK   $cmd -> $bash_path"
  else
    echo "  WARN $cmd — different paths: bash=$bash_path zsh=$zsh_path"
  fi
done

echo ""
if [[ "$errors" -eq 0 ]]; then
  echo "Shell parity checks passed."
else
  echo "$errors parity check(s) failed."
  exit 1
fi
