import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/presentation/auth/providers/auth_bloc_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../blocs/phone_auth_bloc/phone_auth_bloc.dart';
import '../widgets/otp_input.dart';
import '../widgets/resend_otp_widget.dart';

class OTPVerificationPage extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  
  const OTPVerificationPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends ConsumerState<OTPVerificationPage> {
  String _currentOTP = '';
  bool _isOTPComplete = false;

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+84')) {
      final number = phoneNumber.substring(3);
      if (number.length >= 9) {
        return '+84 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
      }
    }
    return phoneNumber;
  }

  void _onOTPChanged(String otp) {
    setState(() {
      _currentOTP = otp;
      _isOTPComplete = otp.length == 6;
    });
  }

  void _onOTPComplete() {
    if (_isOTPComplete) {
      final phoneAuthBloc = ref.read(phoneAuthBlocProvider);
      phoneAuthBloc.add(VerifyOTPEvent(widget.verificationId, _currentOTP));
    }
  }

  void _resendOTP() {
    final phoneAuthBloc = ref.read(phoneAuthBlocProvider);
    phoneAuthBloc.add(ResendOTPEvent(widget.phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    final phoneAuthBloc = ref.watch(phoneAuthBlocProvider);

    return BlocProvider<PhoneAuthBloc>.value(
      value: phoneAuthBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Xác thực OTP'),
          centerTitle: true,
        ),
        body: BlocListener<PhoneAuthBloc, PhoneAuthState>(
          listener: (context, state) {
            if (state is PhoneAuthSuccess) {
              if (state.isNewUser) {
                context.go('/set-profile');
              } else {
                context.go('/home');
              }
            } else if (state is PhoneAuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is OTPResent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mã xác thực đã được gửi lại'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             kToolbarHeight - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    Text(
                      'Nhập mã xác thực',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Mã xác thực đã được gửi đến số\n${_formatPhoneNumber(widget.phoneNumber)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    OTPInput(
                      onOTPChanged: _onOTPChanged,
                      onOTPComplete: _onOTPComplete,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is PhoneAuthLoading || !_isOTPComplete
                              ? null
                              : _onOTPComplete,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is PhoneAuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Xác thực',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ResendOTPWidget(onResend: _resendOTP),
                    
                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Thay đổi số điện thoại'),
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