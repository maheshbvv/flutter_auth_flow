import 'package:flutter/material.dart';
import 'auth_flow_state.dart';
import 'auth_flow_theme.dart';
import 'auth_forms.dart';
import 'auth_mode.dart';

export 'auth_mode.dart' show AuthMode, AuthFlowType;

/// A single widget that handles Sign In, Sign Up, and Forgot Password.
///
/// Drop this into any screen and wire up only the async callbacks you need.
/// The widget manages its own loading state, error display, mode transitions,
/// and form validation — all internally.
///
/// ## Sign In Only
/// ```dart
/// AuthFlow(
///   authFlowType: AuthFlowType.signInOnly(),
///   onSignIn: (email, password) async {
///     await FirebaseAuth.instance.signInWithEmailAndPassword(
///       email: email, password: password,
///     );
///   },
///   onSignInSuccess: () => Navigator.pushReplacement(...),
/// )
/// ```
///
/// ## Sign In + Sign Up (no forgot password)
/// ```dart
/// AuthFlow(
///   authFlowType: AuthFlowType.signInAndSignUp(),
///   onSignIn: (email, password) async { ... },
///   onSignUp: (email, password, name) async { ... },
///   onSignInSuccess: () => goToHome(),
///   onSignUpSuccess: () => goToHome(),
/// )
/// ```
///
/// ## All Modes (default)
/// ```dart
/// AuthFlow(
///   // authFlowType defaults to AuthFlowType.all
///   onSignIn: (email, password) async { ... },
///   onSignUp: (email, password, name) async { ... },
///   onForgotPassword: (email) async { ... },
///   onSignInSuccess: () => goToHome(),
///   onSignUpSuccess: () => goToHome(),
///   onForgotPasswordSuccess: () => showSuccess(),
/// )
/// ```
///
/// ## With Full Customization
/// ```dart
/// AuthFlow(
///   authFlowType: AuthFlowType.all(),
///   onSignIn: ...,
///   onSignUp: ...,
///   onForgotPassword: ...,
///   theme: AuthFlowTheme(primaryColor: Colors.indigo),
///   headerBuilder: (ctx, mode) => MyBrandedHeader(mode: mode),
///   submitButtonBuilder: (ctx, onTap, loading) => MyButton(...),
/// )
/// ```
class AuthFlow extends StatefulWidget {
  const AuthFlow({
    super.key,

    // ── Flow configuration ───────────────────────────────
    /// Specifies which authentication modes are enabled.
    /// Defaults to [AuthFlowType.all] (all three modes available).
    this.authFlowType = AuthFlowType.all,

    // ── Authentication callbacks ──────────────────────────
    /// Called when the user submits the sign-in form.
    /// Required if [authFlowType] includes [AuthMode.signIn].
    final Future<void> Function(String email, String password)? onSignIn,

    /// Called when the user submits the sign-up form.
    /// Required if [authFlowType] includes [AuthMode.signUp].
    final Future<void> Function(String email, String password, String name)?
        onSignUp,

    /// Called when the user submits the forgot-password form.
    /// Required if [authFlowType] includes [AuthMode.forgotPassword].
    final Future<void> Function(String email)? onForgotPassword,

    // ── Success callbacks ─────────────────────────────────
    /// Called when sign-in completes successfully.
    /// Only used if [authFlowType] includes [AuthMode.signIn].
    final void Function()? onSignInSuccess,

    /// Called when sign-up completes successfully.
    /// Only used if [authFlowType] includes [AuthMode.signUp].
    final void Function()? onSignUpSuccess,

    /// Called when password reset email is sent successfully.
    /// Only used if [authFlowType] includes [AuthMode.forgotPassword].
    final void Function()? onForgotPasswordSuccess,

    // ── Optional state overrides ──────────────────────────
    /// When non-null, overrides the widget's internal loading state.
    /// Use this when you manage state externally (BLoC, Riverpod, Provider).
    this.isLoading,

    /// When non-null, overrides the widget's internal error message.
    this.errorMessage,

    /// The mode to start in. Defaults to the default mode of [authFlowType].
    this.initialMode,

    // ── Theme ─────────────────────────────────────────────
    /// Fine-grained visual customization. See [AuthFlowTheme] for all options.
    this.theme,

    // ── Builders ───────────────────────────────────────────
    /// Replaces the default title + subtitle header area.
    ///
    /// Receives the current [AuthMode] so you can render mode-specific branding.
    this.headerBuilder,

    /// Rendered below the form and mode-switcher links.
    this.footerBuilder,

    /// Replaces the default inline error message widget.
    this.errorBuilder,

    /// Replaces the default [CircularProgressIndicator] shown during loading
    /// when no [submitButtonBuilder] is provided.
    this.loadingBuilder,

    /// Replaces the default submit button.
    ///
    /// [onTap] is the validated submit handler — call it on press.
    /// [isLoading] reflects the current loading state.
    this.submitButtonBuilder,

    /// Replaces the default mode-switch row.
    ///
    /// [current] is the active mode. Call the third argument with a new
    /// [AuthMode] to switch modes programmatically.
    this.modeSwitcherBuilder,
  })  : _onSignIn = onSignIn,
        _onSignUp = onSignUp,
        _onForgotPassword = onForgotPassword,
        _onSignInSuccess = onSignInSuccess,
        _onSignUpSuccess = onSignUpSuccess,
        _onForgotPasswordSuccess = onForgotPasswordSuccess;

  // ── Private callback storage ─────────────────────────────
  final Future<void> Function(String email, String password)? _onSignIn;
  final Future<void> Function(String email, String password, String name)?
      _onSignUp;
  final Future<void> Function(String email)? _onForgotPassword;
  final void Function()? _onSignInSuccess;
  final void Function()? _onSignUpSuccess;
  final void Function()? _onForgotPasswordSuccess;

  // ── Flow configuration ───────────────────────────────────
  final AuthFlowType authFlowType;

  // ── State overrides ──────────────────────────────────────
  final bool? isLoading;
  final String? errorMessage;
  final AuthMode? initialMode;

  // ── Theme ────────────────────────────────────────────────
  final AuthFlowTheme? theme;

  // ── Builders ────────────────────────────────────────────
  final Widget Function(BuildContext context, AuthMode mode)? headerBuilder;
  final Widget Function(BuildContext context, AuthMode mode)? footerBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(
    BuildContext context,
    VoidCallback onTap,
    bool isLoading,
  )? submitButtonBuilder;
  final Widget Function(
    BuildContext context,
    AuthMode current,
    void Function(AuthMode) switchMode,
  )? modeSwitcherBuilder;

  /// Returns true if sign-in mode is enabled.
  bool get hasSignIn => authFlowType.hasMode(AuthMode.signIn);

  /// Returns true if sign-up mode is enabled.
  bool get hasSignUp => authFlowType.hasMode(AuthMode.signUp);

  /// Returns true if forgot password mode is enabled.
  bool get hasForgotPassword => authFlowType.hasMode(AuthMode.forgotPassword);

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  late final AuthFlowState _state;

  @override
  void initState() {
    super.initState();
    // Use explicit initialMode, or fall back to the authFlowType's default
    final initialMode = widget.initialMode ?? widget.authFlowType.defaultMode;
    _state = AuthFlowState(initialMode: initialMode);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  // ── Effective loading/error (external overrides internal) ─────────────────
  bool get _isLoading => widget.isLoading ?? _state.isLoading;
  String? get _errorMessage => widget.errorMessage ?? _state.errorMessage;

  // ── Unified submit runner ────────────────────────────────────────────────
  Future<void> _run(Future<void> Function() action,
      [void Function()? onSuccess]) async {
    if (_isLoading) return;
    _state
      ..setError(null)
      ..setLoading(true);
    try {
      await action();
      onSuccess?.call();
    } catch (e) {
      _state.setError(_friendlyError(e));
    } finally {
      _state.setLoading(false);
    }
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    return raw
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^Error:\s*'), '');
  }

  // ── Default header ────────────────────────────────────────────────────────
  Widget _defaultHeader(AuthMode mode, ThemeData td) {
    final titles = {
      AuthMode.signIn: ('Welcome back', 'Sign in to your account'),
      AuthMode.signUp: ('Create account', 'Join us today'),
      AuthMode.forgotPassword: (
        'Reset password',
        "We'll send you a reset link"
      ),
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

  // ── Default error widget ───────────────────────────────────────────────────
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
              // ── Header ─────────────────────────────────────────────────
              widget.headerBuilder != null
                  ? widget.headerBuilder!(context, mode)
                  : _defaultHeader(mode, td),
              const SizedBox(height: 28),

              // ── Error message ─────────────────────────────────────────
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

              // ── Animated form switcher ────────────────────────────────
              AnimatedSwitcher(
                duration: afTheme?.effectiveTransitionDuration ??
                    const Duration(milliseconds: 320),
                switchInCurve:
                    afTheme?.effectiveTransitionCurve ?? Curves.easeInOut,
                switchOutCurve:
                    afTheme?.effectiveTransitionCurve ?? Curves.easeInOut,
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

              // ── Footer ────────────────────────────────────────────────
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
    // Build the appropriate form based on the current mode
    return switch (mode) {
      AuthMode.signIn => AuthFormSignIn(
          key: const ValueKey(AuthMode.signIn),
          isLoading: isLoading,
          theme: widget.theme,
          onSwitchMode: _state.setMode,
          submitButtonBuilder: widget.submitButtonBuilder,
          modeSwitcherBuilder: widget.modeSwitcherBuilder,
          authFlowType: widget.authFlowType,
          onSubmit: (email, password) => _run(
            () => widget._onSignIn!(email, password),
            widget._onSignInSuccess,
          ),
        ),
      AuthMode.signUp => AuthFormSignUp(
          key: const ValueKey(AuthMode.signUp),
          isLoading: isLoading,
          theme: widget.theme,
          onSwitchMode: _state.setMode,
          submitButtonBuilder: widget.submitButtonBuilder,
          modeSwitcherBuilder: widget.modeSwitcherBuilder,
          authFlowType: widget.authFlowType,
          onSubmit: (email, password, name) => _run(
            () => widget._onSignUp!(email, password, name),
            widget._onSignUpSuccess,
          ),
        ),
      AuthMode.forgotPassword => AuthFormForgotPassword(
          key: const ValueKey(AuthMode.forgotPassword),
          isLoading: isLoading,
          theme: widget.theme,
          onSwitchMode: _state.setMode,
          submitButtonBuilder: widget.submitButtonBuilder,
          modeSwitcherBuilder: widget.modeSwitcherBuilder,
          authFlowType: widget.authFlowType,
          onSubmit: (email) => _run(
            () => widget._onForgotPassword!(email),
            widget._onForgotPasswordSuccess,
          ),
        ),
    };
  }
}
