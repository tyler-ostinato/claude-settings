# claude-settings

Portable Claude Code configuration profiles and slash command skills. Drop them into any project to get sensible defaults for formatting, linting, testing, and git conventions — enforced via Claude Code hooks.

## Quick Install

```bash
# Clone once
git clone https://github.com/your-username/claude-settings ~/.claude-settings

# Install a profile into any project
~/.claude-settings/install.sh --profile python /path/to/your/project
~/.claude-settings/install.sh --profile typescript .
~/.claude-settings/install.sh --profile java ~/myapp

# Install slash commands into any project
~/.claude-settings/install.sh --commands .
~/.claude-settings/install.sh --commands github .          # specific command
~/.claude-settings/install.sh --commands github,another .  # multiple commands

# Install profile + commands together
~/.claude-settings/install.sh --profile python --commands ~/myapp
```

## Profiles

| Profile | Formatter | Linter | Test runner |
|---------|-----------|--------|-------------|
| `python` | ruff format | ruff check | pytest |
| `typescript` | prettier | eslint | vitest / jest |
| `java` | google-java-format | — | JUnit 5 |

All profiles include:
- **PostToolUse hooks** that auto-format files after Claude edits them
- **Pre-approved commands** so Claude isn't blocked mid-task
- **Rules** for language conventions and testing patterns
- **git.md** — conventional commits and branching rules

## Commands (Slash Commands)

Commands are reusable Claude Code slash commands installed into `.claude/commands/`. Once installed, invoke them with `/<name>` inside Claude Code.

| Command | What it does |
|---------|-------------|
| `/github` | Audit changed files for sensitive data, stage safe files, create a feature branch, write a commit, push, open a PR, and launch it in the browser |

### `/github` workflow

1. Runs `git status` and lists every changed file
2. Flags **sensitive files** (`.env`, `*.key`, credentials, DBs, etc.) and asks before staging any
3. Silently skips **noise** (`node_modules/`, `__pycache__/`, `dist/`, `.DS_Store`, etc.)
4. Stages safe files individually — never `git add .`
5. Creates a `feat/` or `fix/` feature branch with a kebab-case name
6. Writes a Conventional Commits message (imperative, ≤72 chars)
7. Pushes the branch and creates a PR via `gh pr create`
8. Opens the PR in your browser with `gh pr view --web`

Requires the [GitHub CLI (`gh`)](https://cli.github.com/) to be installed and authenticated.

## What Gets Installed

```
your-project/
└── .claude/
    ├── settings.json      ← hooks + permissions       (profile)
    ├── CLAUDE.md          ← toolchain + workflow       (profile)
    ├── rules/
    │   ├── git.md         ← conventional commits       (all profiles)
    │   ├── <lang>.md      ← language conventions       (path-gated)
    │   └── testing.md     ← test conventions           (path-gated)
    └── commands/
        └── github.md      ← /github slash command      (commands)
```

## Options

```
./install.sh [--profile <name>] [--commands [name,...]] [target-dir] [--force]

  --profile   Profile to install: default | python | typescript | java
  --commands  Install slash commands into .claude/commands/
              Optionally pass a comma-separated list to install specific commands
  --force     Overwrite existing files (default: skip)
  --help      Show usage
```

## Verify After Install

Open the project in Claude Code and run:
- `/hooks` — confirm PostToolUse hook is active
- `/permissions` — confirm language commands are pre-allowed
- `/memory` — confirm CLAUDE.md and rules loaded
- `/help` — see all available slash commands (including installed commands)

## Templates

Some profiles include optional config file starters in `templates/`. The install script offers to copy these to the project root if they don't already exist:

- `python` → `pyproject.toml` (ruff + pytest configured)
- `typescript` → `.eslintrc.json` (strict TypeScript rules)

## Adding a Profile or Skill

See [CLAUDE.md](CLAUDE.md) for instructions.
