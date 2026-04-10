import 'package:flutter/foundation.dart';

typedef PasswordBreachChecker = Future<PasswordBreachCheckResult> Function(
  String password,
);

@immutable
class PasswordPolicy {
  const PasswordPolicy({
    this.showStrengthIndicator = true,
    this.minLength = 8,
    this.enablePwnedCheck = false,
    this.blockPwnedPasswords = true,
    this.breachChecker,
  }) : assert(minLength > 0, 'minLength must be greater than 0');

  /// Shows the built-in password strength meter below the sign-up password field.
  final bool showStrengthIndicator;

  /// Minimum number of characters required before sign-up can proceed.
  final int minLength;

  /// When true, checks the password against the free Pwned Passwords API.
  final bool enablePwnedCheck;

  /// Prevents sign-up when the breach check confirms the password is exposed.
  final bool blockPwnedPasswords;

  /// Override the default breach checker. Useful for tests or custom services.
  final PasswordBreachChecker? breachChecker;
}

@immutable
class PasswordBreachCheckResult {
  const PasswordBreachCheckResult({
    required this.isPwned,
    this.exposureCount = 0,
  }) : assert(exposureCount >= 0, 'exposureCount must be positive');

  const PasswordBreachCheckResult.safe()
      : isPwned = false,
        exposureCount = 0;

  const PasswordBreachCheckResult.pwned({required int exposureCount})
      : this(isPwned: true, exposureCount: exposureCount);

  final bool isPwned;
  final int exposureCount;
}
