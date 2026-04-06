# Project Instructions

## Toolchain
- **Format**: `google-java-format` (if installed; hooks auto-run it)
- **Build + test**: detect from project root:
  - `./mvnw` or `mvn` if `pom.xml` present
  - `./gradlew` or `gradle` if `build.gradle` / `build.gradle.kts` present
- **Preferred**: use the wrapper script (`./mvnw`, `./gradlew`) over global installs

## Development Workflow
- Run tests before finishing any logic change: `./mvnw test` or `./gradlew test`
- Standard source layout: `src/main/java/` and `src/test/java/`
- Java version: check `pom.xml` (`<java.version>`) or `build.gradle` (`sourceCompatibility`)

## Style
- Follow Google Java Style Guide
- Formatter runs automatically on file save via hooks — don't manually reformat
