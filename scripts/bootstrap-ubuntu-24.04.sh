#!/usr/bin/env bash
set -euo pipefail

# bootstrap-ubuntu-24.04.sh — orchestrator for dev workstation setup.
#
# Usage:
#   ./scripts/bootstrap-ubuntu-24.04.sh               # full setup (system + user)
#   ./scripts/bootstrap-ubuntu-24.04.sh --system-only  # system packages and services only
#   ./scripts/bootstrap-ubuntu-24.04.sh --user-only    # user tools, dotfiles, shell only

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_system=true
run_user=true

for arg in "$@"; do
  case "$arg" in
    --system-only)
      run_user=false
      ;;
    --user-only)
      run_system=false
      ;;
    -h|--help)
      echo "Usage: $0 [--system-only | --user-only]"
      echo ""
      echo "  --system-only   Run only system-level setup (apt, repos, Docker, services)"
      echo "  --user-only     Run only user-level setup (pipx, OpenCode, dotfiles, shell)"
      echo "  (no flags)      Run both system and user setup"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Run $0 --help for usage."
      exit 1
      ;;
  esac
done

if $run_system; then
  echo "========================================="
  echo "  Phase 1: System-level setup"
  echo "========================================="
  "$SCRIPT_DIR/bootstrap-system.sh"
  echo ""
fi

if $run_user; then
  echo "========================================="
  echo "  Phase 2: User-level setup"
  echo "========================================="
  "$SCRIPT_DIR/bootstrap-user.sh"
  echo ""
fi

echo "========================================="
echo "  Bootstrap complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Log out and log back in (applies docker group + zsh default shell)"
echo "  2. Authenticate GitHub CLI: gh auth login"
echo "  3. Verify: ./scripts/verify.sh"
echo "  4. Check shell parity: ./scripts/shell-parity-check.sh"
