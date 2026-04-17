import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/contact/blocs/contact_bloc.dart';
import 'package:flutter_chat/presentation/contact/contact_provider.dart';
import 'package:flutter_chat/presentation/contact/widgets/friend_request_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactPage extends ConsumerStatefulWidget {
  final Function(int amount) onPendingRequestCountChanged;

  const ContactPage({super.key, required this.onPendingRequestCountChanged});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  late final TextEditingController searchController;

  Future<void> _refreshPendingRequests() async {
    final bloc = ref.read(contactBlocProvider);
    bloc.add(GetPendingRequests());
    await bloc.stream.firstWhere((state) => state is! ContactLoading);
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(contactBlocProvider).add(GetPendingRequests());
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = ref.watch(contactBlocProvider);

    return BlocProvider<ContactBloc>.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.contacts,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocListener<ContactBloc, ContactState>(
              listenWhen: (previous, current) => current is ContactLoaded,
              listener: (context, state) {
                if (state is ContactLoaded) {
                  widget.onPendingRequestCountChanged(state.pendingRequests.length);
                }
              },
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  if (state is ContactLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ContactError) {
                    return RefreshIndicator(
                      onRefresh: _refreshPendingRequests,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(child: Text(state.message)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ContactLoaded) {
                    if (state.pendingRequests.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshPendingRequests,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(child: Text(l10n.empty_data)),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshPendingRequests,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.pendingRequests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = state.pendingRequests[index];
                          return FriendRequestItem(
                            myUser: user,
                            onAccept: () {
                              context.read<ContactBloc>().add(AcceptRequest(user.id));
                            },
                            onDecline: () {
                              context.read<ContactBloc>().add(DeclineRequest(user.id));
                            },
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshPendingRequests,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(child: Text('No incoming requests yet')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}