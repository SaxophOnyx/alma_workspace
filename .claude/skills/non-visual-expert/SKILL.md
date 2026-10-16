---
name: non-visual-expert
description: Architecture rules for domain, data, and infrastructure layers (models, use cases, repositories, providers, entities, services, DI, exceptions). LOAD ONLY WHEN implementing new domain/data infrastructure from scratch or heavily refactoring existing business logic, data mapping, or backend integration. DO NOT LOAD for minor bug fixes or small logic tweaks (rely on existing code context instead).
---

## Domain, Data & Infrastructure Guidelines

### 1. Core Directives
Priority: Overrides generic architecture rules.
- Dependencies: Domain/data NEVER depend on presentation/view. `domain` is pure Dart (zero framework imports). Depend on `abstract interface class` contracts; inject implementations from above.
- Orchestration: Use Cases orchestrate Repositories. Services are a fallback for non-data/cross-cutting/platform capabilities.
- Lifecycle: UseCases return `Future`/`Stream`. The BLoC (presentation layer) owns subscription cancellation and lifecycle. UseCases and Repositories hold no lifecycle awareness.
- Files: One class per file, exported via barrel file. Barrel files MUST NOT re-export across layer boundaries (one barrel per layer folder). Exception: `<UseCase>Params` / `NoParams` live in the same file as their UseCase.
- Immutability: All domain entity and params fields MUST be `final`. No setters. No `..` cascade mutation. Use `const` constructors wherever possible.
- CodeGen: Use `@JsonSerializable` for data entities (remember `part 'xxx.g.dart';`).
  - Set `explicitToJson: true` for nested objects.
  - Use custom `JsonConverter` for enums, `DateTime`, and non-trivial types.
  - Do NOT set `disallowUnrecognizedKeys: true` (tolerate extra API fields).

### 2. Domain Layer
- Entities: Plain, immutable Dart classes. All fields `final`, `const` constructor. No serialization annotations, no framework types.
- Repositories: `abstract interface class XxxRepository` returning only domain entities.
- Use Cases: Implement base contracts (`FutureUseCase`, `StreamUseCase`, `UseCase` — see `use_case_templates.dart`). Expose single `execute()`. Inject ONLY repository/service abstractions. Place `<UseCase>Params` in the same file as use case. Use `NoParams` for no input. Orchestrate multiple repos if needed. No navigation/view state.
- Pagination: Expose as `List<Model>` return type. Accept `from`/`to` (or equivalent offset/limit) via the Params class. No wrapper types.

```dart
// ==== use_case_templates.dart (reference) ====
abstract interface class FutureUseCase<In, Out> { Future<Out> execute(In input); }
abstract interface class StreamUseCase<In, Out> { Stream<Out> execute(In input); }
abstract interface class UseCase<In, Out> { Out execute(In input); }

class NoParams { const NoParams(); }

// ==== sign_in_use_case.dart ====
class SignInUseCase implements FutureUseCase<SignInParams, User> {
  final AuthRepository _authRepository;
  final NotificationRepository _notificationRepository;

  const SignInUseCase({
    required AuthRepository authRepository,
    required NotificationRepository notificationRepository,
  }) : _authRepository = authRepository,
       _notificationRepository = notificationRepository;

  @override
  Future<User> execute(SignInParams input) async {
    final user = await _authRepository.signIn(input.email, input.password);
    await _notificationRepository.initializeNotifications(user.id);
    return user;
  }
}
```

### 3. Data Layer
- Pipeline: Provider → Entity → Mapper → Repository (each in own file/folder).
- Entities: `XxxEntity` for wire/storage shapes. NEVER escape the data layer.
- Mappers: The ONLY boundary between entities and domain models. Named `XxxMapper` with static methods. Private constructor (`const XxxMapper._();`).
- Repositories: `final class` implementing the domain contract (e.g., `RemoteNotesRepository`).
- Orchestration: Repositories MAY contain data-routing logic (e.g., cache-first strategies). They MUST NOT contain business rules.
- Errors: Convert transport/storage errors to `AppException` subclasses defined in domain. Raw SDK/HTTP types NEVER propagate. Convert unexpected exceptions to `AppException.unknown()`;

```dart
// ==== notes_provider.dart ====
abstract interface class NotesProvider {
  Future<List<NoteEntity>> fetchNotes({required int from, required int to});
}

// ==== notes_mapper.dart ====
final class NotesMapper {
  const NotesMapper._();
  static Note fromEntity(NoteEntity e) => Note(id: e.id, title: e.title);
}

// ==== remote_notes_repository.dart ====
final class RemoteNotesRepository implements NotesRepository {
  final NotesProvider _notesProvider;

  const RemoteNotesRepository({required NotesProvider notesProvider})
      : _notesProvider = notesProvider;

  @override
  Future<List<Note>> getNotes({required int from, required int to}) async {
    try {
      final entities = await _notesProvider.fetchNotes(from: from, to: to);
      return entities.map(NotesMapper.fromEntity).toList();
    } on ApiException catch (e) {
      throw UnableToGetNotesException(cause: e);
    } on SocketException catch (e) {
      throw NetworkUnavailableException(cause: e);
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }
}
```

### 4. Services (Fallback)
- Rule: If it involves data/state, use a Repository. Services are strictly for non-data/cross-cutting/platform capabilities (`SecureStorage`, `Crashlytics`, etc.).
- Isolation: Hide infrastructure services behind thin, intent-based domain abstractions (e.g., `NotificationDispatcher`). Concrete services NEVER import view packages. If a service needs domain-adjacent data (e.g., a token for `SecureStorage`), it receives primitives or its own DTO — never domain entities.

### 5. Dependency Injection
- Registration: Modules expose `static void initDependencies(GetIt locator)`. App entrypoint composes them bottom-up.
- Lifetimes: Default to `registerLazySingleton`. This is intentional for all registrations.
- Consumption: Use constructor injection for domain/data classes. NEVER call `locator<T>()` inside them.

```dart
final class DomainDI {
  const DomainDI._();

  static void initDependencies(GetIt locator) {
    locator.registerLazySingleton<GetNotesUseCase>(
      () => GetNotesUseCase(notesRepository: locator<NotesRepository>()),
    );
  }
}
```

### 6. Error Handling
- Type: `AppException` is defined in the core package. All domain/data exceptions MUST subclass it. NEVER use `Result`/`Either`/`Failure`.
- Throwing: Data sources/services throw with machine-readable context (codes/enums). Repositories catch expected transport errors and rethrow as `AppException` domain subclasses.
- Strings: NO user-facing/view strings in exceptions. The presentation layer maps exception types to UI strings.
- Catching: Catch expected exception families (`ApiException`, `SocketException`, `TimeoutException`, specific SDK exceptions). Add a bare `on Exception catch (_)` to catch unexpected exception.

### 7. Strict Guardrails (NEVER DO)
❌ Framework imports in `domain`.
❌ Domain/UseCases referencing Entities, providers, or data-source types.
❌ Injecting concrete repos/services into UseCases.
❌ Domain/data depending on presentation/view types.
❌ Navigation, view state, or widget logic in UseCases.
❌ Using "Service" for data operations (use Repository).
❌ `Result`/`Either`/`Failure` types.
❌ Direct `locator<T>()` access inside domain/data/service classes.
❌ Lack of `on Exception catch (_)` at the end of `try..catch` bloc.
❌ Manual retry/backoff logic in providers or repositories. Retry is handled by the shared `HttpProvider` infrastructure.
❌ Mutable domain entities (non-`final` fields, setters, cascade mutation).
❌ Barrel files re-exporting across layer boundaries.

### 8. Testing & TDD (Bulletproof Domain & Data)
- Tooling: Use `test` and `mocktail`. No code-generation mocks.
- TDD Mandate: STRICT Test-Driven Development. You MUST write the failing tests FIRST. Only write the implementation after the tests are defined and structurally failing.
- Bulletproof Coverage: Happy path is the bare minimum. Complex logic will be introduced later; tests must anticipate it. You MUST test:
  - Mappers: Null fields, empty collections, boundary values, and malformed data.
  - Use Cases: Orchestration failures (e.g., if Repo A succeeds but Repo B fails), empty inputs, and pagination edge cases (`from`/`to` boundaries, empty page).
  - Repositories: Exact `AppException` mapping from raw SDK/HTTP errors. If orchestrating multiple providers (e.g., cache + API), use `verifyInOrder` to assert the exact flow and side-effects (e.g., saving to cache).
- Mocking Rules:
  - Mock at the boundary (mock `Repository` in UseCase tests; mock `Provider` in Repository tests).
  - NEVER mock the System Under Test (SUT).
  - NEVER use `any()` for arguments if the specific value matters. Use exact instances or `argThat(isA<T>().having(...))` to verify the EXACT data passed to mocks.
- The "Untouchable" Rule: Existing tests are sacred. NEVER modify an existing test to make it pass. If a test fails, you MUST fix the implementation. You may ONLY modify an existing test if the underlying business requirement/behavior is explicitly being changed by the user.

### 9. Post-Implementation
- Run `dart analyze --fatal-infos` on changed files. Fix all diagnostics.
- Run `dart fix --apply` on changed files.
- Run `dart run build_runner build --delete-conflicting-outputs` if entities changed.
- Verify via `scripts/run_unit_tests.sh`. If the script exits non-zero, the implementation is NOT complete.
