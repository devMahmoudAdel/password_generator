import 'package:flutter/material.dart';

/// Represents the evaluated strength of a generated password.
enum PasswordStrengthLevel {
  weak,
  medium,
  strong,
  veryStrong;

  String get label {
    switch (this) {
      case weak:
        return 'Weak';
      case medium:
        return 'Medium';
      case strong:
        return 'Strong';
      case veryStrong:
        return 'Very Strong';
    }
  }

  Color get color {
    switch (this) {
      case weak:
        return const Color(0xFFE53935); // red
      case medium:
        return const Color(0xFFFB8C00); // orange
      case strong:
        return const Color(0xFF43A047); // green
      case veryStrong:
        return const Color(0xFF1565C0); // deep blue
    }
  }

  /// Progress value 0.0 – 1.0 for the strength bar.
  double get progress {
    switch (this) {
      case weak:
        return 0.25;
      case medium:
        return 0.50;
      case strong:
        return 0.75;
      case veryStrong:
        return 1.0;
    }
  }
}

/// Full result returned from the strength evaluator.
class PasswordStrengthResult {
  final PasswordStrengthLevel level;

  /// Entropy in bits: log2(poolSize ^ length).
  final double entropyBits;

  const PasswordStrengthResult({
    required this.level,
    required this.entropyBits,
  });

  String get entropyLabel => '~${entropyBits.toStringAsFixed(0)} bits';
}
