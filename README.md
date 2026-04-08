# flutter_auth_flow

A single Flutter widget that handles **Sign In**, **Sign Up**, and **Forgot Password** — no routing, no multiple pages, no boilerplate.

Drop `AuthFlow` into any screen, wire up three async callbacks, and you're done.

---

## Features

- ✅ Sign In, Sign Up, Forgot Password in one widget
- ✅ Built-in form validation
- ✅ Internal loading & error state — or override with your own
- ✅ Smooth animated transitions between modes
- ✅ Works with any state management (BLoC, Riverpod, Provider, setState)
- ✅ Full builder pattern — replace any widget
- ✅ `AuthFlowTheme` for fine-grained visual control
- ✅ Zero dependencies beyond Flutter

---

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_auth_flow: ^0.0.4
```

---

## Usage

### Minimal

```dart
import 'package:flutter_auth_flow/flutter_auth_flow.dart';

AuthFlow(
  onSignIn: (email, password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, password: password,
    );
  },
  onSignUp: (email, password, name) async {
    await myAuthService.register(email, password, name);
  },
  onForgotPassword: (email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  },
)
```

The widget awaits each callback. While waiting, it shows a loading indicator.
If the callback **throws**, the error is caught and displayed inline — no extra code needed.

---

### With external state management (BLoC / Riverpod)

```dart
AuthFlow(
  onSignIn: (email, password) async {
    context.read<AuthCubit>().signIn(email, password);
  },
  onSignUp: ...,
  onForgotPassword: ...,

  // Override internal state with your own
  isLoading: context.watch<AuthCubit>().state.isLoading,
  errorMessage: context.watch<AuthCubit>().state.error,
)
```

---

### Custom theme

```dart
AuthFlow(
  onSignIn: ...,
  onSignUp: ...,
  onForgotPassword: ...,

  theme: AuthFlowTheme(
    primaryColor: Colors.indigo,
    inputBorderRadius: BorderRadius.circular(8),
    buttonBorderRadius: BorderRadius.circular(8),
    titleStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
  ),
)
```

---

### Custom header (logo, branding)

```dart
AuthFlow(
  onSignIn: ...,
  onSignUp: ...,
  onForgotPassword: ...,

  headerBuilder: (context, mode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/logo.png', height: 40),
        const SizedBox(height: 20),
        Text(
          mode == AuthMode.signIn ? 'Welcome back' : 'Create account',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ],
    );
  },
)
```

---

### Custom submit button

```dart
AuthFlow(
  onSignIn: ...,
  onSignUp: ...,
  onForgotPassword: ...,

  submitButtonBuilder: (context, onTap, isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text('Let me in'),
    );
  },
)
```

---

### Start on a specific mode

```dart
AuthFlow(
  initialMode: AuthMode.signUp,   // or .signIn / .forgotPassword
  onSignIn: ...,
  onSignUp: ...,
  onForgotPassword: ...,
)
```

---

## API reference

### `AuthFlow`

| Parameter | Type | Required | Description |
|---|---|---|---|
| `onSignIn` | `Future<void> Function(String email, String password)` | ✅ | Called on sign-in submit. Throw to show an error. |
| `onSignUp` | `Future<void> Function(String email, String password, String name)` | ✅ | Called on sign-up submit. Throw to show an error. |
| `onForgotPassword` | `Future<void> Function(String email)` | ✅ | Called on forgot-password submit. Throw to show an error. |
| `isLoading` | `bool?` | — | Overrides internal loading state. |
| `errorMessage` | `String?` | — | Overrides internal error message. |
| `initialMode` | `AuthMode?` | — | Starting mode. Default: `AuthMode.signIn`. |
| `theme` | `AuthFlowTheme?` | — | Visual customization. |
| `headerBuilder` | `Widget Function(BuildContext, AuthMode)?` | — | Replace the title/subtitle header. |
| `footerBuilder` | `Widget Function(BuildContext, AuthMode)?` | — | Add content below the form. |
| `errorBuilder` | `Widget Function(BuildContext, String)?` | — | Replace the inline error widget. |
| `loadingBuilder` | `Widget Function(BuildContext)?` | — | Replace the default loading indicator. |
| `submitButtonBuilder` | `Widget Function(BuildContext, VoidCallback, bool)?` | — | Replace the submit button. |
| `modeSwitcherBuilder` | `Widget Function(BuildContext, AuthMode, void Function(AuthMode))?` | — | Replace the mode-switch link row. |

### `AuthMode`

```dart
enum AuthMode { signIn, signUp, forgotPassword }
```

### `AuthFlowTheme`

| Property | Type | Description |
|---|---|---|
| `primaryColor` | `Color?` | Accent color for button and links. |
| `backgroundColor` | `Color?` | Widget surface background. |
| `inputFillColor` | `Color?` | Text field fill color. |
| `errorColor` | `Color?` | Error message color. |
| `titleStyle` | `TextStyle?` | Mode title text style. |
| `subtitleStyle` | `TextStyle?` | Mode subtitle text style. |
| `inputStyle` | `TextStyle?` | Input field text style. |
| `buttonTextStyle` | `TextStyle?` | Submit button text style. |
| `linkStyle` | `TextStyle?` | Mode-switch link text style. |
| `inputBorderRadius` | `BorderRadius?` | Input field corner radius. |
| `buttonBorderRadius` | `BorderRadius?` | Button corner radius. |
| `inputDecoration` | `InputDecoration?` | Full input decoration override. |
| `buttonStyle` | `ButtonStyle?` | Full button style override. |
| `cardDecoration` | `BoxDecoration?` | Outer container decoration. |
| `transitionDuration` | `Duration?` | Mode animation duration. Default: 320ms. |
| `transitionCurve` | `Curve?` | Mode animation curve. Default: `easeInOut`. |

---

## License

MIT
