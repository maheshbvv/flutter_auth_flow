## 0.0.9

* Updated README screenshot links to use absolute GitHub image URLs so they render on pub.dev instead of showing alt-text placeholders.

## 0.0.8

* Added package screenshots metadata to `pubspec.yaml` so pub.dev can display the screenshot gallery on the package page.

## 0.0.7

* Added opt-in `PasswordPolicy` support for the Sign Up flow
* Added a built-in password strength indicator with local password quality scoring
* Added optional "**Have I Been Pwned**" password checks with developer control over whether exposed passwords are blocked
* Updated the auth form layout to scroll when extra password guidance is shown

## 0.0.6

* Added `themeMode` property to `AuthFlowTheme` for automatic dark/light mode detection based on system settings
* Supports `ThemeMode.system` (default), `ThemeMode.light`, and `ThemeMode.dark`

## 0.0.5

* Added `DemoAuthService` for testing and development
* Improved error handling with user-friendly error messages
* Enhanced form validation feedback

## 0.0.4

Published to verified publisher with minor fixes.

## 0.0.3

Published to the verified publisher https://pendura.in

## 0.0.2

Documentation improvements and README updates.

## 0.0.1

* Initial release.
* `AuthFlow` widget with Sign In, Sign Up, and Forgot Password modes.
* `AuthFlowTheme` for fine-grained visual customization.
* Full builder pattern: `headerBuilder`, `footerBuilder`, `errorBuilder`,
  `loadingBuilder`, `submitButtonBuilder`, `modeSwitcherBuilder`.
* Internal loading and error state with optional external override.
* Animated mode transitions with `AnimatedSwitcher`.
* Built-in form validation with autofill support.
