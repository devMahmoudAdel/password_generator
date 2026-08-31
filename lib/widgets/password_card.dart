import 'package:flutter/material.dart';

/// Displays the generated password with copy and show/hide controls.
class PasswordCard extends StatelessWidget {
  final String password;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;

  const PasswordCard({
    super.key,
    required this.password,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayText = password.isEmpty
        ? 'Press Generate'
        : (isVisible ? password : '•' * password.length);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Password text
            Expanded(
              child: Text(
                displayText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: isVisible ? 1.5 : 3,
                  color: password.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // Show / hide
            _IconAction(
              icon: isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              tooltip: isVisible ? 'Hide password' : 'Show password',
              onTap: password.isEmpty ? null : onToggleVisibility,
            ),
            // Regenerate
            _IconAction(
              icon: Icons.refresh_rounded,
              tooltip: 'Regenerate',
              onTap: password.isEmpty ? null : onRegenerate,
            ),
            // Copy
            _IconAction(
              icon: Icons.copy_rounded,
              tooltip: 'Copy password',
              onTap: password.isEmpty ? null : onCopy,
              color: password.isEmpty ? null : colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onTap,
      color: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
