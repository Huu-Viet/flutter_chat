import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/app/e_app_route.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/profile/blocs/profile_bloc/profile_bloc.dart';
import 'package:flutter_chat/presentation/profile/providers/set_profile_bloc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileBlocProvider).add(const LoadProfileEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = ref.read(profileBlocProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocProvider<ProfileBloc>.value(
        value: profileBloc,
        child: const ProfilePageContent(),
      ),
    );
  }
}

class ProfilePageContent extends ConsumerWidget {
  const ProfilePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(profileBlocProvider).add(const LoadProfileEvent());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! ProfileLoaded) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
            onRefresh: () async {
              ref.read(profileBlocProvider).add(const RefreshProfileEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _ProfileLoadedView(
                myUser: state.myUser,
                profileBloc: ref.read(profileBlocProvider),
              ),
            ),
        );
      },
    );
  }
}

class _ProfileLoadedView extends StatelessWidget {
  final ProfileBloc profileBloc;
  final MyUser myUser;

  const _ProfileLoadedView({
    required this.myUser,
    required this.profileBloc,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fullName = [myUser.firstName, myUser.lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');
    final displayName = fullName.isNotEmpty ? fullName : myUser.username;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar
          const Center(
            child: CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 60),
            ),
          ),
          const SizedBox(height: 16),
          
          // User Name
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // User Email  
          Text(
            myUser.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Options
          Card(
            child: Column(
              children: [
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile feature coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications settings coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileOption(
                  icon: Icons.privacy_tip,
                  title: 'Privacy & Security',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy settings coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileOption(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileOption(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Flutter Chat',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.chat),
                      children: [
                        const Text('A modern chat application built with Flutter, BLoC, and Clean Architecture.'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.logout),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          profileBloc.add(SignOutEvent());
                          context.go(AppRoute.login.path);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(l10n.logout),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}