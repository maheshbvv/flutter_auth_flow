import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'password_policy.dart';

Future<PasswordBreachCheckResult> checkPasswordAgainstPwnedPasswords(
  String password, {
  http.Client? client,
}) async {
  final effectiveClient = client ?? http.Client();
  final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
  final prefix = hash.substring(0, 5);
  final suffix = hash.substring(5);

  try {
    final response = await effectiveClient.get(
      Uri.parse('https://api.pwnedpasswords.com/range/$prefix'),
      headers: const {
        'Add-Padding': 'true',
        'User-Agent': 'flutter_auth_flow',
      },
    ).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw StateError(
        'Pwned Passwords lookup failed with status ${response.statusCode}',
      );
    }

    for (final line in const LineSplitter().convert(response.body)) {
      if (line.isEmpty) continue;
      final parts = line.split(':');
      if (parts.length != 2) continue;
      if (parts.first == suffix) {
        final exposureCount = int.tryParse(parts.last) ?? 0;
        if (exposureCount > 0) {
          return PasswordBreachCheckResult.pwned(
            exposureCount: exposureCount,
          );
        }
      }
    }

    return const PasswordBreachCheckResult.safe();
  } finally {
    if (client == null) {
      effectiveClient.close();
    }
  }
}
