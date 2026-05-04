import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  UserThemeMode _selectedTheme = UserThemeMode.system;
  bool _initialized = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(watchThemeStringProvider);

    themeAsync.whenData((theme) {
      if (!_initialized) {
        _selectedTheme = _themeFromRaw(theme);
        _initialized = true;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: themeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(context),
        data: (_) => _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  _buildThemeOption(
                    title: 'LIGHT',
                    subtitle: 'Always use light theme',
                    icon: Icons.light_mode,
                    value: UserThemeMode.light,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    title: 'DARK',
                    subtitle: 'Always use dark theme',
                    icon: Icons.dark_mode,
                    value: UserThemeMode.dark,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    title: 'SYSTEM',
                    subtitle: 'Follow device setting',
                    icon: Icons.settings_suggest,
                    value: UserThemeMode.system,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _confirmTheme,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required UserThemeMode value,
  }) {
    final selected = value == _selectedTheme;

    return ListTile(
      enabled: !_submitting,
      onTap: _submitting ? null : () => setState(() => _selectedTheme = value),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }

  Future<void> _confirmTheme() async {
    setState(() => _submitting = true);

    final result = await ref.read(updateThemeUseCaseProvider)(_selectedTheme);

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Theme updated')));
        Navigator.of(context).pop();
      },
    );
  }

  UserThemeMode _themeFromRaw(String raw) {
    switch (raw.toUpperCase()) {
      case 'LIGHT':
        return UserThemeMode.light;
      case 'DARK':
        return UserThemeMode.dark;
      case 'SYSTEM':
      default:
        return UserThemeMode.system;
    }
  }
}
