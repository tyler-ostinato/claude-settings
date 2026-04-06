# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of Claude Code configuration profiles that can be installed into any project. Each profile provides:
- `.claude/settings.json` — pre-approved commands + PostToolUse formatting hooks
- `.claude/CLAUDE.md` — project instructions for Claude
- `.claude/rules/` — path-gated rules (language conventions, testing, git)

## Development in This Repo

No build system — this repo is pure shell and Markdown.

**Test the install script:**
```bash
./install.sh --profile python /tmp/test-project
./install.sh --profile typescript /tmp/test-ts
./install.sh --profile java /tmp/test-java
```

**Validate all settings.json files are valid JSON:**
```bash
jq . profiles/*/settings.json
```

**Re-run install safely (idempotent):**
```bash
./install.sh --profile python /tmp/test-project        # skips existing files
./install.sh --profile python /tmp/test-project --force  # overwrites
```

## Structure

- `common/rules/` — rules copied into every profile (git conventions)
- `profiles/<name>/` — self-contained profile: `settings.json`, `CLAUDE.md`, `rules/`, optional `templates/`
- `install.sh` — copies a profile's `.claude/` into a target project

## Adding a New Profile

1. Create `profiles/<name>/settings.json` (hooks + permissions)
2. Create `profiles/<name>/CLAUDE.md` (toolchain + workflow)
3. Create `profiles/<name>/rules/<topic>.md` (add `paths:` frontmatter for path-gating)
4. Optionally add `profiles/<name>/templates/` for config file starters
5. Add the profile name to `VALID_PROFILES` in `install.sh`
