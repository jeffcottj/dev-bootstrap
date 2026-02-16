# Project Conventions

## Code Style

- Follow existing patterns and conventions in the codebase
- Use consistent naming: snake_case for Python/Shell, camelCase for JS/TS
- Keep functions focused — one function, one responsibility
- Prefer explicit over clever; readability over brevity

## Error Handling

- Handle errors at the appropriate level — don't swallow exceptions silently
- Provide actionable error messages that help with debugging
- Use early returns to reduce nesting

## Testing

- Write tests for new features and bug fixes
- Tests should be deterministic — no flaky tests
- Name tests descriptively: what is being tested and expected outcome
- Aim for meaningful coverage, not 100% line coverage

## Commits and PRs

- Keep commits atomic — one logical change per commit
- Write commit messages that explain "why", not just "what"
- PR descriptions should include context, what changed, and how to test

## Security

- Never commit secrets, tokens, API keys, or credentials
- Never commit .env files — use .env.example with placeholder values
- Validate and sanitize external input at system boundaries
- Use parameterized queries for database access

## Documentation

- Update docs when changing user-facing behavior
- Document non-obvious design decisions inline
- Keep READMEs current with setup and usage instructions
