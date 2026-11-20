import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/constants/assets_names.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/gradient_background.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  static const String route = "/LoginScreen";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = context.read<LoginBloc>();
    if (kDebugMode) {
      _emailController.text = 'super-admin@test.test';
      _passwordController.text = 'sumato@1234';
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final ddd = !(_formKey.currentState?.validate() ?? false);
    if (ddd) return;
    _loginBloc.add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey, height: 1.5);
    final linkStyle = textStyle?.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
    );
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == LoginStatus.failure,
      listener: (context, state) {
        final message = state.errorMessage;
        if (state.fieldErrors.isEmpty && message != null) {
          context.showSnackBar(message, isError: true);
        }
      },
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Hero(
                      tag: AssetsName.appLogo,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          AssetsName.appLogo,
                          width: 100,
                          height: 100,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                    12.height,
                    const Text(
                      Constants.appFullName,
                      textAlign: TextAlign.center,
                    ),
                    22.height,
                    BlocSelector<LoginBloc, LoginState, String?>(
                      selector: (state) => state.emailError,
                      builder: (context, emailError) => TextFormField(
                        controller: _emailController,
                        forceErrorText: emailError,
                        onChanged: emailError == null
                            ? null
                            : (_) => _loginBloc.add(
                                const LoginFieldErrorCleared('email'),
                              ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          hintText: 'Type your Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Utils.validateEmail,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<
                      LoginBloc,
                      LoginState,
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
                            : (_) => _loginBloc.add(
                                const LoginFieldErrorCleared('password'),
                              ),
                        obscureText: password.obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          hintText: 'Type your Password',
                          prefixIcon: const Icon(PhosphorIconsBold.lock),
                          suffixIcon: IconButton(
                            onPressed: () => _loginBloc.add(
                              const LoginPasswordVisibilityToggled(),
                            ),
                            splashRadius: 16,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              password.obscure
                                  ? PhosphorIconsBold.eyeClosed
                                  : PhosphorIconsBold.eye,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Password is required'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<LoginBloc, LoginState, bool>(
                      selector: (state) => state.isSubmitting,
                      builder: (context, isSubmitting) => SizedBox(
                        width: double.infinity,
                        child: Hero(
                          tag: Constants.keyLoginButton,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submit,
                            child: isSubmitting
                                ? DesignProgress(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  )
                                : Text('Login'),
                          ),
                        ),
                      ),
                    ),
                    12.height,
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to our ',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text('Terms of Use', style: linkStyle),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text('Privacy Policy', style: linkStyle),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
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
