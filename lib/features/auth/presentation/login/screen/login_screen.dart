import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_flutter/core/constants/assets_names.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_text_field.dart';
import 'package:super_flutter/core/ui/widgets/gradient_background.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';

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
  bool isloading = false;
  final _email = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GradientBackground(
      child: BlocProvider(
        create: (_) => getIt<LoginBloc>(),
        child: BlocConsumer<LoginBloc, LoginState>(
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
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: AssetsName.appLogo,
                          child: ClipRRect(
                            borderRadius: .circular(08),
                            child: Image.asset(AssetsName.appLogo, width: 100),
                          ),
                        ),
                        12.height,
                        const Text(Constants.appFullName, textAlign: .center),
                        10.height,
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Utils.validateEmail,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Hero(
                            tag: Constants.keyLoginButton,
                            child: ElevatedButton(
                              onPressed: isloading ? null : () async {},
                              child: isloading
                                  ? DesignProgress(
                                      color: theme.colorScheme.primary,
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
