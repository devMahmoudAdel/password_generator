import 'package:flutter/material.dart';

/// Prominent full-width button to trigger password generation.
class GenerateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GenerateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        icon: const Icon(Icons.lock_outline_rounded, size: 20),
        label: const Text('Generate Password'),
      ),
    );
  }
}
