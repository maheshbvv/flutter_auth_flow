enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
}

class PasswordStrengthResult {
  const PasswordStrengthResult({
    required this.level,
    required this.progress,
    required this.label,
    required this.helperText,
  });

  final PasswordStrength level;
  final double progress;
  final String label;
  final String helperText;
}

PasswordStrengthResult evaluatePasswordStrength({
  required String password,
  required int minLength,
  String email = '',
  String name = '',
}) {
  final trimmedPassword = password.trim();
  if (trimmedPassword.isEmpty) {
    return const PasswordStrengthResult(
      level: PasswordStrength.weak,
      progress: 0.0,
      label: 'Weak',
      helperText:
          'Use a long password or passphrase you do not reuse elsewhere.',
    );
  }

  final loweredPassword = trimmedPassword.toLowerCase();
  final normalizedName = name.toLowerCase().trim();
  final normalizedEmail = email.toLowerCase().trim();
  final uniqueChars = trimmedPassword.runes.toSet().length;
  final uniqueRatio = uniqueChars / trimmedPassword.length;
  final hasLower = RegExp(r'[a-z]').hasMatch(trimmedPassword);
  final hasUpper = RegExp(r'[A-Z]').hasMatch(trimmedPassword);
  final hasDigit = RegExp(r'\d').hasMatch(trimmedPassword);
  final hasSymbol = RegExp(r'[^A-Za-z0-9\s]').hasMatch(trimmedPassword);
  final hasSpaces = trimmedPassword.contains(' ');
  final wordCount = trimmedPassword
      .split(RegExp(r'\s+'))
      .where((part) => part.length >= 3)
      .length;
  final characterGroupCount =
      [hasLower, hasUpper, hasDigit, hasSymbol].where((value) => value).length;

  var score = 0;
  score += (trimmedPassword.length * 4).clamp(0, 56);
  score += (uniqueRatio * 18).round();
  score += characterGroupCount * 6;
  if (hasSpaces && wordCount >= 3) {
    score += 10;
  }

  var helperText = 'Looks usable, but longer and less predictable is better.';

  if (trimmedPassword.length < minLength) {
    return PasswordStrengthResult(
      level: PasswordStrength.weak,
      progress: 0.2,
      label: 'Weak',
      helperText: 'Use at least $minLength characters.',
    );
  }

  final commonPatterns = <String>[
    'password',
    'passw0rd',
    'qwerty',
    'abc123',
    'letmein',
    'welcome',
    'admin',
    'football',
    'baseball',
    'dragon',
    'monkey',
    'iloveyou',
    '123456',
    '654321',
  ];

  final hasCommonPattern =
      commonPatterns.any((pattern) => loweredPassword.contains(pattern));
  final hasWordYearPattern =
      RegExp(r'^[a-z]+(?:19|20)\d{2}$').hasMatch(loweredPassword);
  final hasRepeatPattern =
      RegExp(r'(.)\1{2,}').hasMatch(loweredPassword) || uniqueRatio < 0.45;
  final hasSequencePattern = _hasSequentialPattern(loweredPassword);
  final containsPersonalInfo = _containsPersonalInfo(
    password: loweredPassword,
    email: normalizedEmail,
    name: normalizedName,
  );

  if (hasCommonPattern) {
    score -= 24;
    helperText = 'Avoid common passwords or obvious word patterns.';
  }
  if (hasWordYearPattern) {
    score -= 12;
    helperText = 'Avoid common word-plus-year combinations.';
  }
  if (hasRepeatPattern) {
    score -= 10;
    helperText = 'Avoid repeated characters or overly similar patterns.';
  }
  if (hasSequencePattern) {
    score -= 12;
    helperText = 'Avoid sequences like 1234, abcd, or qwerty.';
  }
  if (containsPersonalInfo) {
    score -= 18;
    helperText = 'Avoid using your name or email in the password.';
  }

  if (trimmedPassword.length >= minLength + 4) {
    score += 8;
  }
  if (trimmedPassword.length >= minLength + 8) {
    score += 8;
  }

  final boundedScore = score.clamp(0, 100);
  final progress = (boundedScore / 100).clamp(0.15, 1.0);

  if (boundedScore < 40) {
    return PasswordStrengthResult(
      level: PasswordStrength.weak,
      progress: progress,
      label: 'Weak',
      helperText: helperText,
    );
  }
  if (boundedScore < 60) {
    return PasswordStrengthResult(
      level: PasswordStrength.fair,
      progress: progress,
      label: 'Fair',
      helperText: helperText,
    );
  }
  if (boundedScore < 80) {
    return PasswordStrengthResult(
      level: PasswordStrength.good,
      progress: progress,
      label: 'Good',
      helperText: 'Good start. Extra length still helps the most.',
    );
  }

  return PasswordStrengthResult(
    level: PasswordStrength.strong,
    progress: progress,
    label: 'Strong',
    helperText: 'Strong choice. Long, unique passwords are hardest to guess.',
  );
}

bool _containsPersonalInfo({
  required String password,
  required String email,
  required String name,
}) {
  final tokens = <String>{
    ...name.split(RegExp(r'\s+')).where((part) => part.length >= 3),
    ...email.split(RegExp(r'[@._\-+]')).where((part) => part.length >= 3),
  };

  return tokens.any(password.contains);
}

bool _hasSequentialPattern(String value) {
  if (value.length < 4) return false;

  const sequences = <String>[
    '0123456789',
    '9876543210',
    'abcdefghijklmnopqrstuvwxyz',
    'zyxwvutsrqponmlkjihgfedcba',
    'qwertyuiop',
    'poiuytrewq',
    'asdfghjkl',
    'lkjhgfdsa',
    'zxcvbnm',
    'mnbvcxz',
  ];

  for (final sequence in sequences) {
    for (var i = 0; i <= sequence.length - 4; i++) {
      final slice = sequence.substring(i, i + 4);
      if (value.contains(slice)) {
        return true;
      }
    }
  }

  return false;
}
