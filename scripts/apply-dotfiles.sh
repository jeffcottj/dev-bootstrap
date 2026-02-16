#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    mv "$target" "${target}.bak.${ts}"
    echo "Backed up ${target} -> ${target}.bak.${ts}"
  fi
}

link_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  backup_if_exists "$dest"

  # If it's already the correct symlink, do nothing
  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    echo "Already linked: $dest"
    return 0
  fi

  ln -sfn "$src" "$dest"
  echo "Linked: $dest -> $src"
}

echo "Applying dotfiles from: $REPO_ROOT"

link_file "$REPO_ROOT/zsh/zprofile" "$HOME/.zprofile"
link_file "$REPO_ROOT/zsh/zshrc" "$HOME/.zshrc"
link_file "$REPO_ROOT/git/gitconfig" "$HOME/.gitconfig"

echo "Done."