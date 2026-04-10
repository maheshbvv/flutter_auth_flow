import 'package:flutter/material.dart';
import 'auth_flow_theme.dart';

/// A pre-styled text field used inside [AuthFlow] forms.
class AuthFlowTextField extends StatelessWidget {
  const AuthFlowTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.obscureToggle,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofillHints,
    this.theme,
    this.themeData,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;

  /// Widget placed in the suffix for password visibility toggle.
  final Widget? obscureToggle;

  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final AuthFlowTheme? theme;
  final ThemeData? themeData;

  @override
  Widget build(BuildContext context) {
    final td = themeData ?? Theme.of(context);
    final afTheme = theme;

    final effectiveFill = afTheme?.inputFillColor ??
        td.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    final baseDecoration = InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: effectiveFill,
      suffixIcon: obscureToggle,
      border: OutlineInputBorder(
        borderRadius:
            afTheme?.effectiveInputBorderRadius ?? BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            afTheme?.effectiveInputBorderRadius ?? BorderRadius.circular(12),
        borderSide: BorderSide(
          color: td.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            afTheme?.effectiveInputBorderRadius ?? BorderRadius.circular(12),
        borderSide: BorderSide(
          color: afTheme?.primaryColor ?? td.colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            afTheme?.effectiveInputBorderRadius ?? BorderRadius.circular(12),
        borderSide: BorderSide(
          color: afTheme?.errorColor ?? td.colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius:
            afTheme?.effectiveInputBorderRadius ?? BorderRadius.circular(12),
        borderSide: BorderSide(
          color: afTheme?.errorColor ?? td.colorScheme.error,
          width: 1.5,
        ),
      ),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      style: afTheme?.inputStyle,
      decoration: afTheme?.inputDecoration ?? baseDecoration,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
