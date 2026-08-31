import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet showing the last N generated passwords.
class HistorySheet extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;

  const HistorySheet({super.key, required this.history, required this.onClear});

  /// Opens the history bottom sheet.
  static void show(
    BuildContext context, {
    required List<String> history,
    required VoidCallback onClear,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => HistorySheet(history: history, onClear: onClear),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Password History',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (history.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      onPressed: () {
                        onClear();
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: history.isEmpty
                  ? _EmptyHistory()
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: history.length,
                      separatorBuilder: (_, _) =>
                          const Divider(indent: 16, endIndent: 16, height: 1),
                      itemBuilder: (context, index) {
                        final password = history[index];
                        return _HistoryTile(password: password, index: index);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No passwords generated yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String password;
  final int index;

  const _HistoryTile({required this.password, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          '${index + 1}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        password,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          letterSpacing: 1.2,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy_rounded),
        tooltip: 'Copy',
        iconSize: 20,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: password));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password copied!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}
