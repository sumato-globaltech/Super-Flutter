import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/presentation/change_password/bloc/change_password_bloc.dart';
import 'package:super_flutter/features/auth/presentation/change_password/bloc/change_password_event.dart';
import 'package:super_flutter/features/auth/presentation/change_password/bloc/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordBloc>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  late final ChangePasswordBloc _changePasswordBloc;

  @override
  void initState() {
    super.initState();
    _changePasswordBloc = context.read<ChangePasswordBloc>();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _changePasswordBloc.add(
      ChangePasswordSubmitted(
        currentPassword: _currentPasswordController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forced = context.select(
      (AuthCubit cubit) => cubit.state.mustChangePassword,
    );
    return BlocListener<ChangePasswordBloc, ChangePasswordState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case ChangePasswordStatus.success:
            Utils.flutterToast(l10n.authChangePasswordDone);
            // Forced, the router takes the user on once the session knows.
            if (context.canPop()) context.pop(true);
          case ChangePasswordStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case ChangePasswordStatus.initial || ChangePasswordStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(
          title: l10n.authChangePasswordTitle,
          automaticallyImplyLeading: !forced,
          actions: [
            if (forced)
              TextButton(
                onPressed: () => _changePasswordBloc.add(
                  const ChangePasswordSignOutRequested(),
                ),
                child: Text(l10n.signOut),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (forced) ...[
                      Text(
                        l10n.authChangePasswordRequired,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      12.height,
                    ],
                    BlocSelector<
                      ChangePasswordBloc,
                      ChangePasswordState,
                      ({String? error, bool obscure})
                    >(
                      selector: (state) => (
                        error: state.currentPasswordError,
                        obscure: state.obscureCurrentPassword,
                      ),
                      builder: (context, currentPassword) => TextFormField(
                        controller: _currentPasswordController,
                        forceErrorText: currentPassword.error,
                        onChanged: currentPassword.error == null
                            ? null
                            : (_) => _changePasswordBloc.add(
                                const ChangePasswordFieldErrorCleared(
                                  'current_password',
                                ),
                              ),
                        textInputAction: TextInputAction.next,
                        obscureText: currentPassword.obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.authChangePasswordCurrentPassword} *',
                          hintText: l10n.fieldEnter(
                            l10n.authChangePasswordCurrentPassword,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => _changePasswordBloc.add(
                              const ChangePasswordCurrentPasswordVisibilityToggled(),
                            ),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              currentPassword.obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.fieldRequired(
                                l10n.authChangePasswordCurrentPassword,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<
                      ChangePasswordBloc,
                      ChangePasswordState,
                      ({String? error, bool obscure})
                    >(
                      selector: (state) => (
                        error: state.passwordError,
                        obscure: state.obscurePassword,
                      ),
                      builder: (context, password) => TextFormField(
                        controller: _passwordController,
                        forceErrorText: password.error,
                        onChanged: password.error == null
                            ? null
                            : (_) => _changePasswordBloc.add(
                                const ChangePasswordFieldErrorCleared(
                                  'password',
                                ),
                              ),
                        textInputAction: TextInputAction.next,
                        obscureText: password.obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: '${l10n.authChangePasswordPassword} *',
                          hintText: l10n.fieldEnter(
                            l10n.authChangePasswordPassword,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => _changePasswordBloc.add(
                              const ChangePasswordPasswordVisibilityToggled(),
                            ),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              password.obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.fieldRequired(
                                l10n.authChangePasswordPassword,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<
                      ChangePasswordBloc,
                      ChangePasswordState,
                      ({String? error, bool obscure})
                    >(
                      selector: (state) => (
                        error: state.passwordConfirmationError,
                        obscure: state.obscurePasswordConfirmation,
                      ),
                      builder: (context, passwordConfirmation) => TextFormField(
                        controller: _passwordConfirmationController,
                        forceErrorText: passwordConfirmation.error,
                        onChanged: passwordConfirmation.error == null
                            ? null
                            : (_) => _changePasswordBloc.add(
                                const ChangePasswordFieldErrorCleared(
                                  'password_confirmation',
                                ),
                              ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        obscureText: passwordConfirmation.obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.authChangePasswordPasswordConfirmation} *',
                          hintText: l10n.fieldEnter(
                            l10n.authChangePasswordPasswordConfirmation,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => _changePasswordBloc.add(
                              const ChangePasswordPasswordConfirmationVisibilityToggled(),
                            ),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              passwordConfirmation.obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.fieldRequired(
                                l10n.authChangePasswordPasswordConfirmation,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<ChangePasswordBloc, ChangePasswordState, bool>(
                      selector: (state) => state.isSubmitting,
                      builder: (context, isSubmitting) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? DesignProgress(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : Text(l10n.formSubmit),
                        ),
                      ),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
