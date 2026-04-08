import 'package:flutter/material.dart';
import 'auth_flow_fields.dart';
import 'auth_flow_theme.dart';
import 'auth_mode.dart';

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
    this.submitButtonBuilder,
    this.modeSwitcherBuilder,
  });

  final Future<void> Function(String email, String password, String name)
      onSubmit;
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
  State<AuthFormSignUp> createState() => _AuthFormSignUpState();
}

class _AuthFormSignUpState extends State<AuthFormSignUp> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
          _emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
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
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
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
