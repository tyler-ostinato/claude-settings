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
./install.sh --commands /tmp/test-project                     # commands only
./install.sh --profile python --commands /tmp/test-project    # profile + commands
./install.sh --commands github /tmp/test-project              # single command
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
- `commands/` — slash commands installed into `.claude/commands/` in target projects
- `install.sh` — copies a profile's `.claude/` and/or commands into a target project

## Adding a New Profile

1. Create `profiles/<name>/settings.json` (hooks + permissions)
2. Create `profiles/<name>/CLAUDE.md` (toolchain + workflow)
3. Create `profiles/<name>/rules/<topic>.md` (add `paths:` frontmatter for path-gating)
4. Optionally add `profiles/<name>/templates/` for config file starters
5. Add the profile name to `VALID_PROFILES` in `install.sh`

## Commands (Slash Commands)

Commands are markdown files in `commands/` that get installed as custom Claude Code slash commands under `.claude/commands/` in the target project. Once installed, invoke them with `/<name>` inside Claude Code.

**Install all commands:**
```bash
./install.sh --commands /path/to/project
```

**Install specific commands:**
```bash
./install.sh --commands github /path/to/project
./install.sh --commands github,another /path/to/project
```

**Combine with a profile:**
```bash
./install.sh --profile python --commands ~/myproject
```

**Adding a new command:**
1. Create `commands/<name>.md` with a frontmatter `description:` field
2. Write the prompt — this is what Claude receives when the user runs `/<name>`
3. No changes to `install.sh` needed — all `commands/*.md` files are auto-discovered

### Available Commands

| Command | Description |
|---------|-------------|
| `/github` | Stage safe files, create a feature branch, commit, push, and open a PR |
| `/new-app` | Scaffold a new app for a local kind cluster (namespace, deployment, service, justfile, secrets, PVC, deploy-apps registration) |
