import 'package:flutter/foundation.dart';
import 'auth_mode.dart';

/// Internal state for [AuthFlow].
///
/// Holds the current [AuthMode], loading flag, and error message.
/// Exposed as a [ChangeNotifier] so the widget tree rebuilds efficiently.
class AuthFlowState extends ChangeNotifier {
  AuthFlowState({AuthMode initialMode = AuthMode.signIn})
      : _mode = initialMode;

  AuthMode _mode;
  bool _isLoading = false;
  String? _errorMessage;

  AuthMode get mode => _mode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setMode(AuthMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _errorMessage = null; // clear errors on mode switch
    notifyListeners();
  }

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    if (_errorMessage == message) return;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() => setError(null);
}
