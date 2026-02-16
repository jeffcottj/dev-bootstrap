#!/usr/bin/env bash
set -euo pipefail

# opencode-apply-profile.sh — apply an OpenCode configuration profile.
# Usage: opencode-apply-profile.sh [minimal|recommended] [--project]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RECOMMENDED_DIR="$REPO_ROOT/opencode/recommended"

# ---------------------------------------------------------------------------
# Profile definitions — set by load_profile()
# ---------------------------------------------------------------------------

MCP_LIST=()
RULES_FILE=""
AGENTS_LIST=()
COMMANDS_LIST=()

load_profile() {
  case "$1" in
    minimal)
      MCP_LIST=(context7 gh-grep)
      RULES_FILE=AGENTS.minimal.md
      AGENTS_LIST=()
      COMMANDS_LIST=()
      ;;
    recommended)
      MCP_LIST=(context7 gh-grep)
      RULES_FILE=AGENTS.recommended.md
      AGENTS_LIST=(code-reviewer explainer)
      COMMANDS_LIST=(test lint)
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

strip_jsonc_comments() {
  # Remove // line comments from JSONC so jq can parse it
  sed 's|^\s*//.*||; s|\s*//[^"]*$||' "$1"
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    cp -a "$target" "${target}.bak.${ts}"
    echo "  Backed up ${target} -> ${target}.bak.${ts}"
  fi
}

copy_if_changed() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ -f "$dest" ]] && diff -q "$src" "$dest" &>/dev/null; then
    echo "  SKIP $label (already up to date)"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  backup_if_exists "$dest"
  cp "$src" "$dest"
  echo "  OK   $label"
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

PROFILE="recommended"
PROJECT_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    minimal|recommended)
      PROFILE="$1"
      shift
      ;;
    --project)
      PROJECT_MODE=true
      shift
      ;;
    -h|--help)
      echo "Usage: opencode-apply-profile.sh [minimal|recommended] [--project]"
      echo ""
      echo "Profiles: minimal, recommended (default)"
      echo "Scope:    global (~/.config/opencode/) by default, --project for .opencode/"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: opencode-apply-profile.sh [minimal|recommended] [--project]" >&2
      exit 1
      ;;
  esac
done

if [[ "$PROJECT_MODE" == true ]]; then
  TARGET_DIR="$(pwd)/.opencode"
  RULES_DEST="$(pwd)/AGENTS.md"
else
  TARGET_DIR="$HOME/.config/opencode"
  RULES_DEST="$HOME/.config/opencode/AGENTS.md"
fi

load_profile "$PROFILE"

echo "==> Applying OpenCode profile: $PROFILE"
if [[ "$PROJECT_MODE" == true ]]; then
  echo "    Scope: project ($(pwd)/.opencode/)"
else
  echo "    Scope: global (~/.config/opencode/)"
fi

# ---------------------------------------------------------------------------
# 1. MCP servers — merge into opencode.json
# ---------------------------------------------------------------------------

echo "==> MCP servers"

OPENCODE_JSON="$TARGET_DIR/opencode.json"
mkdir -p "$TARGET_DIR"

# Create skeleton if missing
if [[ ! -f "$OPENCODE_JSON" ]]; then
  echo '{}' > "$OPENCODE_JSON"
  echo "  OK   Created $OPENCODE_JSON"
fi

BACKED_UP_JSON=false
for mcp_name in "${MCP_LIST[@]}"; do
  snippet="$RECOMMENDED_DIR/mcp/${mcp_name}.jsonc"
  if [[ ! -f "$snippet" ]]; then
    echo "  WARN Snippet not found: $snippet"
    continue
  fi

  # Check if key already exists in opencode.json
  # The snippet file has one top-level key (the server name)
  server_key="$(strip_jsonc_comments "$snippet" | jq -r 'keys[0]')"

  if jq -e ".mcp.\"$server_key\"" "$OPENCODE_JSON" &>/dev/null; then
    echo "  SKIP mcp/$server_key (already configured)"
    continue
  fi

  # Back up before first modification
  if [[ "$BACKED_UP_JSON" == false ]]; then
    backup_if_exists "$OPENCODE_JSON"
    BACKED_UP_JSON=true
  fi

  # Merge: add snippet under .mcp
  snippet_json="$(strip_jsonc_comments "$snippet")"
  jq --argjson s "$snippet_json" '.mcp = ((.mcp // {}) * $s)' "$OPENCODE_JSON" > "$OPENCODE_JSON.tmp"
  mv "$OPENCODE_JSON.tmp" "$OPENCODE_JSON"
  echo "  OK   mcp/$server_key"
done

# ---------------------------------------------------------------------------
# 2. Agents
# ---------------------------------------------------------------------------

echo "==> Agents"

if [[ ${#AGENTS_LIST[@]} -eq 0 ]]; then
  echo "  SKIP (none in $PROFILE profile)"
else
  for agent in "${AGENTS_LIST[@]}"; do
    copy_if_changed \
      "$RECOMMENDED_DIR/agents/${agent}.md" \
      "$TARGET_DIR/agents/${agent}.md" \
      "agents/$agent"
  done
fi

# ---------------------------------------------------------------------------
# 3. Commands
# ---------------------------------------------------------------------------

echo "==> Commands"

if [[ ${#COMMANDS_LIST[@]} -eq 0 ]]; then
  echo "  SKIP (none in $PROFILE profile)"
else
  for cmd in "${COMMANDS_LIST[@]}"; do
    copy_if_changed \
      "$RECOMMENDED_DIR/commands/${cmd}.md" \
      "$TARGET_DIR/commands/${cmd}.md" \
      "commands/$cmd"
  done
fi

# ---------------------------------------------------------------------------
# 4. Rules (AGENTS.md)
# ---------------------------------------------------------------------------

echo "==> Rules"

copy_if_changed \
  "$RECOMMENDED_DIR/rules/$RULES_FILE" \
  "$RULES_DEST" \
  "AGENTS.md (from $RULES_FILE)"

# ---------------------------------------------------------------------------
# 5. Plugins (guidance only)
# ---------------------------------------------------------------------------

echo "==> Plugins (manual install)"

plugin_docs=("$RECOMMENDED_DIR"/plugins/*.md)
if [[ -e "${plugin_docs[0]}" ]]; then
  for doc in "${plugin_docs[@]}"; do
    name="$(basename "$doc" .md)"
    echo "  INFO See opencode/recommended/plugins/${name}.md"
  done
else
  echo "  SKIP (no plugin docs found)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "==> Done. Profile '$PROFILE' applied to $TARGET_DIR"
if [[ "$PROJECT_MODE" == true ]]; then
  echo "    Rules written to $(pwd)/AGENTS.md"
else
  echo "    Rules written to $RULES_DEST"
fi
