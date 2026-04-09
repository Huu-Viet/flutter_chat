import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/call/presentation/call_page.dart';
import 'package:flutter_chat/presentation/contact/pages/contact_page.dart';
import 'package:flutter_chat/presentation/home/page/home_page.dart';
import 'package:flutter_chat/presentation/profile/pages/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget{
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final l10n = AppLocalizations.of(context)!;

    const pages = [
      HomePage(),
      ContactPage(),
      CallPage(),
      ProfilePage(),
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
                icon: Icon(Icons.contacts),
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