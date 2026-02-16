# Worktree Plugin

Git worktree management from within OpenCode.

## What It Does

The `opencode-worktree` npm package provides commands to create, list, switch, and remove git worktrees without leaving your OpenCode session. Useful for reviewing PRs or working on multiple branches simultaneously.

## Installation

```bash
npm install -g opencode-worktree
```

Then add to your `opencode.json`:

```jsonc
{
  "plugin": ["opencode-worktree"]
}
```

## Usage

Once installed, OpenCode gains commands for worktree operations:

- **Create**: spin up a new worktree for a branch
- **List**: see all active worktrees
- **Switch**: change the working directory to another worktree
- **Remove**: clean up a worktree when done

## Configuration

Optional settings in `opencode.json`:

```jsonc
{
  "plugin": ["opencode-worktree"],
  "worktree": {
    // Base directory for worktrees (default: ../project-worktrees/)
    "base": "../worktrees"
  }
}
```
