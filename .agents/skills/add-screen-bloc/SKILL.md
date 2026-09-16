---
name: add-screen-bloc
description: Add one event-driven Bloc for one screen in this Flutter starter. Use when creating screen state management (form + submission, loading/loaded/error flows) while keeping AuthCubit-style Cubits for tiny shared tasks only.
---

# Add Screen Bloc

One Bloc per screen. Main screen work is a `Bloc`; `Cubit` is reserved for
small shared tasks (e.g. status-only `AuthCubit` consumed by the router).

## Files (per screen)

The screen lives with its Bloc under `presentation/`:

```
lib/features/<feature>/presentation/<screen>/screen/<name>_screen.dart
lib/features/<feature>/presentation/<screen>/bloc/<name>_bloc.dart
lib/features/<feature>/presentation/<screen>/bloc/<name>_event.dart
lib/features/<feature>/presentation/<screen>/bloc/<name>_state.dart
lib/features/<feature>/presentation/<screen>/widgets/   # screen-private (only when needed)
```

Shared Cubits (e.g. status-only `AuthCubit`) live in an explicitly-named scope
such as `features/auth/session/bloc/`, never mixed into a screen's `bloc/`.

## State shape

```dart
enum <Name>Status { initial, submitting/loading, success/loaded, failure/error }

class <Name>State extends Equatable {
  const <Name>State({/* form fields with defaults, */ this.status = <Name>Status.initial, this.errorMessage});
  bool get isSubmitting => ...;
  bool get isValid => ...;      // form screens
  bool get canSubmit => isValid && !isSubmitting;
  <Name>State copyWith({...});
  @override List<Object?> get props => [...];
}
```

Keep fields in state (e.g. `username`, `password`), not only in controllers,
so validation and `canSubmit` live in the Bloc.

## Bloc shape

```dart
@injectable
class <Name>Bloc extends Bloc<<Name>Event, <Name>State> {
  <Name>Bloc(this._useCase, this._authCubit) : super(const <Name>State()) {
    on<<Name>FieldChanged>(_onFieldChanged);
    on<<Name>Submitted>(_onSubmitted);
  }
  Future<void> _onSubmitted(event, emit) async {
    if (state.isSubmitting) return;
    if (!state.isValid) { emit(state.copyWith(status: failure, errorMessage: ...)); return; }
    emit(state.copyWith(status: submitting));
    try {
      await _useCase(...);
      _authCubit.authenticated();   // only when the operation changes session status
      emit(state.copyWith(status: success));
    } on AppException catch (e) {
      emit(state.copyWith(status: failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: failure, errorMessage: '... failed. Please try again.'));
    }
  }
}
```

Only touch `AuthCubit` (`authenticated()`/`unauthenticated()`) when the
operation genuinely changes session status. Never inject `AuthCubit` into
`core/` — `SessionManager` reaches it via lazy `GetIt` lookup (DI cycle).

## Screen shape

- `BlocProvider(create: (_) => getIt<<Name>Bloc>())` at the screen root.
- `TextField.onChanged: (v) => context.read<Bloc>().add(FieldChanged(v))`;
  submit button dispatches `Submitted()` after `Form.validate()`.
- `BlocConsumer`: listener shows `SnackBar` on `failure` (do not navigate on
  success — GoRouter redirect on `AuthCubit.stream` handles it where relevant).
- Reference implementations: `features/auth/presentation/login/screen/login_screen.dart`,
  `features/dashboard/presentation/dashboard/screen/dashboard_screen.dart`.

## Tests

`test/features/<feature>/<name>_bloc_test.dart` with `bloc_test`:
field events → state sequence; blank/invalid submit → failure without calling
the use-case (`verifyNever`); success → use-case + status reflection verified;
`AppException` → failure message, no status change.
