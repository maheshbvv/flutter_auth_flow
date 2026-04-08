import 'package:flutter/material.dart';
import 'auth_flow_state.dart';
import 'auth_flow_theme.dart';
import 'auth_forms.dart';
import 'auth_mode.dart';

/// A single widget that handles Sign In, Sign Up, and Forgot Password.
///
/// Drop this into any screen and wire up the three async callbacks.
/// The widget manages its own loading state, error display, mode transitions,
/// and form validation — all internally.
///
/// ## Minimal usage
/// ```dart
/// AuthFlow(
///   onSignIn: (email, password) async {
///     await FirebaseAuth.instance.signInWithEmailAndPassword(
///       email: email, password: password,
///     );
///   },
///   onSignUp: (email, password, name) async {
///     await myAuthService.register(email, password, name);
///   },
///   onForgotPassword: (email) async {
///     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
///   },
/// )
/// ```
///
/// ## With external state (BLoC / Riverpod)
/// ```dart
/// AuthFlow(
///   onSignIn: ...,
///   isLoading: ref.watch(authProvider).isLoading,
///   errorMessage: ref.watch(authProvider).error,
/// )
/// ```
///
/// ## With full customization
/// ```dart
/// AuthFlow(
///   onSignIn: ...,
///   theme: AuthFlowTheme(primaryColor: Colors.indigo),
///   headerBuilder: (ctx, mode) => MyBrandedHeader(mode: mode),
///   submitButtonBuilder: (ctx, onTap, loading) => MyButton(...),
/// )
/// ```
class AuthFlow extends StatefulWidget {
  const AuthFlow({
    super.key,

    // ── Required callbacks ──────────────────────────────
    required this.onSignIn,
    required this.onSignUp,
    required this.onForgotPassword,

    // ── Optional state overrides ────────────────────────
    this.isLoading,
    this.errorMessage,
    this.initialMode,

    // ── Theme ───────────────────────────────────────────
    this.theme,

    // ── Builders ────────────────────────────────────────
    this.headerBuilder,
    this.footerBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.submitButtonBuilder,
    this.modeSwitcherBuilder,
  });

  // ── Callbacks ────────────────────────────────────────────────────────────────

  /// Called when the user submits the sign-in form.
  ///
  /// Throw any [Exception] or [Error] to display it as an error message.
  final Future<void> Function(String email, String password) onSignIn;

  /// Called when the user submits the sign-up form.
  ///
  /// Throw any [Exception] or [Error] to display it as an error message.
  final Future<void> Function(String email, String password, String name)
      onSignUp;

  /// Called when the user submits the forgot-password form.
  ///
  /// Throw any [Exception] or [Error] to display it as an error message.
  final Future<void> Function(String email) onForgotPassword;

  // ── State overrides ───────────────────────────────────────────────────────────

  /// When non-null, overrides the widget's internal loading state.
  /// Use this when you manage state externally (BLoC, Riverpod, Provider).
  final bool? isLoading;

  /// When non-null, overrides the widget's internal error message.
  final String? errorMessage;

  /// The mode to start in. Defaults to [AuthMode.signIn].
  final AuthMode? initialMode;

  // ── Theme ─────────────────────────────────────────────────────────────────────

  /// Fine-grained visual customization. See [AuthFlowTheme] for all options.
  final AuthFlowTheme? theme;

  // ── Builders ──────────────────────────────────────────────────────────────────

  /// Replaces the default title + subtitle header area.
  ///
  /// Receives the current [AuthMode] so you can render mode-specific branding.
  final Widget Function(BuildContext context, AuthMode mode)? headerBuilder;

  /// Rendered below the form and mode-switcher links.
  final Widget Function(BuildContext context, AuthMode mode)? footerBuilder;

  /// Replaces the default inline error message widget.
  final Widget Function(BuildContext context, String error)? errorBuilder;

  /// Replaces the default [CircularProgressIndicator] shown during loading
  /// when no [submitButtonBuilder] is provided.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Replaces the default submit button.
  ///
  /// [onTap] is the validated submit handler — call it on press.
  /// [isLoading] reflects the current loading state.
  final Widget Function(
      BuildContext context,
      VoidCallback onTap,
      bool isLoading,
      )? submitButtonBuilder;

  /// Replaces the default mode-switch row ("Don't have an account? Sign up").
  ///
  /// [current] is the active mode. Call the third argument with a new
  /// [AuthMode] to switch modes programmatically.
  final Widget Function(
      BuildContext context,
      AuthMode current,
      void Function(AuthMode) switchMode,
      )? modeSwitcherBuilder;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  late final AuthFlowState _state;

  @override
  void initState() {
    super.initState();
    _state = AuthFlowState(initialMode: widget.initialMode ?? AuthMode.signIn);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  // ── Effective loading/error (external overrides internal) ─────────────────
  bool get _isLoading => widget.isLoading ?? _state.isLoading;
  String? get _errorMessage => widget.errorMessage ?? _state.errorMessage;

  // ── Unified submit runner ─────────────────────────────────────────────────
  Future<void> _run(Future<void> Function() action) async {
    if (_isLoading) return;
    _state
      ..setError(null)
      ..setLoading(true);
    try {
      await action();
    } catch (e) {
      _state.setError(_friendlyError(e));
    } finally {
      _state.setLoading(false);
    }
  }

  String _friendlyError(Object e) {
    // Surface a readable string regardless of exception type.
    final raw = e.toString();
    // Strip common prefixes like "Exception: " or "Error: "
    return raw
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^Error:\s*'), '');
  }

  // ── Default header ────────────────────────────────────────────────────────
  Widget _defaultHeader(AuthMode mode, ThemeData td) {
    final titles = {
      AuthMode.signIn: ('Welcome back', 'Sign in to your account'),
      AuthMode.signUp: ('Create account', 'Join us today'),
      AuthMode.forgotPassword: ('Reset password', 'We\'ll send you a reset link'),
    };
    final (title, subtitle) = titles[mode]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: widget.theme?.titleStyle ??
              td.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: widget.theme?.subtitleStyle ??
              td.textTheme.bodyMedium?.copyWith(
                color: td.colorScheme.onSurface.withOpacity(0.55),
              ),
        ),
      ],
    );
  }

  // ── Default error widget ──────────────────────────────────────────────────
  Widget _defaultError(String error, ThemeData td) {
    final errorColor = widget.theme?.errorColor ?? td.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: errorColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: errorColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(fontSize: 13, color: errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final td = Theme.of(context);
        final mode = _state.mode;
        final afTheme = widget.theme;

        final effectiveLoading = _isLoading;
        final effectiveError = _errorMessage;

        return Container(
          decoration: afTheme?.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────────────────
              widget.headerBuilder != null
                  ? widget.headerBuilder!(context, mode)
                  : _defaultHeader(mode, td),
              const SizedBox(height: 28),

              // ── Error message ────────────────────────────────────────────
              AnimatedSize(
                duration: afTheme?.effectiveTransitionDuration ??
                    const Duration(milliseconds: 320),
                curve: afTheme?.effectiveTransitionCurve ?? Curves.easeInOut,
                child: effectiveError != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: widget.errorBuilder != null
                            ? widget.errorBuilder!(context, effectiveError)
                            : _defaultError(effectiveError, td),
                      )
                    : const SizedBox.shrink(),
              ),

              // ── Animated form switcher ────────────────────────────────────
              AnimatedSwitcher(
                duration: afTheme?.effectiveTransitionDuration ??
                    const Duration(milliseconds: 320),
                switchInCurve: afTheme?.effectiveTransitionCurve ?? Curves.easeInOut,
                switchOutCurve: afTheme?.effectiveTransitionCurve ?? Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildForm(mode, effectiveLoading),
              ),

              // ── Footer ───────────────────────────────────────────────────
              if (widget.footerBuilder != null) ...[
                const SizedBox(height: 16),
                widget.footerBuilder!(context, mode),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(AuthMode mode, bool isLoading) {
    switch (mode) {
      case AuthMode.signIn:
        return AuthFormSignIn(
          key: const ValueKey(AuthMode.signIn),
          isLoading: isLoading,
          theme: widget.theme,
          onSwitchMode: _state.setMode,
          submitButtonBuilder: widget.submitButtonBuilder,
          modeSwitcherBuilder: widget.modeSwitcherBuilder,
          onSubmit: (email, password) => _run(
            () => widget.onSignIn(email, password),
          ),
        );

      case AuthMode.signUp:
        return AuthFormSignUp(
          key: const ValueKey(AuthMode.signUp),
          isLoading: isLoading,
          theme: widget.theme,
          onSwitchMode: _state.setMode,
          submitButtonBuilder: widget.submitButtonBuilder,
          modeSwitcherBuilder: widget.modeSwitcherBuilder,
          onSubmit: (email, password, name) => _run(
            () => widget.onSignUp(email, password, name),
          ),
        );

      case AuthMode.forgotPassword:
        return AuthFormForgotPassword(
          key: const ValueKey(AuthMode.forgotPassword),
          isLoading: isLoading,
          theme: widget.theme,
          onSwitchMode: _state.setMode,
          submitButtonBuilder: widget.submitButtonBuilder,
          modeSwitcherBuilder: widget.modeSwitcherBuilder,
          onSubmit: (email) => _run(
            () => widget.onForgotPassword(email),
          ),
        );
    }
  }
}
