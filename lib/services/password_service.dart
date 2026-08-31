import 'dart:math';

import '../models/password_options.dart';
import '../models/password_strength.dart';

/// Character pools used during generation.
class _CharPools {
  static const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String numbers = '0123456789';
  // Double-quoted string so we can include single-quote and backslash cleanly.
  // ignore: unnecessary_string_escapes
  static const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';
}

/// Pure-logic service — no Flutter imports, no state.
/// Instantiate once and reuse.
class PasswordService {
  /// Cryptographically-seeded random (falls back to [Random] on platforms
  /// where [Random.secure] is unavailable, but that is extremely rare).
  final Random _rng = Random.secure();

  // ---------------------------------------------------------------------------
  // Generation
  // ---------------------------------------------------------------------------

  /// Generates a password according to [options].
  ///
  /// Guarantees at least one character from every selected category, then
  /// fills the remainder randomly from the combined pool and shuffles.
  ///
  /// Returns an empty string if [options.isValid] is false — callers should
  /// validate before calling.
  String generate(PasswordOptions options) {
    if (!options.isValid) return '';

    final List<String> mandatory = [];
    final StringBuffer pool = StringBuffer();

    if (options.useUppercase) {
      mandatory.add(_randomChar(_CharPools.uppercase));
      pool.write(_CharPools.uppercase);
    }
    if (options.useLowercase) {
      mandatory.add(_randomChar(_CharPools.lowercase));
      pool.write(_CharPools.lowercase);
    }
    if (options.useNumbers) {
      mandatory.add(_randomChar(_CharPools.numbers));
      pool.write(_CharPools.numbers);
    }
    if (options.useSymbols) {
      mandatory.add(_randomChar(_CharPools.symbols));
      pool.write(_CharPools.symbols);
    }

    final String fullPool = pool.toString();
    final int remaining = options.length - mandatory.length;

    final List<String> chars = List<String>.from(mandatory);
    for (int i = 0; i < remaining; i++) {
      chars.add(_randomChar(fullPool));
    }

    // Fisher-Yates shuffle so mandatory chars aren't always at the front.
    for (int i = chars.length - 1; i > 0; i--) {
      final int j = _rng.nextInt(i + 1);
      final String tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }

    return chars.join();
  }

  // ---------------------------------------------------------------------------
  // Strength evaluation
  // ---------------------------------------------------------------------------

  /// Evaluates the strength of [password] produced with [options].
  ///
  /// Scoring is additive:
  /// - Base: length contribution (0–40 pts)
  /// - Category variety bonus (0–20 pts)
  /// - Actual character composition confirmation (0–20 pts)
  /// - Entropy tier bonus (0–20 pts)
  PasswordStrengthResult evaluate(String password, PasswordOptions options) {
    if (password.isEmpty) {
      return PasswordStrengthResult(
        level: PasswordStrengthLevel.weak,
        entropyBits: 0,
      );
    }

    int score = 0;

    // 1. Length score (max 40)
    final int len = password.length;
    if (len >= 8) score += 10;
    if (len >= 12) score += 10;
    if (len >= 16) score += 10;
    if (len >= 24) score += 10;

    // 2. Category variety (max 20)
    score += options.activeCategories * 5;

    // 3. Actual composition check (max 20)
    final bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    final bool hasLower = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'[0-9]'));
    final bool hasSymbol = password.contains(
      RegExp(r'''[!@#$%^&*()\-_=+\[\]{}|;:,.<>?/~`"\'\\]'''),
    );

    if (hasUpper) score += 5;
    if (hasLower) score += 5;
    if (hasDigit) score += 5;
    if (hasSymbol) score += 5;

    // 4. Entropy bonus (max 20)
    final double entropy = _entropy(options);
    if (entropy >= 40) score += 5;
    if (entropy >= 60) score += 5;
    if (entropy >= 80) score += 5;
    if (entropy >= 100) score += 5;

    // Map score → level
    final PasswordStrengthLevel level;
    if (score < 30) {
      level = PasswordStrengthLevel.weak;
    } else if (score < 55) {
      level = PasswordStrengthLevel.medium;
    } else if (score < 75) {
      level = PasswordStrengthLevel.strong;
    } else {
      level = PasswordStrengthLevel.veryStrong;
    }

    return PasswordStrengthResult(level: level, entropyBits: entropy);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _randomChar(String pool) => pool[_rng.nextInt(pool.length)];

  /// Shannon entropy: length * log2(poolSize)
  double _entropy(PasswordOptions options) {
    final int poolSize = options.poolSize;
    if (poolSize == 0) return 0;
    return options.length * log(poolSize) / ln2;
  }
}
