# Project Instructions

## Toolchain
- **Format + lint**: `ruff` (replaces black, isort, flake8)
- **Tests**: `pytest`
- **Type checking**: `mypy` (when configured)
- **Package management**: prefer `uv` when `uv.lock` is present, otherwise `pip`

## Development Workflow
- Virtual environment is expected at `.venv/` — activate before running anything if not using `uv run`
- Run `pytest` before finishing any task that touches logic
- Run `ruff check .` to verify no lint errors before considering work done
- Use `uv add <pkg>` / `pip install <pkg>` to add dependencies; always update lockfile

## Project Layout
Standard Python layout expected:
```
src/<package>/   or   <package>/   — source code
tests/                              — test files (mirrors source structure)
pyproject.toml                      — project metadata, ruff + pytest config
```
