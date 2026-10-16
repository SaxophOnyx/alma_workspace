# AGENTS.md

## Mandatory Directives
- **Ask, don't assume:** If requirements are ambiguous, ask for clarification before writing code.
- **Minimal changes:** Never perform drive-by refactors outside the explicit task scope.

## Discovery Policy
- This workspace has a predictable structure. Check the sections below **before** scanning the repo — they cover most tasks and will save you context.
- Prefer targeted navigation over full repository scans. If you can't locate files using the guides below, scoped searches within relevant packages are acceptable.

## Stack
- `flutter_bloc`
- `auto_route`
- `json_serializable`
- `slang`

## Workspace
Native Dart pub workspace (Dart ^3.12, `resolution: workspace`; no melos). Root `pubspec.yaml` declares all first-party packages.

## Data Flow
Widget → Bloc → UseCase → Repository (contract: `domain`, impl: `data`) → Provider → Entity → Mapper → domain Model.

Errors surface only as `AppException` subclasses.

## Packages
- **`app/`** (`app`): App shell. Entrypoint `lib/src/app/application.dart`; composes all module DI bottom-up.
- **`modules/core/`** (`core`): Base layer: config, DI, `AppException` hierarchy.
- **`modules/domain/`** (`domain`): Models, repository contracts, use cases.
- **`modules/data/`** (`data`): Entities, providers, mappers, repository implementations.
- **`modules/shared_ui/`** (`shared_ui`): Theme (raw + semantic tokens), shared `App*` widgets, assets, slang-generated localization.
- **`modules/navigation/`** (`navigation`): `AppRouter` (auto_route); registers feature routes and implements each feature's `<Feature>Navigator`. Depends on features, never the reverse.
- **`modules/features/`**: Independent app features. Each declares its navigation needs as a `<Feature>Navigator` interface.

## Package Scope Guide
These are the packages typically involved per task type:
- **UI / Theming:** `shared_ui`, `features/*`.
- **Feature logic:** `features/<name>`, `domain`, `shared_ui`.
- **Backend / Data:** `data`, `domain`.
- **App shell / DI:** `app`, `core`.
- **Routing:** `navigation`, target `features/*`.

## Commands
*(Run from repository root)*
- `bash scripts/prebuild.sh` — pub get + code generation.
- `bash scripts/run_unit_tests.sh` — domain, data tests.
- `bash scripts/run_bloc_tests.sh` — bloc tests.
