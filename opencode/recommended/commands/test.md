---
description: Run project tests with coverage
agent: build
---

Detect the project type and run its test suite with coverage reporting.

Steps:
1. Identify the project type (look for package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
2. Run the appropriate test command with coverage enabled
3. Summarize results: total tests, passed, failed, skipped, coverage percentage
4. If any tests fail, show the failure details
