import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_dimensions.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final String? helperText;

  final String? errorText;

  final IconData? prefixIcon;
  final Widget? suffix;

  final bool obscureText;

  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      obscureText: _obscured,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: _obscured ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: AppDimensions.iconMd),
        suffixIcon: _buildSuffix(),
      ),
    );
  }

  Widget? _buildSuffix() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        tooltip: _obscured ? 'Show password' : 'Hide password',
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppDimensions.iconMd,
        ),
      );
    }
    return widget.suffix;
  }
}
