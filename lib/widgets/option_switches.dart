import 'package:flutter/material.dart';

import '../models/password_options.dart';

/// Four toggle switches for character type selection.
class OptionSwitches extends StatelessWidget {
  final PasswordOptions options;
  final ValueChanged<PasswordOptions> onChanged;

  const OptionSwitches({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OptionTile(
          label: 'Uppercase Letters',
          sublabel: 'A – Z',
          value: options.useUppercase,
          onChanged: (v) => onChanged(options.copyWith(useUppercase: v)),
        ),
        _OptionTile(
          label: 'Lowercase Letters',
          sublabel: 'a – z',
          value: options.useLowercase,
          onChanged: (v) => onChanged(options.copyWith(useLowercase: v)),
        ),
        _OptionTile(
          label: 'Numbers',
          sublabel: '0 – 9',
          value: options.useNumbers,
          onChanged: (v) => onChanged(options.copyWith(useNumbers: v)),
        ),
        _OptionTile(
          label: 'Symbols',
          sublabel: r'! @ # $ % ^ & *',
          value: options.useSymbols,
          onChanged: (v) => onChanged(options.copyWith(useSymbols: v)),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionTile({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
