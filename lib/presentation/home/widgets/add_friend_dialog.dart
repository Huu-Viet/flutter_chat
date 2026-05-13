import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/home/blocs/add_friend_blocs/add_friend_bloc.dart';

class AddFriendDialog extends StatelessWidget {
  final AddFriendBloc addFriendBloc;

  const AddFriendDialog({
    super.key,
    required this.addFriendBloc,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider<AddFriendBloc>.value(
      value: addFriendBloc,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: Text(l10n.action_add_friend),
        scrollable: true,
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.add_friend_hint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  addFriendBloc.add(AddFriendQueryChanged(value));
                },
                onSubmitted: (_) {
                  addFriendBloc.add(const AddFriendSearchRequested());
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: BlocBuilder<AddFriendBloc, AddFriendState>(
                  builder: (context, state) {
                    if (state is AddFriendLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AddFriendFailure) {
                      return Center(
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (!state.hasSearched) {
                      return Center(
                        child: Text(
                          l10n.add_friend_guide,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (state.users.isEmpty) {
                      return Center(
                        child: Text(l10n.error_user_not_found),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            child: Text(
                              (user.username.isNotEmpty ? user.username[0] : '?')
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(user.username),
                          subtitle: Text(user.email),
                          trailing: (state.friendAndPendingUserIds.contains(user.id))
                              ? null
                              : IconButton(
                                  onPressed: state.busyUserId == user.id
                                      ? null
                                      : () {
                                          addFriendBloc.add(AddFriendRequestRequested(user.id));
                                        },
                                  icon: state.busyUserId == user.id
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.person_add_alt_1_outlined),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          BlocBuilder<AddFriendBloc, AddFriendState>(
            builder: (context, state) {
              return FilledButton.icon(
                onPressed: state.query.trim().isEmpty || state is AddFriendLoading
                    ? null
                    : () {
                        addFriendBloc.add(const AddFriendSearchRequested());
                      },
                icon: const Icon(Icons.search),
                label: Text(l10n.search),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
