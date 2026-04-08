/// The three authentication modes supported by [AuthFlow].
enum AuthMode {
  /// Sign in with email and password.
  signIn,

  /// Create a new account with name, email, and password.
  signUp,

  /// Request a password reset link via email.
  forgotPassword,
}
