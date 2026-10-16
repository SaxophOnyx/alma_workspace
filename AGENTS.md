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

## Product Specs
Product requirements live in `.agent-docs/`. Read only the file relevant to the task:
- `00_APP_OVERVIEW.md` — concept, three modules (Respirar, Hablar, Leer), cross-module links, permissions, content plan.
- `01_USER_FLOW.md` — navigation map, screen-by-screen layouts, back behavior, empty/edge states.
- `02_COLOR_PALETTE.md` — five-color palette, typography table, breathing point spec, visual prohibitions.
- `03_USE_CASES.md` — six persona scenarios.
- `04_ONBOARDING.md` — four-slide onboarding spec, timings, `onboarding_complete` persistence, Android back behavior.
- `05_features/` — one file per feature (14 features, 47 user stories with Given/When/Then acceptance criteria); `README.md` is the index with priorities.
- `06_UNFINISHED.md` — placeholders and known gaps (Leer seed content, content schemas, pending Hablar links).

Where specs name tech choices that differ from **Stack** above (e.g. `go_router`), the Stack section wins.

## Commands
*(Run from repository root)*
- `bash scripts/prebuild.sh` — pub get + code generation.
- `bash scripts/run_unit_tests.sh` — domain, data tests.
- `bash scripts/run_bloc_tests.sh` — bloc tests.
