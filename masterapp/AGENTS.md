# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter app.

- `lib/`: main application code.
  - `main.dart`: app entry point and route setup.
  - `pages/`: UI screens (for example `lib/pages/dashboard/`, `lib/pages/file_manager/`, `lib/pages/project_management/`).
  - `models/`: simple data models (for example `lib/models/project_item.dart`, `lib/models/file_manager_entry.dart`).
  - `services/`: local services/storage helpers (for example `lib/services/project_file_store_io.dart`).
- `test/`: unit/widget tests (`*_test.dart`).
- Platform folders: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`.
- Assets: configure in `pubspec.yaml` under `flutter/assets` when added.

## Build, Test, and Development Commands

Run from repo root:

```powershell
flutter pub get        # install dependencies
flutter run            # run locally (choose device)
flutter test           # run all tests in /test
flutter analyze        # static analysis (flutter_lints)
flutter build apk      # example release build
```

## Coding Style & Naming Conventions

- Dart/Flutter style with `flutter_lints` (`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`).
- Indentation: 2 spaces (default Dart formatting).
- Naming:
  - Files/folders: `snake_case.dart`
  - Types/widgets: `PascalCase`
  - Variables/methods: `lowerCamelCase`
- Prefer ASCII in source strings and UI separators; avoid weird encoding characters (use `-` instead of fancy bullets).

## Testing Guidelines

- Tests live in `test/` and should be named `something_test.dart`.
- Prefer widget tests for screens in `lib/pages/**` and unit tests for pure logic in `lib/models/**` and `lib/services/**`.
- Minimum bar: new features/bugfixes should include at least one focused test when behavior is non-trivial.

## Commit & Pull Request Guidelines

Commit messages in this repo commonly use a date prefix and a short slug, e.g.:

- `250326/perbaiki_tampilan_halaman_file_manager`
- `120326/membuat_tampilan_file_manager`

Guidelines:

- Use `DDMMYY/short_description` (lowercase, `_` as separator) or a clear short phrase.
- PRs should include: what changed, where to test (screens/flows), and screenshots for UI changes (before/after if layout changed).

## Configuration Notes

- Avoid committing machine-specific paths.
- When adding packages, update `pubspec.yaml` and keep changes minimal and focused.
