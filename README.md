# flutter_game_framework

An internal Flutter package containing reusable game-domain models, services,
and widgets used by Routina and related Glitch9 projects.

This package was split from `flutter_corelib` so game-specific code can evolve
without expanding the general-purpose core library.

## Usage

The package exposes one supported public entry point:

```dart
import 'package:flutter_game_framework/flutter_game_framework.dart';
```

Avoid importing files below `lib/src` directly. Add a symbol to
`lib/flutter_game_framework.dart` when it needs to become part of the public
API.

## Package structure

```text
lib/
├── flutter_game_framework.dart      # Public API
└── src/                             # Internal implementation
    ├── core/                        # Cross-feature foundations
    │   ├── enums/
    │   ├── errors/
    │   └── localization/
    ├── features/                    # Feature-first game modules
    │   ├── game_content/
    │   ├── game_item/
    │   ├── game_shop/
    │   │   ├── controllers/
    │   │   ├── models/
    │   │   └── widgets/
    │   ├── loading/
    │   └── unlocking/
    └── shared/                      # Reusable models and widgets
        ├── models/
        └── widgets/
```

### Placement rules

- Put code owned by one feature under `src/features/<feature>`.
- Keep cross-feature infrastructure in `src/core`.
- Put generic reusable value objects and UI in `src/shared`.
- Use relative imports between internal files.
- Export only intentionally supported APIs from `flutter_game_framework.dart`.
- Split a feature into `models`, `controllers`, or `widgets` only when the
  feature is large enough to benefit from those boundaries.

## Development

From this directory, run:

```shell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The package is private (`publish_to: none`) and currently depends on sibling
Glitch9 packages through local path dependencies.
