import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/password_options.dart';
import '../models/password_strength.dart';
import '../services/password_service.dart';
import '../widgets/generate_button.dart';
import '../widgets/history_sheet.dart';
import '../widgets/length_slider.dart';
import '../widgets/option_switches.dart';
import '../widgets/password_card.dart';
import '../widgets/strength_indicator.dart';

/// Maximum number of passwords kept in history.
const int _kMaxHistory = 5;

/// Minimum password length constant.
const int _kMinLength = 4;

/// Maximum password length constant.
const int _kMaxLength = 32;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Service ──────────────────────────────────────────────────────────────
  final PasswordService _service = PasswordService();

  // ── State ─────────────────────────────────────────────────────────────────
  PasswordOptions _options = const PasswordOptions();
  String _password = '';
  PasswordStrengthResult? _strengthResult;
  bool _isPasswordVisible = false;
  final List<String> _history = [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Generate an initial password on launch so the screen isn't empty.
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _generate() {
    if (!_options.isValid) {
      _showError('Select at least one character type.');
      return;
    }

    final password = _service.generate(_options);
    final strength = _service.evaluate(password, _options);

    setState(() {
      _password = password;
      _strengthResult = strength;
      _isPasswordVisible = true; // reveal on fresh generate

      // Prepend to history, keep max N entries.
      _history.insert(0, password);
      if (_history.length > _kMaxHistory) {
        _history.removeRange(_kMaxHistory, _history.length);
      }
    });
  }

  void _copyPassword() {
    if (_password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _password));
    _showSnackBar('Password copied!', icon: Icons.check_circle_outline_rounded);
  }

  void _toggleVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _onOptionsChanged(PasswordOptions updated) {
    setState(() => _options = updated);
  }

  void _onLengthChanged(int length) {
    setState(() => _options = _options.copyWith(length: length));
  }

  void _clearHistory() {
    setState(() => _history.clear());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {IconData? icon}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Password Generator',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // History button
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'Password history',
                onPressed: () => HistorySheet.show(
                  context,
                  history: List.unmodifiable(_history),
                  onClear: _clearHistory,
                ),
              ),
              if (_history.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Password card ─────────────────────────────────────────
              _SectionLabel(label: 'Generated Password'),
              const SizedBox(height: 8),
              PasswordCard(
                password: _password,
                isVisible: _isPasswordVisible,
                onToggleVisibility: _toggleVisibility,
                onCopy: _copyPassword,
                onRegenerate: _generate,
              ),

              const SizedBox(height: 24),

              // ── Strength indicator ────────────────────────────────────
              StrengthIndicator(result: _strengthResult),

              const SizedBox(height: 28),

              // ── Divider ───────────────────────────────────────────────
              Divider(color: colorScheme.outlineVariant, height: 1),

              const SizedBox(height: 24),

              // ── Length slider ─────────────────────────────────────────
              LengthSlider(
                value: _options.length,
                min: _kMinLength,
                max: _kMaxLength,
                onChanged: _onLengthChanged,
              ),

              const SizedBox(height: 24),

              // ── Character options ─────────────────────────────────────
              _SectionLabel(label: 'Character Types'),
              const SizedBox(height: 4),
              OptionSwitches(
                options: _options,
                onChanged: _onOptionsChanged,
              ),

              const SizedBox(height: 32),

              // ── Generate button ───────────────────────────────────────
              GenerateButton(onPressed: _generate),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widget ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
