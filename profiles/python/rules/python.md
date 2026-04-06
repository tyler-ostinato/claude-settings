---
description: Python code conventions for .py files
paths:
  - "**/*.py"
---

# Python Conventions

## Type Hints
- Add type hints to all new functions: parameters and return type
- Use `from __future__ import annotations` for forward references
- Prefer `X | None` over `Optional[X]` (Python 3.10+)
- Use `TypeAlias` for complex type aliases

## Standard Library Preferences
- `pathlib.Path` over `os.path` for file operations
- `logging` over `print` for anything that isn't intentional user-facing output
- `dataclasses.dataclass` or Pydantic `BaseModel` for structured data over raw dicts
- `contextlib.suppress` over bare `except: pass`

## Code Style
- Ruff handles formatting — don't manually reformat
- Maximum line length: 88 characters (ruff default)
- Imports are auto-sorted by ruff (isort-compatible)
- Prefer f-strings over `.format()` or `%` formatting

## Error Handling
- Catch specific exceptions, not bare `except:`
- Re-raise with context: `raise NewError("msg") from original_err`
- Don't swallow exceptions silently unless intentional (use `logging.debug` at minimum)
