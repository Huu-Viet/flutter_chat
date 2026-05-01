import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/presentation/profile/blocs/manage_session_bloc/manage_session_bloc.dart';
import 'package:flutter_chat/presentation/profile/providers/profile_bloc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageSessionPage extends ConsumerStatefulWidget {
  const ManageSessionPage({super.key});

  @override
  ConsumerState<ManageSessionPage> createState() => _ManageSessionPageState();
}

class _ManageSessionPageState extends ConsumerState<ManageSessionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = ref.read(manageSessionBlocProvider);
      if (!bloc.isClosed) {
        bloc.add(const LoadSessionsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ref.watch(manageSessionBlocProvider);
    return BlocProvider<ManageSessionBloc>.value(
      value: bloc,
      child: const ManageSessionPageContent(),
    );
  }
}

class ManageSessionPageContent extends StatelessWidget {
  const ManageSessionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ManageSessionBloc>();

    return BlocListener<ManageSessionBloc, ManageSessionState>(
      listener: (context, state) {
        if (state is ManageSessionActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ManageSessionCurrentSessionRevoked) {
          context.go('/login?refresh=${DateTime.now().millisecondsSinceEpoch}');
        } else if (state is ManageSessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Privacy & Security',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<ManageSessionBloc, ManageSessionState>(
          builder: (context, state) {
            if (state is ManageSessionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final sessions = state.sessions;
            final isActionInProgress = state is ManageSessionActionInProgress;

            if (state is ManageSessionError && sessions.isEmpty) {
              return _SessionErrorView(
                message: state.message,
                onRetry: () {
                  if (!bloc.isClosed) {
                    bloc.add(const LoadSessionsEvent());
                  }
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (!bloc.isClosed) {
                  bloc.add(const RefreshSessionsEvent());
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _SecuritySectionHeader(
                    isActionInProgress: isActionInProgress,
                    onRevokeOtherSessions: sessions.isEmpty || isActionInProgress
                        ? null
                        : () => _confirmRevokeOtherSessions(context, bloc),
                  ),
                  const SizedBox(height: 16),
                  if (isActionInProgress)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (sessions.isEmpty)
                    const _EmptySessionsView()
                  else
                    ...sessions.map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionListTile(
                          session: session,
                          isActionInProgress: isActionInProgress,
                          onRevoke: () => _confirmRevokeSession(
                            context,
                            bloc,
                            session,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmRevokeOtherSessions(
    BuildContext context,
    ManageSessionBloc bloc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke other sessions?'),
        content: const Text(
          'All other active devices will be signed out. Your current session will remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true && !bloc.isClosed) {
      bloc.add(const RevokeOtherSessionsEvent());
    }
  }

  Future<void> _confirmRevokeSession(
    BuildContext context,
    ManageSessionBloc bloc,
    UserSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(session.isCurrent ? 'Revoke current session?' : 'Revoke this session?'),
        content: Text(
          session.isCurrent
              ? 'This is your current session. You will be logged out immediately after revoking it.\n\nSession ID: ${session.id}'
              : 'This device will be signed out.\n\nSession ID: ${session.id}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true && !bloc.isClosed) {
      bloc.add(RevokeSessionEvent(session.id));
    }
  }
}

class _SecuritySectionHeader extends StatelessWidget {
  final bool isActionInProgress;
  final VoidCallback? onRevokeOtherSessions;

  const _SecuritySectionHeader({
    required this.isActionInProgress,
    required this.onRevokeOtherSessions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Active sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Review devices that are currently signed in to your account.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRevokeOtherSessions,
                icon: const Icon(Icons.logout),
                label: Text(
                  isActionInProgress
                      ? 'Revoking sessions...'
                      : 'Revoke other sessions',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  final UserSession session;
  final bool isActionInProgress;
  final VoidCallback onRevoke;

  const _SessionListTile({
    required this.session,
    required this.isActionInProgress,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final clients = session.clients.isEmpty ? 'Unknown client' : session.clients.join(', ');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: session.isCurrent ? colorScheme.primaryContainer.withAlpha(89) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: session.isCurrent ? colorScheme.primary : Colors.transparent,
          width: session.isCurrent ? 1.5 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  session.isCurrent ? Icons.phone_android : Icons.devices,
                  color: session.isCurrent ? colorScheme.primary : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clients,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (session.isCurrent) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Current device',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        session.ipAddress?.trim().isNotEmpty == true
                            ? session.ipAddress!
                            : 'Unknown IP address',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SessionInfoRow(
              label: 'Started',
              value: _formatDateTime(session.started),
            ),
            const SizedBox(height: 6),
            _SessionInfoRow(
              label: 'Last access',
              value: _formatDateTime(session.lastAccess),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: isActionInProgress ? null : onRevoke,
                icon: Icon(session.isCurrent ? Icons.logout : Icons.close),
                label: Text(session.isCurrent ? 'Revoke & logout' : 'Revoke'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Unknown';
    }
    return AppDateUtils.formatDateTime(value);
  }
}

class _SessionInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SessionInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _EmptySessionsView extends StatelessWidget {
  const _EmptySessionsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.devices_other, size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(
            'No active sessions found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _SessionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SessionErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
