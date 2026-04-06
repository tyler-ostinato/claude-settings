---
description: Java testing conventions (JUnit 5 + AssertJ)
paths:
  - "**/Test*.java"
  - "**/*Test.java"
  - "**/*Tests.java"
  - "**/*IT.java"
---

# Testing Conventions (JUnit 5 + AssertJ)

## Naming
- Test class: `<SourceClass>Test` in the same package under `src/test/java/`
- Test method: `<methodName>_<condition>_<expectedOutcome>` (camelCase)
  - e.g. `parse_emptyString_throwsIllegalArgument`

## Annotations
- `@Test` — basic test
- `@BeforeEach` / `@AfterEach` — per-test setup/teardown (prefer over `@BeforeAll`)
- `@ParameterizedTest` + `@MethodSource` — prefer over copy-pasted test methods
- `@DisplayName` — use for complex scenarios where the method name isn't clear enough

## Assertions
- Use AssertJ (`assertThat(...)`) over JUnit's `Assertions.assertEquals(...)`:
  ```java
  assertThat(result).isEqualTo(expected);
  assertThat(list).hasSize(3).containsExactly(a, b, c);
  assertThatThrownBy(() -> sut.method()).isInstanceOf(IllegalArgumentException.class);
  ```

## Mocking
- Use Mockito for mocking external dependencies
- Mock at the boundary — don't mock the class under test
- Prefer `@ExtendWith(MockitoExtension.class)` over `MockitoAnnotations.openMocks(this)`

## Integration Tests
- Suffix with `IT` (e.g. `UserRepositoryIT`) to distinguish from unit tests
- Keep integration tests in a separate Maven/Gradle lifecycle phase
