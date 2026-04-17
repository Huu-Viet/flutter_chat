import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/widgets/login_custom_input.dart';

class RegistryInitForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String email, String firstName, String lastName) onSubmit;

  const RegistryInitForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<RegistryInitForm> createState() => _RegistryInitFormState();
}

class _RegistryInitFormState extends State<RegistryInitForm> {
  late final TextEditingController emailController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  final RegExp _gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$', caseSensitive: false);

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fill_in_input_notify)),
      );
      return;
    }

    if (!_gmailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.email_rule)),
      );
      return;
    }

    widget.onSubmit(email, firstName, lastName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.registry,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            LoginCustomInput(
              hintText: l10n.email_hint,
              label: l10n.email_label,
              controller: emailController,
              icon: Icons.email_outlined,
            ),
            LoginCustomInput(
              hintText: l10n.first_name_hint,
              label: l10n.first_name_label,
              controller: firstNameController,
              icon: Icons.person_outline,
            ),
            LoginCustomInput(
              hintText: l10n.last_name_hint,
              label: l10n.last_name_label,
              controller: lastNameController,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey;
                  }
                  return Colors.blueAccent;
                }),
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.submit,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
