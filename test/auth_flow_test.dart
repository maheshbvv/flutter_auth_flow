import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_flow/flutter_auth_flow.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

AuthFlow _buildWidget({
  Future<void> Function(String, String)? onSignIn,
  Future<void> Function(String, String, String)? onSignUp,
  Future<void> Function(String)? onForgotPassword,
  AuthMode initialMode = AuthMode.signIn,
}) {
  return AuthFlow(
    initialMode: initialMode,
    onSignIn: onSignIn ?? (_, __) async {},
    onSignUp: onSignUp ?? (_, __, ___) async {},
    onForgotPassword: onForgotPassword ?? (_) async {},
  );
}

void main() {
  group('AuthFlow — sign in mode', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('switches to forgot password mode', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('switches to sign up mode', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget()));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);
    });
  });

  group('AuthFlow — sign up mode', () {
    testWidgets('renders name, email, password, confirm fields', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget(initialMode: AuthMode.signUp)));
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
    });

    testWidgets('validates password mismatch', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget(initialMode: AuthMode.signUp)));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full name'), 'Jane');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'jane@test.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm password'), 'different');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('AuthFlow — forgot password mode', () {
    testWidgets('renders email field only', (tester) async {
      await tester
          .pumpWidget(_wrap(_buildWidget(initialMode: AuthMode.forgotPassword)));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Password'), findsNothing);
    });
  });

  group('AuthFlow — error handling', () {
    testWidgets('displays error from thrown exception', (tester) async {
      await tester.pumpWidget(_wrap(_buildWidget(
        onSignIn: (_, __) async => throw Exception('Invalid credentials'),
      )));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'x@x.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'pass1234');
      await tester.tap(find.text('Sign In'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 100)); // complete
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('displays external errorMessage override', (tester) async {
      await tester.pumpWidget(_wrap(AuthFlow(
        onSignIn: (_, __) async {},
        onSignUp: (_, __, ___) async {},
        onForgotPassword: (_) async {},
        errorMessage: 'Session expired',
      )));
      await tester.pump();
      expect(find.text('Session expired'), findsOneWidget);
    });
  });

  group('AuthFlow — custom builders', () {
    testWidgets('headerBuilder receives correct mode', (tester) async {
      AuthMode? capturedMode;
      await tester.pumpWidget(_wrap(AuthFlow(
        onSignIn: (_, __) async {},
        onSignUp: (_, __, ___) async {},
        onForgotPassword: (_) async {},
        headerBuilder: (ctx, mode) {
          capturedMode = mode;
          return Text('Custom header: ${mode.name}');
        },
      )));
      await tester.pump();
      expect(capturedMode, AuthMode.signIn);
      expect(find.text('Custom header: signIn'), findsOneWidget);
    });
  });
}
