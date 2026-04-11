import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/widgets/step_indicator.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/blocs/registry_bloc/registry_bloc.dart';
import 'package:flutter_chat/presentation/auth/providers/auth_bloc_providers.dart';
import 'package:flutter_chat/presentation/auth/widgets/otp_verification_form.dart';
import 'package:flutter_chat/presentation/auth/widgets/registry_init_form.dart';
import 'package:flutter_chat/presentation/auth/widgets/reset_password_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistryPage extends ConsumerStatefulWidget {
  const RegistryPage({super.key});

  @override
  ConsumerState<RegistryPage> createState() => _RegistryState();
}

class _RegistryState extends ConsumerState<RegistryPage> {
  late final PageController _pageController;

  int _currentIndex = 0;
  bool _showLoading = false;

  String _submittedEmail = '';
  String _submittedFirstName = '';
  String _submittedLastName = '';
  String _registrationToken = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? 0;
      if (newIndex != _currentIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int? _extractStatusCode(String message) {
    final match = RegExp(r'(\d{3})').firstMatch(message);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  String _mapRegistryError(int? statusCode, AppLocalizations l10n) {
    if (_currentIndex == 0) {
      if (statusCode == 409) return l10n.error_email_exist;
      if (statusCode == 429) return l10n.error_too_many_attempts;
      if (statusCode == 400) return l10n.error_info_invalid;
      return '${l10n.error_unknown} (${statusCode ?? "unknown"})';
    }

    if (_currentIndex == 1) {
      if (statusCode == 400) return l10n.error_otp_invalid;
      if (statusCode == 429) return l10n.error_too_many_attempts;
      return '${l10n.error_unknown} (${statusCode ?? "unknown"})';
    }

    if (_currentIndex == 2) {
      if (statusCode == 400) return l10n.error_registry_token;
      if (statusCode == 409) return l10n.error_email_exist;
      if (statusCode == 500) return l10n.error_unknown;
      return '${l10n.error_unknown} (${statusCode ?? "unknown"})';
    }

    return 'Da co loi xay ra';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final registryBloc = ref.watch(registryBlocProvider);

    return BlocProvider<RegistryBloc>.value(
      value: registryBloc,
      child: BlocListener<RegistryBloc, RegistryState>(
        listener: (context, state) {
          if (state is RegistryLoading) {
            setState(() => _showLoading = true);
          } else if (state is RegistryInitSuccess) {
            setState(() {
              _showLoading = false;
              _registrationToken = '';
            });
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } else if (state is RegistryVerifyOtpSuccess) {
            setState(() {
              _showLoading = false;
              _registrationToken = state.registrationToken;
            });
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } else if (state is RegistryCompleteSuccess) {
            setState(() => _showLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.success_registry)),
            );
            context.go('/login');
          } else if (state is RegistryError) {
            setState(() => _showLoading = false);
            final statusCode = _extractStatusCode(state.message);
            final message = _mapRegistryError(statusCode, l10n);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      RegistryInitForm(
                        isLoading: _showLoading,
                        onSubmit: (email, firstName, lastName) {
                          _registrationToken = '';
                          _submittedEmail = email;
                          _submittedFirstName = firstName;
                          _submittedLastName = lastName;
                          registryBloc.add(
                            RegistryInitEvent(
                              email: _submittedEmail,
                              firstName: _submittedFirstName,
                              lastName: _submittedLastName,
                            ),
                          );
                        },
                      ),
                      OtpVerificationForm(
                        email: _submittedEmail,
                        onOtpComplete: (otp) {
                          _registrationToken = '';
                          registryBloc.add(
                            RegistryVerifyOtpEvent(
                              email: _submittedEmail,
                              otp: otp.trim(),
                            ),
                          );
                        },
                        onResendOtp: (email) async {
                          _registrationToken = '';
                          registryBloc.add(
                            RegistryInitEvent(
                              email: _submittedEmail,
                              firstName: _submittedFirstName,
                              lastName: _submittedLastName,
                            ),
                          );
                        },
                      ),
                      ResetPasswordForm(
                        onResetPassword: (newPass) {
                          if (_registrationToken.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thieu ma dang ky')),
                            );
                            return;
                          }

                          registryBloc.add(
                            RegistryCompleteEvent(
                              registrationToken: _registrationToken,
                              password: newPass.trim(),
                              platform: 'mobile',
                              deviceName: null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                  child: StepIndicator(currentIndex: _currentIndex, total: 3),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 36.0, 0, 0),
                  child: IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                if (_showLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}