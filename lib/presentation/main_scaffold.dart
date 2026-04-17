import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/call/presentation/call_page.dart';
import 'package:flutter_chat/presentation/contact/pages/contact_page.dart';
import 'package:flutter_chat/presentation/home/page/home_page.dart';
import 'package:flutter_chat/presentation/profile/pages/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);
final pendingContactRequestsCountProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget{
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final pendingCount = ref.watch(pendingContactRequestsCountProvider);
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      const HomePage(),
      ContactPage(
        onPendingRequestCountChanged: (amount) {
          ref.read(pendingContactRequestsCountProvider.notifier).state = amount;
        },
      ),
      const CallPage(),
      const ProfilePage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surfaceBright
      ),
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.4,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (index) {
              ref.read(selectedTabProvider.notifier).state = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: l10n.messages,
              ),
              BottomNavigationBarItem(
                icon: _ContactTabIcon(pendingCount: pendingCount),
                label: l10n.contacts,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call),
                label: l10n.call,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _ContactTabIcon extends StatelessWidget {
  final int pendingCount;

  const _ContactTabIcon({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.contacts),
        if (pendingCount > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                pendingCount > 99 ? '99+' : '$pendingCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}