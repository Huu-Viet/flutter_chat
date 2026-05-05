import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _mobileEnabled = true;
  bool _desktopEnabled = true;
  NotifyFor _notifyFor = NotifyFor.all;
  bool _initialized = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(watchNotificationsProvider);

    notificationsAsync.whenData((notifications) {
      if (!_initialized) {
        _mobileEnabled = notifications.mobileEnabled;
        _desktopEnabled = notifications.desktopEnabled;
        _notifyFor = notifications.notifyFor == NotifyFor.unknown
            ? NotifyFor.all
            : notifications.notifyFor;
        _initialized = true;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
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
                  SwitchListTile(
                    value: _mobileEnabled,
                    onChanged: _submitting
                        ? null
                        : (value) => setState(() => _mobileEnabled = value),
                    secondary: const Icon(Icons.phone_android),
                    title: const Text('Mobile notifications'),
                    subtitle: const Text('Push alerts on mobile devices'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _desktopEnabled,
                    onChanged: _submitting
                        ? null
                        : (value) => setState(() => _desktopEnabled = value),
                    secondary: const Icon(Icons.desktop_windows),
                    title: const Text('Desktop notification'),
                    subtitle: const Text(
                      'Push alerts in browser / desktop app',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildNotifyForOption(
                    title: 'All messages',
                    subtitle: 'Notify for every new message',
                    icon: Icons.notifications_active,
                    value: NotifyFor.all,
                  ),
                  const Divider(height: 1),
                  _buildNotifyForOption(
                    title: 'Mentions only',
                    subtitle: 'Only when someone @mentions you',
                    icon: Icons.alternate_email,
                    value: NotifyFor.mentionsOnly,
                  ),
                  const Divider(height: 1),
                  _buildNotifyForOption(
                    title: 'Nothing',
                    subtitle: 'No push notifications',
                    icon: Icons.notifications_off,
                    value: NotifyFor.nothing,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _confirmNotifications,
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

  Widget _buildNotifyForOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required NotifyFor value,
  }) {
    final selected = value == _notifyFor;

    return ListTile(
      enabled: !_submitting,
      onTap: _submitting ? null : () => setState(() => _notifyFor = value),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }

  Future<void> _confirmNotifications() async {
    setState(() => _submitting = true);

    final result = await ref.read(updateNotificationsUseCaseProvider)(
      UserNotifications(
        mobileEnabled: _mobileEnabled,
        desktopEnabled: _desktopEnabled,
        notifyFor: _notifyFor,
      ),
    );

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings updated')),
        );
        Navigator.of(context).pop();
      },
    );
  }
}
