import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/widgets/step_indicator.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/blocs/account_bloc/account_bloc.dart';
import 'package:flutter_chat/presentation/auth/providers/auth_bloc_providers.dart';
import 'package:flutter_chat/presentation/auth/widgets/forgot_password_form.dart';
import 'package:flutter_chat/presentation/auth/widgets/otp_verification_form.dart';
import 'package:flutter_chat/presentation/auth/widgets/reset_password_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _showLoading = false;

  String _submittedEmail = '';
  String _resetToken = '';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountBloc = ref.watch(grantedAccountAuthBlocProvider);
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? 0;
      if (_currentIndex != newIndex) {
        _currentIndex = newIndex;
      }
    });

    return BlocProvider<AccountBloc>.value(
      value: accountBloc,
      child: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if(state is AccountLoading) {
            _showLoading = true;
          } else if (state is AccountForgotPasswordSuccess){
            _showLoading = false;
            _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut
            );
          } else if(state is AccountError) {
            _showLoading = false;
            debugPrint('[ForgotPasswordPage] Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.error_email_not_found)),
            );
          } else if(state is AccountVerifyOtpSuccess) {
              _showLoading = false;
              _resetToken = state.resetToken;
              _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut
              );
          } else if (state is AccountResetPasswordSuccess) {
            _showLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.success_password_reset)),
            );
            context.go('/login');
          }
        },
        child: Center(
          child: Stack(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    IntrinsicHeight(
                      child: ForgotPasswordForm(
                        isLoading: _showLoading,
                        onSubmit: (email) {
                          _submittedEmail = email;
                          accountBloc.add(ForgotPasswordEvent(email));
                        },
                      ),
                    ),
                    IntrinsicHeight(
                        child: OtpVerificationForm(
                          email: _submittedEmail,
                          onOtpComplete: (otp) {
                            if(_submittedEmail.isEmpty) return;
                            debugPrint('[ForgotPasswordPage] Email: $_submittedEmail, OTP: $otp');
                            accountBloc.add(VerifyOtpEvent(
                                email: _submittedEmail,
                                otp: otp
                            ));
                          },
                          onResendOtp: (email) async {
                            accountBloc.add(ForgotPasswordEvent(email));
                          },
                        )
                    ),
                    IntrinsicHeight(
                        child: ResetPasswordForm(onResetPassword: (newPass) {
                          if(_resetToken.isEmpty) return;
                          debugPrint('[ForgotPasswordPage] Reset token: $_resetToken, New password: $newPass');
                          accountBloc.add(ResetPasswordEvent(
                              resetToken: _resetToken,
                              newPassword: newPass
                          ));
                        })
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
                    onPressed: () {
                      context.go('/login');
                    },
                    icon: const Icon(Icons.arrow_back)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}