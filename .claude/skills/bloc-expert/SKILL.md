---
name: bloc-expert
description: Bloc architecture patterns, state management, and guidelines. LOAD ONLY WHEN implementing new BLoCs, events, or states from scratch, or heavily refactoring existing BLoC architecture. DO NOT LOAD for minor bug fixes, small logic tweaks, or simple state updates (rely on existing code context instead).
---

## Bloc Architecture Guidelines

### 1. Core Directives
Priority: These rules override generic Bloc recommendations.
- DI & Injection: Inject `UseCase` and the feature's `<Feature>Navigator` via constructor. Resolve via `context.resolve<T>()`. NEVER inject Repositories or `AppRouter`.
- Provider Scope: Create `BlocProvider` at the Screen level, never in child widgets.
- Initial Load: Dispatch initial events via cascade in `BlocProvider.create`: `..add(const LoadEvent())`.
- Isolation: No bloc-to-bloc communication.
- Navigation: Blocs navigate via the injected `<Feature>Navigator` interface (see §6).

### 2. UseCase Contract
- Every UseCase exposes a single `execute` method.
- Parameters are passed via a dedicated `<UseCase>Params` class, or `const NoParams()` for parameterless use cases.
- A Bloc may receive multiple UseCases via constructor injection if the feature requires distinct operations.

```dart
final result = await _loadFeatureUseCase.execute(const NoParams());
final saved  = await _submitFeatureUseCase.execute(SubmitParams(data: event.data));
```

### 3. Events & Bloc Structure
- Events: `sealed class` base, `final class` concrete. All constructors `const`.
- Handlers: Explicit `on<ConcreteEvent>(_onConcreteEvent)`. NEVER use `on<BaseEvent>()`.
- Post-await guard: After every `await`, before the next `emit(...)`, check `if (isClosed) return;`.
- Rapid-tap protection: Guard with state flags (e.g., `if (state.isLoading) return;`) at the top of the handler. Do NOT rely on `droppable()` for synchronous handlers.
- Transformer selection: The default sequential transformer is correct for most handlers. Do not add a transformer unless the scenario matches one of the following:
    - Async handler (load, save, submit) → State guard (`if (state.isLoading) return;`). No transformer needed.
    - Sync handler with side-effects (navigate, toggle) → State guard. No transformer needed.
    - Search / typeahead streams → `restartable()`.

```dart
// ===== feature_event.dart =====
part of 'feature_bloc.dart';

sealed class FeatureEvent {
  const FeatureEvent();
}

final class LoadEvent extends FeatureEvent {
  const LoadEvent();
}

final class UpdateEvent extends FeatureEvent {
  final String title;
  const UpdateEvent(this.title);
}

final class SubmitEvent extends FeatureEvent {
  const SubmitEvent();
}

// ===== feature_bloc.dart =====
part 'feature_event.dart';
part 'feature_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final LoadFeatureUseCase _loadUseCase;
  final FeatureNavigator _navigator;

  FeatureBloc({
    required LoadFeatureUseCase loadUseCase,
    required FeatureNavigator navigator,
  }) : _loadUseCase = loadUseCase,
       _navigator = navigator,
       super(const FeatureState()) {
    on<LoadEvent>(_onLoadEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<SubmitEvent>(_onSubmitEvent);
  }

  // Async handler: state guard + isClosed + error handling
  Future<void> _onLoadEvent(LoadEvent event, Emitter<FeatureState> emit) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _loadUseCase.execute(const NoParams());
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, title: result.title, count: result.count));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  // Sync handler: simple state update
  void _onUpdateEvent(UpdateEvent event, Emitter<FeatureState> emit) {
    emit(state.copyWith(title: event.title));
  }

  // Async handler: navigation via FeatureNavigator
  Future<void> _onSubmitEvent(SubmitEvent event, Emitter<FeatureState> emit) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      await _navigator.openSuccess();
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, error: e));
    }
  }
}
```

### 4. State Design
- Structure: Single `final class` with flat fields. This is the default and preferred approach. NEVER use `sealed class`, state subclasses, or `Data`/`Payload` wrapper classes.
- Equality: State classes do NOT implement `Equatable` or custom `==`/`hashCode`. Rebuild scoping is handled by `buildWhen`/`listenWhen` in the UI.
- Error field: `final Exception? error;` — not `AppException?`. This allows the Bloc to catch both domain and unexpected exceptions uniformly.
- Domain models: Allowed as field types. NEVER wrap them in additional `Data`/`Payload` classes.
- Nullability: Only use nullable fields when semantically meaningful.
- `copyWith`: Nullable fields MUST use the `_unset` proxy to allow explicit nulls. Non-nullable fields use standard `??` fallback.

```dart
// ===== feature_state.dart =====
part of 'feature_bloc.dart';

class FeatureState {
  final bool isLoading;
  final String? title;
  final int count;
  final Exception? error;
  final bool isSubmitting;

  const FeatureState({
    this.isLoading = false,
    this.title,
    this.count = 0,
    this.error,
    this.isSubmitting = false,
  });

  static const _unset = Object();

  FeatureState copyWith({
    bool? isLoading,
    Object? title = _unset,
    int? count,
    Object? error = _unset,
    bool? isSubmitting,
  }) {
    return FeatureState(
      isLoading: isLoading ?? this.isLoading,
      title: identical(title, _unset) ? this.title : title as String?,
      count: count ?? this.count,
      error: identical(error, _unset) ? this.error : error as Exception?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
```

### 5. Error Handling
- Bloc catches broadly: `on Exception catch (e)` — stores the exception in `state.error`.
- UI maps to messages: Each feature provides a `<Feature>ExceptionMapper` that downcasts `AppException` subtypes to user-facing strings and falls back to a generic message for unexpected exceptions.
- Blocs never format strings. No error messages, no localization keys in Bloc code.

### 6. Navigation Authority
Blocs own navigation. Inject the feature's `<Feature>Navigator` via constructor.
- Interface: `abstract interface class <Feature>Navigator` lives in the feature (`lib/src/navigation/<feature>_navigator.dart`) and is exported from the feature barrel.
- Intent-named methods: `openDetails(String id)`, `close()`, `Future<bool?> confirmDelete()`. NEVER expose routes, `AppRouter`, or route classes in the interface.
- Implementation: `Router<Feature>Navigator` in the `navigation` package maps each method to `AppRouter`:
    - `push` — Forward navigation, add to stack. Also used for dialogs and bottom sheets (implemented as routes). Example: Home → Detail, ConfirmDialog, FilterSheet.
    - `navigate` — Circular / lateral navigation, don't grow stack. Example: SignIn ↔ SignUp.
    - `replaceAll(updateExistingRoutes: false)` — Wipe entire stack, fresh start. Example: Login → Home.
    - `pop` — Back navigation.

```dart
// ===== feature/lib/src/navigation/feature_navigator.dart =====
abstract interface class FeatureNavigator {
  Future<void> openSuccess();
  Future<bool?> confirmDelete();
}

// ===== navigation/lib/src/navigators/router_feature_navigator.dart =====
final class RouterFeatureNavigator implements FeatureNavigator {
  final AppRouter _appRouter;

  const RouterFeatureNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openSuccess() => _appRouter.push(const SuccessRoute());

  @override
  Future<bool?> confirmDelete() => _appRouter.push<bool>(const ConfirmRoute());
}
```

Navigation results:
When a navigator method returns a result (e.g., a confirmation dialog), `await` it and handle the nullable return:

```dart
final confirmed = await _navigator.confirmDelete();
if (isClosed) return;
if (confirmed == true) {
  // proceed with the confirmed action
}
// confirmed == null means dismissed without a result (back button, barrier tap).
// Treat null as cancellation / no-op.
```

### 7. Strict Guardrails (NEVER DO)
❌ Repository / Data source injection into Blocs.
❌ Injecting `AppRouter` or importing the `navigation` package in a feature — use `<Feature>Navigator`.
❌ Base event handlers: NEVER use `on<FeatureEvent>()`. Always register handlers for concrete events.
❌ Standard `??` for nullable `copyWith` fields — use the `_unset` proxy.
❌ `Data` / `Payload` wrapper classes.
❌ Calling `emit()` after an `await` without an `isClosed` check.
❌ `Equatable` or custom `==`/`hashCode` on state classes.
❌ Storing `AppException` in state — use `Exception`.
❌ Formatting error strings or localization keys in Blocs.
❌ Adding a transformer not listed in the §3 selection guide.
❌ Using `droppable()` as the sole guard on synchronous handlers.

### 8. Testing & Auditing
- Tooling: `bloc_test` + `mocktail`.
- Structure: One `group(...)` per handler. Build the Bloc, then write tests to audit the implementation against these architectural rules.
- Isolation Check: BLoC tests ONLY mock `UseCase` and `<Feature>Navigator`. If a test attempts to mock a Repository or `AppRouter`, the BLoC implementation is violating §1.
- Required test cases:
    - Flat state emissions: Assert the exact sequence of flat `FeatureState` emissions. NEVER assert sealed state subclasses.
    - `_unset` proxy audit: Pass explicit `null` to a nullable `copyWith` field (e.g., `error`) via an event. Assert the field becomes `null`.
    - State guard: Dispatch the same async event twice rapidly. Assert only one loading cycle occurs.
    - `isClosed` safety: Close the Bloc while an async handler is in flight. Assert no crash and no emission after close.
    - Error path: Make the UseCase throw. Assert `isLoading` resets to `false` and `error` is set.
    - Navigation authority: Verify the matching `<Feature>Navigator` method is called for navigation events.
    - Navigation result: Mock the result-returning navigator method (e.g., `confirmDelete()`) returning `true`, `false`, and `null`. Assert correct handling for each.
- The "Untouchable" Rule: Existing tests are sacred. Do NOT modify an existing test to make it pass. If a test fails, fix the Bloc implementation. If the test itself contradicts an explicitly updated spec, flag it for human review rather than silently rewriting it.

### 9. Post-Implementation
- Run `dart fix --apply` on changed files.