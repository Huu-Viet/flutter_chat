import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/widgets/login_custom_input.dart';

class ForgotPasswordForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String email) onSubmit;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();

  const ForgotPasswordForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mail_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  l10n.forget_password,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                Text(
                  l10n.forgot_password_guide,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                LoginCustomInput(
                    hintText: l10n.email_hint,
                    label: l10n.email_label,
                    controller: emailController,
                    icon: Icons.email_outlined
                ),
                const SizedBox(height: 10),

                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
                    minimumSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    )),
                  ),

                  onPressed: () {
                      if (emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.fill_in_input_notify)),
                        );
                        return;
                      }
                      widget.onSubmit(emailController.text);
                  },
                  child: widget.isLoading
                      ? CircularProgressIndicator()
                      : Text(l10n.submit, style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}