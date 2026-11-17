import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/constants/assets_names.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
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
  bool obscureText = true;
  final _email = TextEditingController();
  final _password = TextEditingController();

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
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: AssetsName.appLogo,
                            child: ClipRRect(
                              borderRadius: .circular(08),
                              child: Image.asset(
                                AssetsName.appLogo,
                                width: 100,
                              ),
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
                              hintText: "Type your Email",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: Utils.validateEmail,
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                          12.height,
                          TextFormField(
                            controller: _password,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              hintText: "Type your Password",
                              prefixIcon: const Icon(PhosphorIconsBold.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  obscureText = !obscureText;
                                  setState(() {});
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 16,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  obscureText
                                      ? PhosphorIconsBold.eyeClosed
                                      : PhosphorIconsBold.eye,
                                  color: DesignColor.grey900,
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Password is required'
                                : null,
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            obscureText: obscureText,
                          ),
                          12.height,
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
                          12.height,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey, height: 1.5),
                              children: [
                                const TextSpan(
                                  text: 'By continuing, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Utils.launchUrl2(
                                      //   url:
                                      //       "${Constants.apiUrl}/terms-and-conditions",
                                      // );
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Utils.launchUrl2(
                                      //   url: "${Constants.apiUrl}/privacy-policy",
                                      // );
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ],
                      ),
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
