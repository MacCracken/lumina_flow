# Photis Nadi

[![Flutter CI](https://github.com/MacCracken/photisnadi/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MacCracken/photisnadi/actions/workflows/ci.yml)
[![Tests](https://img.shields.io/badge/Tests-26%20passed-green)](https://github.com/yourusername/photisnadi/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

A cross-platform productivity application combining Kanban-style task management with daily ritual tracking.

## Features

- **Kanban Board**: Horizontal-scrolling task management similar to Trello
- **Project Management**: Organize tasks into projects with unique keys (e.g., WK-1, WK-2)
- **Daily Rituals**: Persistent sidebar checklist for recurring daily, weekly, or monthly tasks
- **Dual-Mode UI**: Vibrant glassmorphism mode and E-reader friendly high-contrast mode
- **Cross-Platform**: Native performance on macOS, iOS, Linux desktop, and Linux mobile
- **Local-First**: Offline-first data storage with optional Supabase cloud sync
- **Conflict Resolution**: Last-write-wins sync with `modifiedAt` timestamps

## Quick Start

```bash
# Clone and setup
git clone https://github.com/yourusername/photisnadi.git
cd photisnadi
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run in debug mode
flutter run
```

## Documentation

| Topic | Link |
|-------|------|
| Usage Guide | [USAGE.md](USAGE.md) |
| Data Models | [docs/models.md](docs/models.md) |
| Code Style | [docs/style.md](docs/style.md) |
| Build & Distribution | [docs/distribution.md](docs/distribution.md) |
| Roadmap & TODOs | [docs/todos.md](docs/todos.md) |

## Project Structure

```
photisnadi/
├── lib/
│   ├── models/          # Data models (Task, Ritual, Board, Project)
│   ├── services/        # Business logic and state management
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable UI components
│   ├── themes/          # App theming and styling
│   └── main.dart        # App entry point, Hive initialization
├── docs/                # Detailed documentation
├── test/                # Unit tests
└── .github/workflows/   # CI/CD configuration
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on setting up your development environment, branch strategy, making changes, and submitting pull requests.

## License

MIT License - see [LICENSE](LICENSE) file for details.
