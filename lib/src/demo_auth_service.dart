import 'dart:convert';
import 'package:flutter/material.dart';

String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  return base64Encode(bytes);
}

class _DemoUser {
  const _DemoUser({
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.createdAt,
  });
  final String email;
  final String passwordHash;
  final String name;
  final DateTime createdAt;
}

class DemoAuthResult {
  const DemoAuthResult({required this.email, required this.name});
  final String email;
  final String name;
}

class DemoAuthException implements Exception {
  const DemoAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class DemoAuthService extends ChangeNotifier {
  DemoAuthService();

  final Map<String, _DemoUser> _users = {};

  Future<DemoAuthResult> signIn(String email, String password) async {
    await Future.delayed(_randomDelay());
    final normalizedEmail = email.toLowerCase().trim();
    final user = _users[normalizedEmail];
    if (user == null || user.passwordHash != _hashPassword(password)) {
      throw const DemoAuthException('Invalid email or password');
    }
    return DemoAuthResult(email: user.email, name: user.name);
  }

  Future<DemoAuthResult> signUp(
      String email, String password, String name) async {
    await Future.delayed(_randomDelay());
    final normalizedEmail = email.toLowerCase().trim();
    if (!_isValidEmail(normalizedEmail)) {
      throw const DemoAuthException('Please enter a valid email address');
    }
    if (password.length < 8) {
      throw const DemoAuthException('Password must be at least 8 characters');
    }
    if (_users.containsKey(normalizedEmail)) {
      throw const DemoAuthException('Email already in use');
    }
    final user = _DemoUser(
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    _users[normalizedEmail] = user;
    return DemoAuthResult(email: user.email, name: user.name);
  }

  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    final normalizedEmail = email.toLowerCase().trim();
    if (!_isValidEmail(normalizedEmail)) {
      throw const DemoAuthException('Please enter a valid email address');
    }
  }

  /// Clears all registered users from memory.
  void clearUsers() => _users.clear();

  /// Returns the number of registered users.
  int get userCount => _users.length;

  Duration _randomDelay() {
    final ms = 1000 + (DateTime.now().millisecondsSinceEpoch % 1000);
    return Duration(milliseconds: ms);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}

class DemoAuthServiceProvider extends StatefulWidget {
  const DemoAuthServiceProvider({
    super.key,
    required this.service,
    required this.child,
  });

  final DemoAuthService service;
  final Widget child;

  static DemoAuthService of(BuildContext context) {
    final provider =
        context.findAncestorWidgetOfExactType<DemoAuthServiceProvider>();
    if (provider == null) {
      throw FlutterError(
        'DemoAuthServiceProvider.of() called with no provider in the widget tree.',
      );
    }
    return provider.service;
  }

  static DemoAuthService? maybeOf(BuildContext context) {
    final provider =
        context.findAncestorWidgetOfExactType<DemoAuthServiceProvider>();
    return provider?.service;
  }

  @override
  State<DemoAuthServiceProvider> createState() =>
      _DemoAuthServiceProviderState();
}

class _DemoAuthServiceProviderState extends State<DemoAuthServiceProvider> {
  @override
  Widget build(BuildContext context) => widget.child;
}
