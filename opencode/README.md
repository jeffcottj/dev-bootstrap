# OpenCode Configuration

Curated OpenCode configuration profiles for dev workstations. Includes MCP servers, agents, commands, and rules that can be applied globally or per-project.

## OpenCode Config Precedence

OpenCode resolves configuration from multiple layers (highest priority first):

| Priority | Source | Scope | Location |
|----------|--------|-------|----------|
| 1 | Session flags | Session | CLI arguments |
| 2 | Project config | Project | `.opencode/` in project root |
| 3 | Global config | User | `~/.config/opencode/` |
| 4 | Remote config | Org | `.well-known/opencode.json` on a URL |
| 5 | Built-in defaults | System | OpenCode binary |

Lower-priority settings are overridden by higher-priority ones. This means project config always wins over global config.

## Quick Start

Apply the recommended profile globally (affects all projects):

```bash
./opencode/scripts/opencode-apply-profile.sh recommended
```

Or apply the minimal profile to the current project only:

```bash
./opencode/scripts/opencode-apply-profile.sh minimal --project
```

## Profiles

| Component | Minimal | Recommended |
|-----------|---------|-------------|
| **MCP: context7** | Yes | Yes |
| **MCP: gh-grep** | Yes | Yes |
| **Agent: code-reviewer** | — | Yes |
| **Agent: explainer** | — | Yes |
| **Command: test** | — | Yes |
| **Command: lint** | — | Yes |
| **Rules** | AGENTS.minimal.md | AGENTS.recommended.md |

## Manual Opt-In

Instead of applying a full profile, copy individual pieces:

**Add an MCP server** — merge a snippet into your `opencode.json`:

```bash
# Merge context7 into global config
jq -s '.[0] * {mcp: (.[0].mcp // {} | . * .[1])}' \
  ~/.config/opencode/opencode.json \
  opencode/recommended/mcp/context7.jsonc \
  > tmp.$$.json && mv tmp.$$.json ~/.config/opencode/opencode.json
```

**Add an agent**:

```bash
cp opencode/recommended/agents/code-reviewer.md ~/.config/opencode/agents/
```

**Add a command**:

```bash
cp opencode/recommended/commands/test.md ~/.config/opencode/commands/
```

**Add rules**:

```bash
cp opencode/recommended/rules/AGENTS.recommended.md ~/.config/opencode/AGENTS.md
```

## Customization and Overrides

- **Global config** lives in `~/.config/opencode/`. Changes here apply to all projects.
- **Project config** lives in `.opencode/` at the project root. It overrides global config.
- To **disable** an MCP server from a higher layer, set `"enabled": false` in the project config.
- To **customize agents/commands**, copy them into your project's `.opencode/agents/` or `.opencode/commands/` and edit.
- **Rules** (`AGENTS.md`) can be placed at the repo root or in `.opencode/`. Edit freely — they're plain markdown.
- The `remote/opencode.jsonc` file is a reference template for org-level config. See [OpenCode docs](https://opencode.ai/docs/remote-config) for hosting details.
