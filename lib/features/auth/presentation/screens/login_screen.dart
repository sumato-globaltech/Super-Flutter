import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/core/di/injection.dart';
import 'package:starter/core/localization/app_localizations.dart';
import 'package:starter/core/ui/layouts/app_scaffold.dart';
import 'package:starter/core/ui/theme/app_spacing.dart';
import 'package:starter/core/ui/widgets/app_button.dart';
import 'package:starter/core/ui/widgets/app_text_field.dart';

import '../bloc/login_cubit.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: AppScaffold(
        title: l10n.signIn,
        constrainWidth: true,
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
            // Success navigates via GoRouter redirect (AuthCubit -> authenticated).
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.signInToContinue,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Gap.lg,
                  AppTextField(
                    label: l10n.username,
                    controller: _usernameController,
                    hint: 'emilys',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    enabled: !state.isSubmitting,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.username : null,
                  ),
                  Gap.md,
                  AppTextField(
                    label: l10n.password,
                    controller: _passwordController,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    enabled: !state.isSubmitting,
                    onSubmitted: (_) => _submit(context),
                    validator: (v) => (v == null || v.isEmpty) ? l10n.password : null,
                  ),
                  Gap.lg,
                  AppButton(
                    label: l10n.signIn,
                    isLoading: state.isSubmitting,
                    onPressed: state.isSubmitting
                        ? null
                        : () => _submit(context),
                  ),
                  Gap.sm,
                  Text(
                    'Demo backend: dummyjson.com (try emilys / emilyspass)',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().submit(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    }
  }
}
