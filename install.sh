#!/usr/bin/env bash
# install.sh — Install a Claude Code profile into a target project
#
# Usage:
#   ./install.sh [--profile <default|python|typescript|java>] [target-dir]
#   ./install.sh                           # installs default profile into current directory
#   ./install.sh --profile python          # installs python profile into current directory
#   ./install.sh --profile java ~/myproject --force  # overwrite existing files
#
# Options:
#   --profile   Profile to install (default: "default"): default, python, typescript, java
#   --force     Overwrite existing files (default: skip existing)
#   --help      Show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALID_PROFILES=("default" "python" "typescript" "java")

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
PROFILE="default"
TARGET="."
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --help|-h)
      head -10 "$0" | grep '^#' | sed 's/^# \{0,1\}//'
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

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
valid=false
for p in "${VALID_PROFILES[@]}"; do
  [[ "$PROFILE" == "$p" ]] && valid=true && break
done
if [[ "$valid" == false ]]; then
  echo "Error: unknown profile '$PROFILE'. Valid options: ${VALID_PROFILES[*]}" >&2
  exit 1
fi

PROFILE_DIR="$SCRIPT_DIR/profiles/$PROFILE"
COMMON_DIR="$SCRIPT_DIR/common"

if [[ ! -d "$PROFILE_DIR" ]]; then
  echo "Error: profile directory not found: $PROFILE_DIR" >&2
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
echo "Installing Claude Code profile: $PROFILE → $TARGET"
echo ""

CLAUDE_DIR="$TARGET/.claude"
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
echo "  2. Run /hooks to confirm the PostToolUse hook is active"
echo "  3. Run /permissions to confirm allowed commands"
echo "  4. Run /memory to confirm CLAUDE.md and rules loaded"
