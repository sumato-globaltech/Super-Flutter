import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/constants/assets_names.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
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

  void _requestOtp() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _otpController.clear();
    _loginBloc.add(LoginOtpRequested(_phoneController.text));
  }

  void _resendOtp(String phone) {
    _otpController.clear();
    _loginBloc.add(LoginOtpRequested(phone));
  }

  void _verifyOtp() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _loginBloc.add(LoginOtpSubmitted(_otpController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                child: BlocSelector<LoginBloc, LoginState, LoginMethod>(
                  selector: (state) => state.method,
                  builder: (context, method) => Column(
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

                      // 16.height,
                      if (method == LoginMethod.email) ...[
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
                      ] else
                        BlocBuilder<LoginBloc, LoginState>(
                          buildWhen: (prev, curr) =>
                              prev.otpPhone != curr.otpPhone ||
                              prev.otpSecondsLeft != curr.otpSecondsLeft ||
                              prev.phoneError != curr.phoneError ||
                              prev.otpError != curr.otpError ||
                              prev.isSubmitting != curr.isSubmitting,
                          builder: (context, state) {
                            final progress = DesignProgress(
                              color: Theme.of(context).colorScheme.primary,
                            );
                            final phone = state.otpPhone;
                            if (phone == null) {
                              return Column(
                                children: [
                                  TextFormField(
                                    controller: _phoneController,
                                    forceErrorText: state.phoneError,
                                    onChanged: state.phoneError == null
                                        ? null
                                        : (_) => _loginBloc.add(
                                            const LoginFieldErrorCleared(
                                              'phone',
                                            ),
                                          ),
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.telephoneNumberNational,
                                    ],
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: l10n.loginPhone,
                                      hintText: l10n.loginPhoneHint,
                                      prefixIcon: const Icon(
                                        PhosphorIconsBold.phone,
                                      ),
                                    ),
                                    validator: (v) =>
                                        RegExp(r'^\d{10}$').hasMatch(v ?? '')
                                        ? null
                                        : l10n.loginPhoneInvalid,
                                    onFieldSubmitted: (_) => _requestOtp(),
                                    onTapOutside: (_) => FocusManager
                                        .instance
                                        .primaryFocus
                                        ?.unfocus(),
                                  ),
                                  12.height,
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state.isSubmitting
                                          ? null
                                          : _requestOtp,
                                      child: state.isSubmitting
                                          ? progress
                                          : Text(l10n.loginOtpSend),
                                    ),
                                  ),
                                ],
                              );
                            }
                            final left = state.otpSecondsLeft;
                            final time =
                                '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}';
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10n.loginOtpSentTo(phone),
                                        style: textStyle,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: state.isSubmitting
                                          ? null
                                          : () => _loginBloc.add(
                                              const LoginOtpNumberChanged(),
                                            ),
                                      child: Text(l10n.loginOtpChangeNumber),
                                    ),
                                  ],
                                ),
                                8.height,
                                TextFormField(
                                  controller: _otpController,
                                  forceErrorText: state.otpError,
                                  onChanged: state.otpError == null
                                      ? null
                                      : (_) => _loginBloc.add(
                                          const LoginFieldErrorCleared('otp'),
                                        ),
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.oneTimeCode,
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.loginOtp,
                                    hintText: l10n.loginOtpHint,
                                    prefixIcon: const Icon(
                                      PhosphorIconsBold.password,
                                    ),
                                  ),
                                  validator: (v) =>
                                      RegExp(r'^\d{6}$').hasMatch(v ?? '')
                                      ? null
                                      : l10n.loginOtpInvalid,
                                  onFieldSubmitted: (_) => _verifyOtp(),
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                ),
                                12.height,
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        state.isSubmitting || state.otpExpired
                                        ? null
                                        : _verifyOtp,
                                    child: state.isSubmitting
                                        ? progress
                                        : Text(l10n.loginOtpVerify),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.otpExpired
                                            ? l10n.loginOtpExpired
                                            : l10n.loginOtpExpiresIn(time),
                                        style: textStyle,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          state.otpExpired &&
                                              !state.isSubmitting
                                          ? () => _resendOtp(phone)
                                          : null,
                                      child: Text(l10n.loginOtpResend),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      12.height,
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Continue with '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () {
                                  _loginBloc.add(
                                    LoginMethodChanged(
                                      method == LoginMethod.email
                                          ? LoginMethod.phone
                                          : LoginMethod.email,
                                    ),
                                  );
                                },
                                child: Text(
                                  method == LoginMethod.email
                                      ? l10n.loginWithPhone
                                      : l10n.loginWithEmail,
                                  style: linkStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: textStyle,
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
      ),
    );
  }
}
