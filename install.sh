#!/usr/bin/env bash
# install.sh — Install a Claude Code profile and/or commands into a target project
#
# Usage:
#   ./install.sh [--profile <default|python|typescript|java>] [--commands [name,...]] [target-dir]
#   ./install.sh                                # installs default profile into current directory
#   ./install.sh --profile python               # installs python profile into current directory
#   ./install.sh --commands                     # installs all commands into current directory
#   ./install.sh --commands github              # installs only the 'github' command
#   ./install.sh --profile python --commands    # installs profile + all commands
#   ./install.sh --profile java ~/myproject --force  # overwrite existing files
#
# Options:
#   --profile   Profile to install (default: "default"): default, python, typescript, java
#   --commands  Install slash commands into .claude/commands/ (optional comma-separated list)
#   --force     Overwrite existing files (default: skip existing)
#   --help      Show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALID_PROFILES=("default" "python" "typescript" "java")

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
PROFILE=""
TARGET="."
FORCE=false
INSTALL_COMMANDS=false
COMMANDS_FILTER=""  # empty = all; comma-separated names = specific commands

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --commands)
      INSTALL_COMMANDS=true
      # Optional next arg: comma-separated command names (not a path or existing dir)
      if [[ $# -gt 1 && "$2" != -* && "$2" != /* && "$2" != ./* && "$2" != ~* && "$2" != "." && "$2" != ".." && ! -d "$2" ]]; then
        COMMANDS_FILTER="$2"
        shift
      fi
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --help|-h)
      head -17 "$0" | grep '^#' | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

# Default: install profile if no explicit flags were set
if [[ -z "$PROFILE" && "$INSTALL_COMMANDS" == false ]]; then
  PROFILE="default"
elif [[ -z "$PROFILE" && "$INSTALL_COMMANDS" == true ]]; then
  : # commands-only mode; no profile install
fi

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
if [[ -n "$PROFILE" ]]; then
  valid=false
  for p in "${VALID_PROFILES[@]}"; do
    [[ "$PROFILE" == "$p" ]] && valid=true && break
  done
  if [[ "$valid" == false ]]; then
    echo "Error: unknown profile '$PROFILE'. Valid options: ${VALID_PROFILES[*]}" >&2
    exit 1
  fi
fi

PROFILE_DIR="$SCRIPT_DIR/profiles/${PROFILE:-}"
COMMON_DIR="$SCRIPT_DIR/common"
COMMANDS_DIR="$SCRIPT_DIR/commands"

if [[ -n "$PROFILE" && ! -d "$PROFILE_DIR" ]]; then
  echo "Error: profile directory not found: $PROFILE_DIR" >&2
  exit 1
fi

if [[ "$INSTALL_COMMANDS" == true && ! -d "$COMMANDS_DIR" ]]; then
  echo "Error: commands directory not found: $COMMANDS_DIR" >&2
  exit 1
fi

TARGET="$(realpath "$TARGET")"
if [[ ! -d "$TARGET" ]]; then
  echo "Error: target directory does not exist: $TARGET" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
COPIED=()
SKIPPED=()
OFFERED=()

copy_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [[ -f "$dest" ]] && [[ "$FORCE" == false ]]; then
    SKIPPED+=("${dest#$TARGET/}")
    return
  fi
  cp "$src" "$dest"
  COPIED+=("${dest#$TARGET/}")
}

copy_dir() {
  local src_dir="$1"
  local dest_dir="$2"
  [[ -d "$src_dir" ]] || return 0

  while IFS= read -r -d '' src_file; do
    local rel="${src_file#$src_dir/}"
    copy_file "$src_file" "$dest_dir/$rel"
  done < <(find "$src_dir" -type f -print0)
}

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------
CLAUDE_DIR="$TARGET/.claude"

if [[ -n "$PROFILE" ]]; then
  echo "Installing Claude Code profile: $PROFILE → $TARGET"
  echo ""

  mkdir -p "$CLAUDE_DIR/rules"

  # 1. Common rules (git.md etc.)
  copy_dir "$COMMON_DIR/rules" "$CLAUDE_DIR/rules"

  # 2. Profile settings.json
  copy_file "$PROFILE_DIR/settings.json" "$CLAUDE_DIR/settings.json"

  # 3. Profile CLAUDE.md
  copy_file "$PROFILE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

  # 4. Profile rules/
  copy_dir "$PROFILE_DIR/rules" "$CLAUDE_DIR/rules"

  # 5. Templates — offer to copy if target file doesn't exist
  if [[ -d "$PROFILE_DIR/templates" ]]; then
    while IFS= read -r -d '' src_file; do
      local_name="$(basename "$src_file")"
      dest_file="$TARGET/$local_name"
      if [[ ! -f "$dest_file" ]]; then
        read -r -p "  Copy template '$local_name' to project root? [y/N] " yn || yn=""
        case "$yn" in
          [Yy]*)
            cp "$src_file" "$dest_file"
            OFFERED+=("$local_name (copied)")
            ;;
          *)
            OFFERED+=("$local_name (skipped)")
            ;;
        esac
      fi
    done < <(find "$PROFILE_DIR/templates" -type f -print0)
  fi
fi

# 6. Commands → .claude/commands/
if [[ "$INSTALL_COMMANDS" == true ]]; then
  echo "Installing commands → $TARGET/.claude/commands/"
  echo ""

  mkdir -p "$CLAUDE_DIR/commands"

  if [[ -z "$COMMANDS_FILTER" ]]; then
    # Install all commands
    while IFS= read -r -d '' src_file; do
      cmd_name="$(basename "$src_file")"
      copy_file "$src_file" "$CLAUDE_DIR/commands/$cmd_name"
    done < <(find "$COMMANDS_DIR" -maxdepth 1 -name "*.md" -print0 | sort -z)
  else
    # Install only named commands
    IFS=',' read -ra CMD_NAMES <<< "$COMMANDS_FILTER"
    for name in "${CMD_NAMES[@]}"; do
      name="${name// /}"  # trim spaces
      src_file="$COMMANDS_DIR/${name}.md"
      if [[ ! -f "$src_file" ]]; then
        echo "  Warning: command '$name' not found at $src_file — skipping" >&2
        continue
      fi
      copy_file "$src_file" "$CLAUDE_DIR/commands/${name}.md"
    done
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "Done."
echo ""

if [[ ${#COPIED[@]} -gt 0 ]]; then
  echo "  Copied  (${#COPIED[@]}):"
  for f in "${COPIED[@]}"; do echo "    + $f"; done
fi

if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo "  Skipped (${#SKIPPED[@]}) — already exist (use --force to overwrite):"
  for f in "${SKIPPED[@]}"; do echo "    ~ $f"; done
fi

if [[ ${#OFFERED[@]} -gt 0 ]]; then
  echo "  Templates:"
  for f in "${OFFERED[@]}"; do echo "    • $f"; done
fi

echo ""
echo "Next steps:"
echo "  1. Open '$TARGET' in Claude Code"
if [[ -n "$PROFILE" ]]; then
  echo "  2. Run /hooks to confirm the PostToolUse hook is active"
  echo "  3. Run /permissions to confirm allowed commands"
  echo "  4. Run /memory to confirm CLAUDE.md and rules loaded"
fi
if [[ "$INSTALL_COMMANDS" == true ]]; then
  echo "  • Commands are available as slash commands — e.g. /github"
  echo "    Run /help to see all available commands"
fi
