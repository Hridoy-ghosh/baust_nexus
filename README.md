# BAUST Nexus

BAUST Nexus is a Flutter smart-campus companion app for students, teachers, guests, and campus administrators. It brings academic resources and common campus services together in one app.

## Features

- Student, teacher, and administrator sign-in and registration
- Guest access to public campus information
- Academic resources and notices
- Library, transport, and cafeteria information
- Cafe and library administration screens
- CGPA calculator and progress tracker
- Query board and user profile

## Requirements

- Flutter SDK compatible with Dart 3.4 or later
- A configured Supabase project for backend services
- An Android, iOS, web, Windows, macOS, or Linux development target supported by Flutter

## Getting Started

1. Install Flutter and verify your setup:

   ```bash
   flutter doctor
   ```

2. From this directory, fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Configure the Supabase project connection for the app before running it. Use your project's Supabase URL and public anon key; do not put a Supabase service-role key in a client app.

4. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

## Validation

Run the static analyzer and widget tests with:

```bash
flutter analyze
flutter test
```

## Project Layout

- `lib/config/` — app constants, colors, and themes
- `lib/models/` — data models
- `lib/screens/` — app screens
- `lib/services/` — backend and application services
- `lib/utils/` — shared utilities
- `lib/widgets/` — reusable UI components
- `assets/` — app icons and images
- `test/` — Flutter tests

## Related Backend

The Laravel backend is maintained in the sibling `../baust_nexus_laravel` project.
