---
description: Run linters and auto-fix
agent: build
---

Detect the project type and run the appropriate linters with auto-fix enabled.

Steps:
1. Identify the project type and available linters
2. Run linters with auto-fix where supported:
   - Python: ruff check --fix && ruff format
   - JavaScript/TypeScript: eslint --fix && prettier --write
   - Rust: cargo clippy --fix && cargo fmt
   - Go: golangci-lint run --fix && gofmt -w
   - Shell: shellcheck (report only, no auto-fix)
3. Summarize: files checked, issues found, issues auto-fixed, remaining issues
