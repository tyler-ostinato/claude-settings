# claude-settings

Portable Claude Code configuration profiles. Drop them into any project to get sensible defaults for formatting, linting, testing, and git conventions — enforced via Claude Code hooks.

## Quick Install

```bash
# Clone once
git clone https://github.com/your-username/claude-settings ~/.claude-settings

# Install into any project
~/.claude-settings/install.sh --profile python /path/to/your/project
~/.claude-settings/install.sh --profile typescript .
~/.claude-settings/install.sh --profile java ~/myapp
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

## What Gets Installed

```
your-project/
└── .claude/
    ├── settings.json   ← hooks + permissions
    ├── CLAUDE.md       ← toolchain + workflow instructions
    └── rules/
        ├── git.md      ← conventional commits (all profiles)
        ├── <lang>.md   ← language conventions (path-gated)
        └── testing.md  ← test conventions (path-gated)
```

## Options

```
./install.sh --profile <name> [target-dir] [--force]

  --profile   python | typescript | java  (required)
  --force     Overwrite existing files (default: skip)
  --help      Show usage
```

## Verify After Install

Open the project in Claude Code and run:
- `/hooks` — confirm PostToolUse hook is active
- `/permissions` — confirm language commands are pre-allowed
- `/memory` — confirm CLAUDE.md and rules loaded

## Templates

Some profiles include optional config file starters in `templates/`. The install script offers to copy these to the project root if they don't already exist:

- `python` → `pyproject.toml` (ruff + pytest configured)
- `typescript` → `.eslintrc.json` (strict TypeScript rules)

## Adding a Profile

See [CLAUDE.md](CLAUDE.md) for instructions.
