import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/blocs/account_bloc/account_bloc.dart';
import 'package:flutter_chat/presentation/auth/providers/auth_bloc_providers.dart';
import 'package:flutter_chat/presentation/auth/widgets/login_custom_input.dart';
import 'package:flutter_chat/presentation/main_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grantedAccountProvider = ref.watch(grantedAccountAuthBlocProvider);
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<AccountBloc>.value(
      value: grantedAccountProvider,
      child: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
            if(state is AccountLoading) {
              setState(() {
                showLoading = true;
              });
            } else if (state is AccountSuccess) {
              setState(() {
                showLoading = false;
              });
              ref.read(selectedTabProvider.notifier).state = 0;
              context.go("/home");
            } else if (state is AccountError) {
              setState(() {
                showLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        child: Scaffold (
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.app_name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.welcome_login,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.grey
                      ),
                    ),

                    const SizedBox(height: 24),

                    LoginCustomInput(
                      hintText: l10n.email_hint,
                      label: l10n.email_label,
                      controller: emailController,
                      icon: Icons.email_outlined,
                    ),

                    LoginCustomInput(
                      hintText: l10n.password_hint,
                      label: l10n.password_label,
                      controller: passwordController,
                      isPassword: true,
                      icon: Icons.lock_outline,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          context.go("/forgot-password");
                        },
                        child: Text(
                          l10n.forget_password,
                          style: const TextStyle(
                              color: Colors.blueAccent
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24,),

                    ElevatedButton(
                      onPressed: () {
                        if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.fill_in_input_notify)),
                          );
                          return;
                        }
                        grantedAccountProvider.add(LoginWithEmailEvent(
                          emailController.text,
                          passwordController.text,
                        ));
                      },
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
                        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        )),
                      ),
                      child: showLoading ?
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ) : Text(
                        l10n.login,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 24,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: Divider(color: Colors.grey,)),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            l10n.or,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        const Expanded(child: Divider(color: Colors.grey,)),
                      ],
                    ),

                    const SizedBox(height: 24,),

                    ElevatedButton(
                      onPressed: () {
                        context.go("/register");
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceBright),
                        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            side: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: Theme.of(context).colorScheme.onSurface,),
                          const SizedBox(width: 10,),
                          Text(
                            l10n.registry,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}