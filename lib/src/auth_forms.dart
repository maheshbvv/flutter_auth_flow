import 'package:flutter/material.dart';
import 'auth_flow_fields.dart';
import 'auth_flow_theme.dart';
import 'auth_mode.dart';
import 'password_policy.dart';
import 'password_strength.dart';
import 'pwned_password_checker.dart';

/// The sign-in form rendered inside [AuthFlow] when mode is [AuthMode.signIn].
class AuthFormSignIn extends StatefulWidget {
  const AuthFormSignIn({
    super.key,
    required this.onSubmit,
    required this.onSwitchMode,
    required this.authFlowType,
    this.isLoading = false,
    this.theme,
    this.submitButtonBuilder,
    this.modeSwitcherBuilder,
  });

  final Future<void> Function(String email, String password) onSubmit;
  final void Function(AuthMode) onSwitchMode;
  final AuthFlowType authFlowType;
  final bool isLoading;
  final AuthFlowTheme? theme;
  final Widget Function(BuildContext, VoidCallback onTap, bool isLoading)?
      submitButtonBuilder;
  final Widget Function(
          BuildContext, AuthMode current, void Function(AuthMode))?
      modeSwitcherBuilder;

  @override
  State<AuthFormSignIn> createState() => _AuthFormSignInState();
}

class _AuthFormSignInState extends State<AuthFormSignIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailCtrl.text.trim(), _passwordCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final td = Theme.of(context);
    final afTheme = widget.theme;
    final primaryColor = afTheme?.primaryColor ?? td.colorScheme.primary;

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthFlowTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              theme: afTheme,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFlowTextField(
              controller: _passwordCtrl,
              label: 'Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              theme: afTheme,
              obscureToggle: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Forgot password link (only show if enabled)
            if (widget.authFlowType.hasMode(AuthMode.forgotPassword))
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => widget.onSwitchMode(AuthMode.forgotPassword),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: afTheme?.linkStyle ??
                        TextStyle(fontSize: 13, color: primaryColor),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Submit button
            widget.submitButtonBuilder != null
                ? widget.submitButtonBuilder!(
                    context, _submit, widget.isLoading)
                : _DefaultSubmitButton(
                    label: 'Sign In',
                    isLoading: widget.isLoading,
                    onTap: _submit,
                    theme: afTheme,
                    primaryColor: primaryColor,
                  ),
            const SizedBox(height: 24),

            // Mode switcher (only show if sign up is enabled)
            if (widget.authFlowType.hasMode(AuthMode.signUp))
              widget.modeSwitcherBuilder != null
                  ? widget.modeSwitcherBuilder!(
                      context, AuthMode.signIn, widget.onSwitchMode)
                  : _DefaultModeSwitcher(
                      prompt: "Don't have an account?",
                      actionLabel: 'Sign up',
                      onTap: () => widget.onSwitchMode(AuthMode.signUp),
                      primaryColor: primaryColor,
                      theme: afTheme,
                    ),
          ],
        ),
      ),
    );
  }
}

// ─── Sign Up Form ─────────────────────────────────────────────────────────────

/// The sign-up form rendered inside [AuthFlow] when mode is [AuthMode.signUp].
class AuthFormSignUp extends StatefulWidget {
  const AuthFormSignUp({
    super.key,
    required this.onSubmit,
    required this.onSwitchMode,
    required this.authFlowType,
    this.isLoading = false,
    this.theme,
    this.passwordPolicy,
    this.submitButtonBuilder,
    this.modeSwitcherBuilder,
  });

  final Future<void> Function(String email, String password, String name)
      onSubmit;
  final void Function(AuthMode) onSwitchMode;
  final AuthFlowType authFlowType;
  final bool isLoading;
  final AuthFlowTheme? theme;
  final PasswordPolicy? passwordPolicy;
  final Widget Function(BuildContext, VoidCallback onTap, bool isLoading)?
      submitButtonBuilder;
  final Widget Function(
          BuildContext, AuthMode current, void Function(AuthMode))?
      modeSwitcherBuilder;

  @override
  State<AuthFormSignUp> createState() => _AuthFormSignUpState();
}

class _AuthFormSignUpState extends State<AuthFormSignUp> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late PasswordStrengthResult _strengthResult;
  bool _isCheckingPwnedPassword = false;
  String? _lastCheckedPassword;
  String? _pwnedWarning;
  PasswordBreachCheckResult? _pwnedResult;

  PasswordPolicy? get _passwordPolicy => widget.passwordPolicy;
  int get _minimumPasswordLength => _passwordPolicy?.minLength ?? 8;
  bool get _showsStrengthIndicator =>
      _passwordPolicy?.showStrengthIndicator ?? false;
  bool get _checksPwnedPasswords => _passwordPolicy?.enablePwnedCheck ?? false;
  bool get _blocksPwnedPasswords =>
      _passwordPolicy?.blockPwnedPasswords ?? true;

  @override
  void initState() {
    super.initState();
    _strengthResult = evaluatePasswordStrength(
      password: '',
      email: '',
      name: '',
      minLength: _minimumPasswordLength,
    );
    _nameCtrl.addListener(_handleStrengthContextChanged);
    _emailCtrl.addListener(_handleStrengthContextChanged);
    _passwordCtrl.addListener(_handlePasswordChanged);
    _passwordFocusNode.addListener(_handlePasswordFocusChanged);
  }

  @override
  void dispose() {
    _passwordFocusNode
      ..removeListener(_handlePasswordFocusChanged)
      ..dispose();
    _nameCtrl.removeListener(_handleStrengthContextChanged);
    _emailCtrl.removeListener(_handleStrengthContextChanged);
    _passwordCtrl.removeListener(_handlePasswordChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AuthFormSignUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passwordPolicy != widget.passwordPolicy) {
      _strengthResult = evaluatePasswordStrength(
        password: _passwordCtrl.text,
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        minLength: _minimumPasswordLength,
      );
      _clearPwnedState();
    }
  }

  void _handleStrengthContextChanged() {
    if (_passwordPolicy == null) return;
    setState(() {
      _strengthResult = evaluatePasswordStrength(
        password: _passwordCtrl.text,
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        minLength: _minimumPasswordLength,
      );
    });
  }

  void _handlePasswordChanged() {
    if (_passwordPolicy == null) return;
    final password = _passwordCtrl.text;
    setState(() {
      _strengthResult = evaluatePasswordStrength(
        password: password,
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        minLength: _minimumPasswordLength,
      );
      if (_lastCheckedPassword != password) {
        _clearPwnedState();
      }
    });
  }

  void _handlePasswordFocusChanged() {
    if (!_passwordFocusNode.hasFocus) {
      _checkPwnedPasswordIfNeeded();
    }
  }

  void _clearPwnedState() {
    _isCheckingPwnedPassword = false;
    _lastCheckedPassword = null;
    _pwnedWarning = null;
    _pwnedResult = null;
  }

  Future<void> _checkPwnedPasswordIfNeeded() async {
    if (!_checksPwnedPasswords || _isCheckingPwnedPassword) return;

    final password = _passwordCtrl.text;
    if (password.isEmpty || password.length < _minimumPasswordLength) {
      if (_lastCheckedPassword != null ||
          _pwnedResult != null ||
          _pwnedWarning != null ||
          _isCheckingPwnedPassword) {
        setState(_clearPwnedState);
      }
      return;
    }
    if (_lastCheckedPassword == password) return;

    setState(() {
      _isCheckingPwnedPassword = true;
      _pwnedWarning = null;
    });

    try {
      final checker =
          _passwordPolicy?.breachChecker ?? checkPasswordAgainstPwnedPasswords;
      final result = await checker(password);
      if (!mounted || _passwordCtrl.text != password) return;
      setState(() {
        _lastCheckedPassword = password;
        _pwnedResult = result;
        _pwnedWarning = null;
        _isCheckingPwnedPassword = false;
      });
    } catch (_) {
      if (!mounted || _passwordCtrl.text != password) return;
      setState(() {
        _lastCheckedPassword = password;
        _pwnedResult = null;
        _pwnedWarning =
            "Couldn't verify breach exposure right now. You can still continue.";
        _isCheckingPwnedPassword = false;
      });
    }
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _checkPwnedPasswordIfNeeded();
    if (!mounted) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_blocksPwnedPasswords && _pwnedResult?.isPwned == true) {
      return;
    }

    widget.onSubmit(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _nameCtrl.text.trim(),
    );
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < _minimumPasswordLength) {
      return 'Minimum $_minimumPasswordLength characters';
    }
    if (_blocksPwnedPasswords &&
        _pwnedResult?.isPwned == true &&
        _lastCheckedPassword == value) {
      return 'This password has appeared in data breaches';
    }
    return null;
  }

  bool get _showsPasswordFeedback {
    if (_passwordCtrl.text.isEmpty) return false;
    return _showsStrengthIndicator ||
        _checksPwnedPasswords ||
        _pwnedWarning != null ||
        _pwnedResult != null;
  }

  @override
  Widget build(BuildContext context) {
    final td = Theme.of(context);
    final afTheme = widget.theme;
    final primaryColor = afTheme?.primaryColor ?? td.colorScheme.primary;

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthFlowTextField(
              controller: _nameCtrl,
              label: 'Full name',
              hint: 'Jane Doe',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              theme: afTheme,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFlowTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
              theme: afTheme,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFlowTextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocusNode,
              label: 'Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              theme: afTheme,
              obscureToggle: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: _passwordValidator,
            ),
            if (_showsPasswordFeedback) ...[
              const SizedBox(height: 12),
              _PasswordFeedbackPanel(
                strengthResult: _strengthResult,
                showStrengthIndicator: _showsStrengthIndicator,
                isCheckingPwnedPassword: _isCheckingPwnedPassword,
                pwnedResult: _pwnedResult,
                pwnedWarning: _pwnedWarning,
                theme: afTheme,
              ),
            ],
            const SizedBox(height: 16),
            AuthFlowTextField(
              controller: _confirmCtrl,
              label: 'Confirm password',
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              theme: afTheme,
              onFieldSubmitted: (_) => _submit(),
              obscureToggle: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != _passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 24),
            widget.submitButtonBuilder != null
                ? widget.submitButtonBuilder!(
                    context, _submit, widget.isLoading)
                : _DefaultSubmitButton(
                    label: 'Create Account',
                    isLoading: widget.isLoading,
                    onTap: _submit,
                    theme: afTheme,
                    primaryColor: primaryColor,
                  ),
            const SizedBox(height: 24),

            // Mode switcher (only show if sign in is enabled)
            if (widget.authFlowType.hasMode(AuthMode.signIn))
              widget.modeSwitcherBuilder != null
                  ? widget.modeSwitcherBuilder!(
                      context, AuthMode.signUp, widget.onSwitchMode)
                  : _DefaultModeSwitcher(
                      prompt: 'Already have an account?',
                      actionLabel: 'Sign in',
                      onTap: () => widget.onSwitchMode(AuthMode.signIn),
                      primaryColor: primaryColor,
                      theme: afTheme,
                    ),
          ],
        ),
      ),
    );
  }
}

// ─── Forgot Password Form ─────────────────────────────────────────────────────

/// The forgot-password form rendered when mode is [AuthMode.forgotPassword].
class AuthFormForgotPassword extends StatefulWidget {
  const AuthFormForgotPassword({
    super.key,
    required this.onSubmit,
    required this.onSwitchMode,
    required this.authFlowType,
    this.isLoading = false,
    this.theme,
    this.submitButtonBuilder,
    this.modeSwitcherBuilder,
  });

  final Future<void> Function(String email) onSubmit;
  final void Function(AuthMode) onSwitchMode;
  final AuthFlowType authFlowType;
  final bool isLoading;
  final AuthFlowTheme? theme;
  final Widget Function(BuildContext, VoidCallback onTap, bool isLoading)?
      submitButtonBuilder;
  final Widget Function(
          BuildContext, AuthMode current, void Function(AuthMode))?
      modeSwitcherBuilder;

  @override
  State<AuthFormForgotPassword> createState() => _AuthFormForgotPasswordState();
}

class _AuthFormForgotPasswordState extends State<AuthFormForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final td = Theme.of(context);
    final afTheme = widget.theme;
    final primaryColor = afTheme?.primaryColor ?? td.colorScheme.primary;

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthFlowTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _submit(),
              theme: afTheme,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            widget.submitButtonBuilder != null
                ? widget.submitButtonBuilder!(
                    context, _submit, widget.isLoading)
                : _DefaultSubmitButton(
                    label: 'Send Reset Link',
                    isLoading: widget.isLoading,
                    onTap: _submit,
                    theme: afTheme,
                    primaryColor: primaryColor,
                  ),
            const SizedBox(height: 24),

            // Mode switcher (only show if sign in is enabled)
            if (widget.authFlowType.hasMode(AuthMode.signIn))
              widget.modeSwitcherBuilder != null
                  ? widget.modeSwitcherBuilder!(
                      context, AuthMode.forgotPassword, widget.onSwitchMode)
                  : _DefaultModeSwitcher(
                      prompt: 'Remember your password?',
                      actionLabel: 'Sign in',
                      onTap: () => widget.onSwitchMode(AuthMode.signIn),
                      primaryColor: primaryColor,
                      theme: afTheme,
                    ),
          ],
        ),
      ),
    );
  }
}

class _PasswordFeedbackPanel extends StatelessWidget {
  const _PasswordFeedbackPanel({
    required this.strengthResult,
    required this.showStrengthIndicator,
    required this.isCheckingPwnedPassword,
    required this.pwnedResult,
    required this.pwnedWarning,
    this.theme,
  });

  final PasswordStrengthResult strengthResult;
  final bool showStrengthIndicator;
  final bool isCheckingPwnedPassword;
  final PasswordBreachCheckResult? pwnedResult;
  final String? pwnedWarning;
  final AuthFlowTheme? theme;

  @override
  Widget build(BuildContext context) {
    final td = Theme.of(context);
    final textColor = td.colorScheme.onSurface.withOpacity(0.7);
    final strengthColor = _strengthColor(td);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: td.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius:
            theme?.effectiveInputBorderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showStrengthIndicator) ...[
              Row(
                children: [
                  Text(
                    'Strength',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    strengthResult.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: strengthResult.progress,
                  backgroundColor: td.colorScheme.outline.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strengthResult.helperText,
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ],
            if (isCheckingPwnedPassword ||
                pwnedResult != null ||
                pwnedWarning != null) ...[
              if (showStrengthIndicator) const SizedBox(height: 12),
              _PasswordFeedbackStatus(
                isCheckingPwnedPassword: isCheckingPwnedPassword,
                pwnedResult: pwnedResult,
                pwnedWarning: pwnedWarning,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _strengthColor(ThemeData td) {
    return switch (strengthResult.level) {
      PasswordStrength.weak => td.colorScheme.error,
      PasswordStrength.fair => Colors.orange.shade700,
      PasswordStrength.good => td.colorScheme.primary,
      PasswordStrength.strong => Colors.green.shade700,
    };
  }
}

class _PasswordFeedbackStatus extends StatelessWidget {
  const _PasswordFeedbackStatus({
    required this.isCheckingPwnedPassword,
    required this.pwnedResult,
    required this.pwnedWarning,
  });

  final bool isCheckingPwnedPassword;
  final PasswordBreachCheckResult? pwnedResult;
  final String? pwnedWarning;

  @override
  Widget build(BuildContext context) {
    final td = Theme.of(context);

    if (isCheckingPwnedPassword) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Checking breach exposure...',
            style: TextStyle(
              fontSize: 12,
              color: td.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    if (pwnedResult?.isPwned == true) {
      final exposureCount = pwnedResult!.exposureCount;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: td.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Found in breach data ${_formatExposureCount(exposureCount)}. Choose a different password.',
              style: TextStyle(
                fontSize: 12,
                color: td.colorScheme.error,
              ),
            ),
          ),
        ],
      );
    }

    if (pwnedWarning != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pwnedWarning!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      );
    }

    if (pwnedResult != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 16,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No match found in the Pwned Passwords dataset.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _formatExposureCount(int count) {
    if (count == 1) return '1 time';
    return '$count times';
  }
}

// ─── Default Submit Button ─────────────────────────────────────────────────────
// ─── Shared internal widgets ──────────────────────────────────────────────────

class _DefaultSubmitButton extends StatelessWidget {
  const _DefaultSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    required this.primaryColor,
    this.theme,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final Color primaryColor;
  final AuthFlowTheme? theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: theme?.buttonStyle ??
            ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryColor.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: theme?.effectiveButtonBorderRadius ??
                    BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: theme?.buttonTextStyle ??
                    const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ),
      ),
    );
  }
}

class _DefaultModeSwitcher extends StatelessWidget {
  const _DefaultModeSwitcher({
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
    required this.primaryColor,
    this.theme,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;
  final Color primaryColor;
  final AuthFlowTheme? theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$prompt ',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: theme?.linkStyle ??
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
          ),
        ),
      ],
    );
  }
}
