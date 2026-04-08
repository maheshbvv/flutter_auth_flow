/// flutter_auth_flow
///
/// A single, fully customizable Flutter widget that handles Sign In,
/// Sign Up, and Forgot Password in one place.
///
/// ## Quick start
/// ```dart
/// import 'package:flutter_auth_flow/flutter_auth_flow.dart';
///
/// AuthFlow(
///   onSignIn: (email, password) async { ... },
///   onSignUp: (email, password, name) async { ... },
///   onForgotPassword: (email) async { ... },
/// )
/// ```
library flutter_auth_flow;

export 'src/auth_flow_widget.dart' show AuthFlow;
export 'src/auth_flow_theme.dart' show AuthFlowTheme;
export 'src/auth_mode.dart' show AuthMode;
