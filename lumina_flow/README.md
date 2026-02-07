# Lumina Flow

A cross-platform productivity application combining Kanban-style task management with daily ritual tracking.

## Features

- **Kanban Board**: Horizontal-scrolling task management similar to Trello
- **Daily Rituals**: Persistent sidebar checklist for recurring daily tasks
- **Dual-Mode UI**: Vibrant glassmorphism mode and E-reader friendly high-contrast mode
- **Cross-Platform**: Native performance on macOS, iOS, Linux desktop, and Linux mobile
- **Local-First**: Offline-first data storage with optional sync capabilities

## Technical Stack

- **Framework**: Flutter 3.10+
- **Database**: Hive for local storage
- **State Management**: Provider + Riverpod
- **Desktop Integration**: window_manager, system_tray
- **UI**: Material 3 with custom glassmorphism effects

## Usage

For detailed instructions on how to use Lumina Flow, including the Kanban board, daily rituals, theme modes, and troubleshooting, see the [USAGE.md](USAGE.md) guide.

## Installation

### Prerequisites

- Flutter SDK 3.10.0 or higher
- For desktop builds: Platform-specific development tools

### Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate model adapters:
   ```bash
   flutter packages pub run build_runner build
   ```

## Development

### Build Commands

```bash
# Development
flutter run                    # Run in debug mode
flutter run --release         # Run in release mode

# Platform-specific builds
flutter build macos           # macOS app
flutter build linux           # Linux executable
flutter build apk             # Android APK
flutter build ios             # iOS app

# Testing
flutter test                  # Run all tests
flutter test test/unit_test.dart  # Run specific test
```

### Linting and Code Quality

```bash
# Lint code
flutter analyze

# Format code
dart format .

# Generate code (models, etc.)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── models/          # Data models (Task, Ritual, Board)
├── services/        # Business logic and state management
├── screens/         # UI screens
├── widgets/         # Reusable UI components
├── themes/          # App theming and styling
└── utils/           # Utility functions
```

## Code Style Guidelines

### Import Style
- Use `flutter/material.dart` first
- Group imports: external, internal, relative
- Use relative imports for files within lib/
- Sort imports alphabetically

### Formatting
- Use 2-space indentation
- Maximum line length: 80 characters
- Use trailing commas for multi-line parameters
- Use single quotes for strings

### Type Annotations
- Always type function parameters and return values
- Use explicit types for public APIs
- Use `var` for local variables with inferred types

### Naming Conventions
- Variables: `camelCase`
- Functions: `camelCase`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Files: `snake_case.dart`
- Directories: `snake_case`

### Error Handling
- Use try-catch blocks for async operations
- Log errors appropriately without exposing sensitive data
- Provide user-friendly error messages
- Use proper error propagation patterns

## Testing

- Write unit tests for all service classes
- Use descriptive test names following `describe...when...should` pattern
- Mock external dependencies
- Test edge cases and error conditions
- Maintain test coverage above 80%

## Platform Integration

### macOS Features
- Menu bar integration via window_manager
- Always-on-top floating window mode
- Native system tray support

### Linux Features
- AppImage build support
- Flatpak packaging ready
- System tray integration
- Desktop notifications

### Mobile Support
- Responsive design for mobile screens
- Touch-optimized interactions
- Offline-first architecture

## Sync Architecture

The app uses a local-first approach:
1. All data stored locally in Hive database
2. Real-time sync available via PowerSync/Supabase (implementation planned)
3. Conflict resolution handled automatically
4. Offline capability with queue-and-retry pattern

## Build & Distribution

### macOS
```bash
flutter build macos --release
# Creates .app bundle in build/macos/Build/Products/Release/
```

### Linux
```bash
flutter build linux --release
# Creates executable in build/linux/x64/release/bundle/
```

### AppImage Generation
```bash
# Using linuxdeploy
./linuxdeploy-x86_64.AppImage --appdir AppDir --executable lumina_flow --create-desktop-file --output appimage
```

## Contributing

1. Fork the repository
2. Create a feature branch from main
3. Make changes with descriptive commits
4. Run linting and tests locally
5. Submit pull request for review

## License

MIT License - see LICENSE file for details.