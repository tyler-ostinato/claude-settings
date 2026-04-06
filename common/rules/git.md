---
description: Git commit and branching conventions — always loaded
---

# Git Conventions

## Commit Messages
Use Conventional Commits format: `<type>: <subject>`

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`

- Subject line ≤72 characters, imperative mood ("Add feature" not "Added feature")
- No period at the end of the subject
- Body (optional): explain *why*, not *what* — the diff shows what

Examples:
```
feat: add user authentication via OAuth2
fix: prevent crash when config file is missing
test: add coverage for edge cases in parser
```

## Branching
- Never commit directly to `main` or `master`
- Branch naming: `<type>/<short-description>` (e.g. `feat/user-auth`, `fix/null-crash`)

## Commit Scope
- Include test changes in the same commit as the feature or fix they cover
- Keep commits focused — one logical change per commit
- If a commit message needs "and" to describe it, consider splitting it
