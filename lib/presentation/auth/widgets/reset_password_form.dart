
import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/widgets/login_custom_input.dart';
import 'package:flutter_chat/presentation/auth/widgets/policy_dialog.dart';

class ResetPasswordForm extends StatefulWidget {
  final void Function(String) onResetPassword;
  bool hasMinLength(String value) => value.length >= 8;
  bool hasUppercase(String value) => value.contains(RegExp(r'[A-Z]'));
  bool hasNumber(String value) => value.contains(RegExp(r'[0-9]'));
  bool hasSpecialChar(String value) => value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\[\]\/~`+=;]'));


  const ResetPasswordForm({
    super.key,
    required this.onResetPassword,
  });

  @override
  State<StatefulWidget> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _acceptPolicy = false;

  bool has8Chars = false;
  bool hasUpper = false;
  bool hasNum = false;
  bool hasSpecial = false;

  bool get _canSubmit => has8Chars && hasUpper && hasNum && hasSpecial;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      final text = newPasswordController.text;
      setState(() {
        has8Chars = widget.hasMinLength(text);
        hasUpper = widget.hasUppercase(text);
        hasNum = widget.hasNumber(text);
        hasSpecial = widget.hasSpecialChar(text);
      });
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Widget buildRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  bool _checkConfirmPassword() {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_password_not_match)),
      );
      return false;
    }
    return true;
  }

  void _showPolicyDialog({required int initialTab}) {
    showDialog<void>(
      context: context,
      builder: (_) => PolicyDialog(initialTab: initialTab),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80, width: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    l10n.reset_password,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    l10n.create_new_pass_guide,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  LoginCustomInput(
                    hintText: l10n.new_password_hint,
                    label: l10n.new_password_label,
                    controller: newPasswordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  LoginCustomInput(
                    hintText: l10n.confirm_pass_hint,
                    label: l10n.confirm_pass_label,
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  //Badge rules
                  const SizedBox(height: 10),

                  buildRule(l10n.password_rule_length, has8Chars),
                  buildRule(l10n.password_rule_uppercase, hasUpper),
                  buildRule(l10n.password_rule_number, hasNum),
                  buildRule(l10n.password_rule_special, hasSpecial),
                  const SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _acceptPolicy = !_acceptPolicy;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptPolicy,
                            onChanged: (value) {
                              setState(() {
                                _acceptPolicy = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    l10n.i_accept_the,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () => _showPolicyDialog(initialTab: 0),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(l10n.terms_of_service),
                                  ),
                                  Text(
                                    ' & ',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () => _showPolicyDialog(initialTab: 1),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(l10n.privacy_policy),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey;
                        }
                        return Colors.blueAccent;
                      }),
                      minimumSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      )),
                    ),
                    onPressed: !_acceptPolicy ? null : () {
                      if (!_canSubmit) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mat khau chua dat yeu cau toi thieu'),
                          ),
                        );
                        return;
                      }

                      if (!_checkConfirmPassword()) return;
                      widget.onResetPassword(newPasswordController.text);
                    },
                    child: Text(
                      l10n.submit,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}