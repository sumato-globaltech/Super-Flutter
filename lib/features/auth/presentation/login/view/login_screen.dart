import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/core/di/injection.dart';
import 'package:starter/core/localization/app_localizations.dart';
import 'package:starter/core/ui/layouts/app_scaffold.dart';
import 'package:starter/core/ui/theme/app_spacing.dart';
import 'package:starter/core/ui/widgets/app_button.dart';
import 'package:starter/core/ui/widgets/app_text_field.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: AppScaffold(
        title: l10n.signIn,
        constrainWidth: true,
        body: BlocConsumer<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == LoginStatus.failure,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
            // Success navigates via GoRouter redirect (AuthCubit -> authenticated).
          },
          builder: (context, state) {
            final bloc = context.read<LoginBloc>();
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
                    initialValue: state.username,
                    hint: 'emilys',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    enabled: !state.isSubmitting,
                    onChanged: (v) => bloc.add(LoginUsernameChanged(v)),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.username : null,
                  ),
                  Gap.md,
                  AppTextField(
                    label: l10n.password,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    enabled: !state.isSubmitting,
                    onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                    onSubmitted: (_) => _submit(context),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.password : null,
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
      context.read<LoginBloc>().add(const LoginSubmitted());
    }
  }
}
