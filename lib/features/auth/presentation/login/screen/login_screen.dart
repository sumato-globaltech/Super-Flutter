import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/constants/assets_names.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/gradient_background.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';

class LoginScreen extends StatelessWidget {
  static const String route = "/LoginScreen";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: bloc.formKey,
              child: Column(
                children: [
                  const _LoginHeader(),
                  10.height,
                  const _EmailField(),
                  12.height,
                  const _PasswordField(),
                  12.height,
                  const _LoginButton(),
                  12.height,
                  const _TermsText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: AssetsName.appLogo,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              AssetsName.appLogo,
              width: 100,
              height: 100,
              // gaplessPlayback: true,
            ),
          ),
        ),
        12.height,
        const Text(Constants.appFullName, textAlign: TextAlign.center),
        12.height,
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    return TextFormField(
      controller: bloc.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Email *',
        hintText: 'Type your Email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: Utils.validateEmail,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    final obscure = context.select((LoginBloc b) => b.state.obscurePassword);
    return TextFormField(
      controller: bloc.passwordController,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password *',
        hintText: 'Type your Password',
        prefixIcon: const Icon(PhosphorIconsBold.lock),
        suffixIcon: IconButton(
          onPressed: () => bloc.add(const LoginPasswordVisibilityToggled()),
          splashRadius: 16,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            obscure ? PhosphorIconsBold.eyeClosed : PhosphorIconsBold.eye,
            size: 18,
          ),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Password is required' : null,
      onFieldSubmitted: (_) => bloc.add(const LoginSubmitted()),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((LoginBloc b) => b.state.isSubmitting);
    return SizedBox(
      width: double.infinity,
      child: Hero(
        tag: Constants.keyLoginButton,
        child: ElevatedButton(
          onPressed: isSubmitting
              ? null
              : () => context.read<LoginBloc>().add(const LoginSubmitted()),
          child: isSubmitting
              ? DesignProgress(color: Theme.of(context).colorScheme.primary)
              : const Text('Login'),
        ),
      ),
    );
  }
}

class _TermsText extends StatefulWidget {
  const _TermsText();

  @override
  State<_TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<_TermsText> {
  late final _termsTap = TapGestureRecognizer()..onTap = () {};
  late final _privacyTap = TapGestureRecognizer()..onTap = () {};

  static const _linkStyle = TextStyle(
    color: AppColors.secondary,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Use',
            style: _linkStyle,
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: _linkStyle,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Colors.grey, height: 1.5),
    );
  }
}
