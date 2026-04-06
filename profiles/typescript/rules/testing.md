---
description: Testing conventions for TypeScript projects (vitest/jest)
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/*.test.tsx"
  - "**/*.spec.tsx"
  - "**/*.test.js"
  - "**/*.spec.js"
---

# Testing Conventions (vitest / jest)

## File Organization
- Test files co-located with source: `foo.ts` → `foo.test.ts`
- Use `describe` blocks to group related tests for the same unit
- One `describe` per exported function or class is a good default

## Naming
- `describe('functionName', ...)` — name the unit under test
- `it('should <behavior> when <condition>', ...)` — describe observable behavior

## Mocking
- Use `vi.fn()` (vitest) or `jest.fn()` for mock functions
- Mock at the module boundary — don't mock internal helper functions
- Prefer dependency injection over module-level mocking when possible
- Always restore mocks: use `afterEach(() => vi.restoreAllMocks())`

## Assertions
- Use `expect(...).toEqual(...)` for deep equality, `toBe` for reference/primitive equality
- For async: `await expect(promise).resolves.toEqual(...)` over `expect(await promise).toEqual(...)`
- Test one behavior per `it` block — avoid testing multiple independent behaviors together
