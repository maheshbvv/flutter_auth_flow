import 'package:flutter/material.dart';

/// Controls the visual appearance of [AuthFlow].
///
/// Every property is optional. Unset properties fall back to the app's
/// active [ThemeData], so [AuthFlow] always looks at home without any
/// configuration at all.
///
/// For surgical overrides pass individual tokens (e.g. [primaryColor]).
/// For complete control pass [inputDecoration], [buttonStyle], or
/// [cardDecoration] directly.
class AuthFlowTheme {
  const AuthFlowTheme({
    // ── Colors ────────────────────────────────────────────
    this.primaryColor,
    this.backgroundColor,
    this.inputFillColor,
    this.errorColor,

    // ── Typography ────────────────────────────────────────
    this.titleStyle,
    this.subtitleStyle,
    this.inputStyle,
    this.buttonTextStyle,
    this.linkStyle,

    // ── Shape ─────────────────────────────────────────────
    this.inputBorderRadius,
    this.buttonBorderRadius,

    // ── Full-override decorations ─────────────────────────
    this.inputDecoration,
    this.buttonStyle,
    this.cardDecoration,

    // ── Animation ─────────────────────────────────────────
    this.transitionDuration,
    this.transitionCurve,
  });

  // ── Colors ──────────────────────────────────────────────
  /// Primary accent color — used for the submit button and links.
  /// Defaults to [ColorScheme.primary].
  final Color? primaryColor;

  /// Background color of the widget surface.
  /// Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// Fill color for text input fields.
  /// Defaults to a subtle tint derived from [backgroundColor].
  final Color? inputFillColor;

  /// Color used for inline error messages.
  /// Defaults to [ColorScheme.error].
  final Color? errorColor;

  // ── Typography ──────────────────────────────────────────
  /// Style for the mode title ("Welcome back", "Create account", etc.).
  final TextStyle? titleStyle;

  /// Style for the mode subtitle below the title.
  final TextStyle? subtitleStyle;

  /// Style applied to text inside input fields.
  final TextStyle? inputStyle;

  /// Style for the text inside the submit button.
  final TextStyle? buttonTextStyle;

  /// Style for the mode-switch links ("Don't have an account? Sign up").
  final TextStyle? linkStyle;

  // ── Shape ───────────────────────────────────────────────
  /// Border radius applied to all text inputs.
  /// Defaults to [BorderRadius.circular(12)].
  final BorderRadius? inputBorderRadius;

  /// Border radius applied to the submit button.
  /// Defaults to [BorderRadius.circular(12)].
  final BorderRadius? buttonBorderRadius;

  // ── Full-override decorations ────────────────────────────
  /// Complete [InputDecoration] override. When set, individual token
  /// overrides ([inputFillColor], [inputBorderRadius], [inputStyle])
  /// are ignored for the decoration.
  final InputDecoration? inputDecoration;

  /// Complete [ButtonStyle] override for the submit button.
  final ButtonStyle? buttonStyle;

  /// [BoxDecoration] for the outer card/container.
  /// Set to `BoxDecoration()` (empty) to remove all decoration.
  final BoxDecoration? cardDecoration;

  // ── Animation ───────────────────────────────────────────
  /// Duration of the animated mode transition.
  /// Defaults to [Duration(milliseconds: 320)].
  final Duration? transitionDuration;

  /// Curve used for the mode transition animation.
  /// Defaults to [Curves.easeInOut].
  final Curve? transitionCurve;

  // ── Helpers used internally ──────────────────────────────
  Duration get effectiveTransitionDuration =>
      transitionDuration ?? const Duration(milliseconds: 320);

  Curve get effectiveTransitionCurve => transitionCurve ?? Curves.easeInOut;

  BorderRadius get effectiveInputBorderRadius =>
      inputBorderRadius ?? BorderRadius.circular(12);

  BorderRadius get effectiveButtonBorderRadius =>
      buttonBorderRadius ?? BorderRadius.circular(12);
}
