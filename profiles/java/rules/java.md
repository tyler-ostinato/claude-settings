---
description: Java code conventions
paths:
  - "**/*.java"
---

# Java Conventions

## Immutability
- Prefer `final` fields; make classes `final` unless designed for extension
- Use Java records for simple data carriers (Java 16+)
- Prefer immutable collections: `List.of(...)`, `Map.of(...)`, `Set.of(...)`

## Null Safety
- Use `Optional<T>` at public API boundaries for nullable returns — never return `null` from a public method
- Don't use `Optional` as a field type or method parameter
- Annotate with `@Nullable` / `@NonNull` (Jakarta or Checker Framework) where `Optional` would be excessive

## Design
- Prefer composition over class inheritance
- Use interfaces to define contracts; keep implementations package-private when possible
- Don't introduce Lombok if it's not already in the project — use records or manual accessors

## Error Handling
- Use checked exceptions for recoverable conditions, unchecked for programming errors
- Don't swallow exceptions: log + rethrow or wrap in a domain exception
- Prefer specific exception types over raw `RuntimeException`

## Style
- google-java-format handles formatting automatically
- Wildcard imports are forbidden (`import java.util.*` → explicit imports)
