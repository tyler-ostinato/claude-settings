# Project Instructions

## Toolchain
- **Format**: `prettier`
- **Lint**: `eslint`
- **Tests**: `vitest` (preferred) or `jest`
- **Type checking**: `tsc --noEmit`
- **Package manager**: detect from lockfile (`package-lock.json` → npm, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm)

## Development Workflow
- Always use strict TypeScript — `"strict": true` in `tsconfig.json`
- Run type check before finishing: `npx tsc --noEmit`
- Run tests before finishing: `npm test` or `npx vitest run`
- Check for lint errors: `npx eslint .`

## Project Layout
Standard layout expected:
```
src/          — source files
src/**/*.test.ts  or  src/**/*.spec.ts  — test files co-located with source
tsconfig.json — TypeScript config (strict: true required)
package.json  — project metadata and scripts
```
