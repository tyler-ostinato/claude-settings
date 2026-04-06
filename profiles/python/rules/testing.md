---
description: pytest testing conventions
paths:
  - "**/test_*.py"
  - "**/*_test.py"
  - "**/conftest.py"
---

# Testing Conventions (pytest)

## Naming
- Test files: `test_<module>.py` mirroring the source module name
- Test functions: `test_<what>_<condition>_<expected_outcome>`
  - e.g. `test_parse_empty_string_returns_none`

## Structure
- Use `pytest.fixture` for shared setup; avoid module-level mutable globals
- Group related tests in a class only when they share fixtures or have clear conceptual grouping
- One logical assertion concept per test — multiple `assert` lines are fine if they all test one thing
- Use `conftest.py` for fixtures shared across multiple test files

## Markers
- `@pytest.mark.slow` — for tests that take >1 second
- `@pytest.mark.integration` — for tests that hit real databases, APIs, or filesystems
- `@pytest.mark.parametrize` — prefer over copy-pasted test functions

## Mocking
- Mock at the boundary of your system, not internal implementation details
- Prefer real objects over mocks for internal code (don't mock what you own)
- Use `unittest.mock.patch` as a context manager or decorator, not `start()`/`stop()`

## Assertions
- Use plain `assert` (pytest rewrites these for useful output)
- Avoid `assertTrue`/`assertEqual` — they come from unittest and give worse output
