---
name: feature-expert
description: Feature composition, screen structure, BLoC-UI integration, and navigation wiring. LOAD ONLY WHEN building new feature screens from scratch or heavily refactoring existing feature architecture and BLoC-UI wiring. DO NOT LOAD for minor UI tweaks, layout adjustments, or small bug fixes (rely on existing code context instead).
---

## Feature Composition Guidelines

### 1. Core Directives
Priority: These rules override generic composition recommendations.
- Screen = Provider shell: `<Feature>Screen` is strictly a `BlocProvider` wrapper. It injects UseCases and the `<Feature>Navigator`, dispatches the initial event, and renders `<Feature>Content`. No UI logic here.
- Content = UI root: `<Feature>Content` is where all widget composition lives. It consumes the BLoC via `BlocBuilder`/`BlocListener`.
- Navigation authority: Features never call navigator using context. Send BLoC event to trigger the navigation. Dialogs and bottom-sheets follow the same principle.
- Dependency direction: Features NEVER depend on the `navigation` package or on other features. `navigation` depends on features and implements their `<Feature>Navigator` interfaces.
- Exception mapping: User-facing error strings live in `feature/lib/src/misc/exception_mappers.dart`. NEVER hardcode error strings in widgets or BLoCs.

### 2. Feature Structure
Determine if the feature is Single-Screen or Multi-Screen based on requirements.

Single-screen:
```text
lib/src/
├── screen/        # <feature>_screen.dart + <feature>_content.dart
├── bloc/          # FeatureBloc, FeatureEvent, FeatureState
├── navigation/    # <feature>_navigator.dart (FeatureNavigator interface)
├── misc/          # Exception mappers, extensions
└── widgets/       # (Optional) Feature-specific widgets
```

Multi-screen:
```text
lib/src/
├── <subfeature_A>/  # screen/, bloc/, misc/, widgets/
├── <subfeature_B>/  # screen/, bloc/, misc/, widgets/
├── navigation/      # One <feature>_navigator.dart for the whole feature
└── shared/          # (Optional) Shared across subfeatures within this feature only
```

Public API (barrel):
Each feature exposes a top-level `lib/<feature>.dart` that exports the generated routes and the navigator interface, and defines the feature's route configuration.

```dart
// ===== lib/home.dart =====
import 'package:auto_route/auto_route.dart';

import 'home.gr.dart';

export 'home.gr.dart';
export 'src/navigation/home_navigator.dart';

@AutoRouterConfig()
class HomeRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(initial: true, page: HomeRoute.page),
  ];
}
```
This is the feature's only public surface. The `navigation` package imports this file. Do not export individual widgets, BLoCs, or internal files.

### 3. Screen Composition

```dart
// ===== feature_screen.dart =====
@RoutePage()
class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeatureBloc>(
      create: (context) => FeatureBloc(
        featureUseCase: context.resolve<FeatureUseCase>(),
        navigator: context.resolve<FeatureNavigator>(),
      )..add(const LoadEvent()),
      child: const FeatureContent(),
    );
  }
}
```
- DI: Resolve UseCases and `<Feature>Navigator` via `context.resolve<T>()`. NEVER inject Repositories or `AppRouter`.
- Initial load: Dispatch via cascade `..add(const LoadEvent())` in `BlocProvider.create`.
- Provider scope: Create `BlocProvider` at the Screen level, never in child widgets. One BLoC per screen. Multi-screen features give each screen its own BLoC.
- SafeArea: `<Feature>Content` root must be wrapped in `SafeArea` unless the design explicitly overrides.

### 4. BLoC Consumption
- Rendering: Use `BlocBuilder` inside `<Feature>Content`.
- Side effects: Use `BlocListener` ONLY for one-time UI side-effects that are not navigation. Navigation, dialogs, and bottom-sheets are handled by the BLoC via `_navigator`.
- BlocBuilder grouping: Use semi-aggressive grouping. Group widgets by shared `buildWhen` predicate. One builder for simple screens. Never wrap individual widgets.
- `buildWhen`: Include when the state contains multiple independent fields or collections. For simple states the default equality check is sufficient. Do not add `buildWhen` reflexively.
- Static above reactive: Place static widgets (titles, spacers, decorative icons) outside `BlocBuilder`. Only state-dependent widgets belong inside `builder`.
- Form scrolling: Screens with `TextField` require `SingleChildScrollView` with `keyboardDismissBehavior: onDrag`. Exception: static center-aligned screens (splash, simple error).
- Keyboard wiring: Wire `TextInputAction.done` to form submit via `onFieldSubmitted`. Manage focus between fields via `FocusNode`.
- Form controllers: `TextEditingController`s live strictly in the UI. Initialize them in `initState` and ALWAYS `dispose()` them. NEVER put controllers in the BLoC.

### 5. Exception Mapping

```dart
// ===== feature/lib/src/misc/exception_mappers.dart =====
class FeatureExceptionMapper {
  static String map(Exception error, AppTranslations t) => switch (error) {
    UserNotFoundException() => t.errors.userNotFound,
    _ => t.errors.unknown,
  };
}
```
Map domain exceptions to localized strings. Pass `AppTranslations` from the widget layer. NEVER hardcode user-facing strings.

### 6. Navigation Wiring
BLoCs own navigation through the feature's `<Feature>Navigator`. The UI NEVER initiates navigation.
- NEVER use `Navigator`, `context.push`, or `context.pop` in UI or BLoC.
- Dialogs and bottom-sheets are standalone routes. The BLoC opens them via an intent-named navigator method (e.g., `_navigator.confirmDelete()`).
- NEVER use `showDialog`, `showModalBottomSheet`, or any imperative overlay API in Content.
- Isolation: No bloc-to-bloc communication. Each feature BLoC is independent.

Adding a navigation action:
1. Declare an intent-named method on `<Feature>Navigator` (`feature/lib/src/navigation/<feature>_navigator.dart`).
2. Implement it in `navigation/lib/src/navigators/router_<feature>_navigator.dart` using `AppRouter` (`push` / `navigate` / `replaceAll` / `pop`, see `bloc-expert` §6). Cross-feature targets are resolved here, never in the feature.
3. Register it in `NavigationDI`: `locator.registerLazySingleton<FeatureNavigator>(() => RouterFeatureNavigator(appRouter: locator<AppRouter>()))`.

Adding a new feature: spread `<Feature>Router().routes` into `AppRouter.routes`, add the feature to `navigation/pubspec.yaml`, and register its navigator as above.

### 7. Widget Usage
When consuming `App*` widgets inside feature screens:
- Use `AppText`, `AppImage`, `AppIcon` — never raw `Text`, `Image`, `Icon`.
- Don't wrap `App*` widgets in `Semantics` — they own their a11y.
- Use semantic tokens: `context.appColors`, `context.appTexts`, `AppDimens`, `AppMotions`.
- Interactable `App*` widgets expose `isEnabled` — use it, don't reinvent.
- Pass localized strings via `context.translations.<key>`, not hardcoded literals.

### 8. Common Mistakes
- `BlocBuilder` per widget → group by shared `buildWhen` predicate.
- Static widget inside `BlocBuilder` → move outside the builder.
- `SingleChildScrollView` without `keyboardDismissBehavior` → add `onDrag`.
- `TextInputAction.done` without `onFieldSubmitted` → wire to form submit.
- `TextEditingController` in BLoC → move to UI widget and ensure `dispose()` is called.
- `Navigator.push(...)` or `Navigator.pop(...)` in screen → use `_navigator` in BLoC.
- `AppRouter` / `package:navigation` imported in a feature → declare a `<Feature>Navigator` method instead.
- Hardcoded error string in widget → use `ExceptionMapper` in `misc/`.
- `BlocProvider` in child widget → move to `<Feature>Screen`.
- Repository injection in BLoC → inject UseCase instead.
- `showDialog(...)` / `showModalBottomSheet(...)` in Content → route via a `_navigator` method in BLoC.

### 9. Strict Guardrails (NEVER DO)
❌ `BlocProvider` in child widgets — only in `<Feature>Screen`.
❌ Repository/Data source injection into BLoCs.
❌ Feature depending on the `navigation` package or on another feature.
❌ Hardcoded user-facing strings in widgets or BLoCs.
❌ `BlocBuilder` wrapping individual widgets.
❌ Static widgets inside `BlocBuilder`.
❌ Bloc-to-bloc communication.
❌ `Navigator.push(...)` or `context.pop(...)` in Content → emit a BLoC event.
❌ `showDialog(...)` / `showModalBottomSheet(...)` in Content → emit a BLoC event.
❌ `TextEditingController` in BLoC — they belong strictly in the UI.

### 10. Testing & Auditing
- BLoC tests: Covered by `bloc-expert`. Run `bash scripts/run_bloc_tests.sh`.
- Navigation: Mock `<Feature>Navigator` and verify its methods are called for navigation events. Assert `Navigator` is never used.
- The "Untouchable" Rule: Existing tests are sacred. NEVER modify an existing test to make it pass.

### 11. Post-Implementation
- Run `dart fix --apply` on changed files.
