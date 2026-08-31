import 'package:flutter/material.dart';

import '../models/password_strength.dart';

/// Animated strength bar with label and entropy info.
class StrengthIndicator extends StatelessWidget {
  final PasswordStrengthResult? result;

  const StrengthIndicator({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final level = result?.level;
    final progress = level?.progress ?? 0.0;
    final color = level?.color ?? colorScheme.outlineVariant;
    final label = level?.label ?? '—';
    final entropyLabel = result?.entropyLabel ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strength',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              children: [
                if (entropyLabel.isNotEmpty) ...[
                  Text(
                    entropyLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }
}
