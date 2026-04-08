import 'package:flutter/material.dart';
import 'package:flutter_auth_flow/flutter_auth_flow.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuthFlow Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AuthFlow(
                // ── Callbacks ───────────────────────────────────────────
                onSignIn: (email, password) async {
                  // Simulate a network call
                  await Future.delayed(const Duration(seconds: 2));
                  // Throw to simulate an auth error:
                  // throw Exception('Invalid email or password');
                  debugPrint('Signed in: $email');
                },
                onSignUp: (email, password, name) async {
                  await Future.delayed(const Duration(seconds: 2));
                  debugPrint('Signed up: $name <$email>');
                },
                onForgotPassword: (email) async {
                  await Future.delayed(const Duration(seconds: 1));
                  debugPrint('Reset link sent to: $email');
                },

                // ── Optional: start on a specific mode ──────────────────
                initialMode: AuthMode.signIn,

                // ── Optional: custom theme ───────────────────────────────
                // theme: AuthFlowTheme(
                //   primaryColor: Colors.indigo,
                //   inputBorderRadius: BorderRadius.circular(8),
                //   buttonBorderRadius: BorderRadius.circular(8),
                // ),

                // ── Optional: custom header with logo ────────────────────
                // headerBuilder: (ctx, mode) => Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     FlutterLogo(size: 48),
                //     SizedBox(height: 20),
                //     Text(
                //       mode == AuthMode.signIn ? 'Welcome back' : 'Join us',
                //       style: Theme.of(ctx).textTheme.headlineSmall,
                //     ),
                //   ],
                // ),

                // ── Optional: footer for Terms / Privacy links ────────────
                footerBuilder: (ctx, mode) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'By continuing you agree to our Terms of Service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
