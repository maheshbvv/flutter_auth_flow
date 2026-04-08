/// Authentication modes supported by the auth flow widgets.
enum AuthMode {
  /// Sign in with email and password.
  signIn,

  /// Create a new account with name, email, and password.
  signUp,

  /// Request a password reset link via email.
  forgotPassword,
}

/// Specifies which authentication modes are enabled in the auth flow.
///
/// Use this to create a modular auth flow where users only see
/// the modes they need.
///
/// ## Examples
///
/// Enable only Sign In:
/// ```dart
/// AuthFlowType.signInOnly()
/// ```
///
/// Enable Sign In and Sign Up (no forgot password):
/// ```dart
/// AuthFlowType(enabledModes: {AuthMode.signIn, AuthMode.signUp})
/// ```
///
/// Enable all modes (default):
/// ```dart
/// AuthFlowType.all()
/// ```
class AuthFlowType {
  /// The set of authentication modes that are enabled.
  final Set<AuthMode> enabledModes;

  /// Creates an AuthFlowType with the specified enabled modes.
  ///
  /// At least one mode must be enabled. By default, all modes are enabled.
  const AuthFlowType({
    Set<AuthMode>? enabledModes,
  }) : enabledModes = enabledModes ??
            const {
              AuthMode.signIn,
              AuthMode.signUp,
              AuthMode.forgotPassword,
            };

  /// Pre-configured type for Sign In only.
  const AuthFlowType.signInOnly() : enabledModes = const {AuthMode.signIn};

  /// Pre-configured type for Sign Up only.
  const AuthFlowType.signUpOnly() : enabledModes = const {AuthMode.signUp};

  /// Pre-configured type for Forgot Password only.
  const AuthFlowType.forgotPasswordOnly()
      : enabledModes = const {AuthMode.forgotPassword};

  /// Pre-configured type for Sign In and Sign Up (no forgot password).
  const AuthFlowType.signInAndSignUp()
      : enabledModes = const {AuthMode.signIn, AuthMode.signUp};

  /// Pre-configured type for Sign In and Forgot Password (no sign up).
  const AuthFlowType.signInAndForgotPassword()
      : enabledModes = const {AuthMode.signIn, AuthMode.forgotPassword};

  /// Pre-configured type for Sign Up and Forgot Password (no sign in).
  const AuthFlowType.signUpAndForgotPassword()
      : enabledModes = const {AuthMode.signUp, AuthMode.forgotPassword};

  /// Pre-configured type with all modes enabled (the default).
  static const AuthFlowType all = AuthFlowType();

  /// Returns true if the given mode is enabled.
  bool hasMode(AuthMode mode) => enabledModes.contains(mode);

  /// Returns true if only one mode is enabled.
  bool get isSingleMode => enabledModes.length == 1;

  /// Returns the single enabled mode if only one mode is enabled.
  /// Returns null if multiple or no modes are enabled.
  AuthMode? get singleMode => isSingleMode ? enabledModes.first : null;

  /// Returns the default mode to show when there are multiple modes.
  /// Priority: signIn > signUp > forgotPassword
  AuthMode get defaultMode {
    if (enabledModes.contains(AuthMode.signIn)) return AuthMode.signIn;
    if (enabledModes.contains(AuthMode.signUp)) return AuthMode.signUp;
    return AuthMode.forgotPassword;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthFlowType) return false;
    if (enabledModes.length != other.enabledModes.length) return false;
    return enabledModes.containsAll(other.enabledModes);
  }

  @override
  int get hashCode => Object.hashAll(enabledModes);

  @override
  String toString() => 'AuthFlowType($enabledModes)';
}
