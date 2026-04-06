---
description: TypeScript code conventions
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
---

# TypeScript Conventions

## Type Safety
- No `any` — use `unknown` and narrow with type guards or `as` only when unavoidable
- No `// @ts-ignore` or `// @ts-expect-error` without an explanatory comment
- Enable and respect `strict: true` in tsconfig

## Type Definitions
- Prefer `interface` over `type` for object shapes (more extensible, better error messages)
- Use `type` for unions, intersections, and aliases of primitives
- Export types separately from values: `export type { Foo }`
- Use `const` assertions (`as const`) for literal type inference

## Patterns
- Prefer `readonly` arrays and properties where mutation isn't needed
- Use optional chaining (`?.`) and nullish coalescing (`??`) over manual null checks
- Avoid class inheritance — prefer composition and interfaces
- Use discriminated unions for state machines and result types over boolean flags

## Imports
- Use `import type` for type-only imports
- Avoid barrel files (`index.ts` re-exporting everything) in large codebases — they hurt tree-shaking
