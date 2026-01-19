import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/presentation/auth/providers/auth_bloc_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../blocs/phone_auth_bloc.dart';
import '../widgets/phone_input_form.dart';

class PhoneInputPage extends ConsumerWidget {
  const PhoneInputPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneAuthBloc = ref.watch(phoneAuthBlocProvider);

    return BlocProvider<PhoneAuthBloc>.value(
      value: phoneAuthBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đăng nhập'),
          centerTitle: true,
        ),
        body: BlocListener<PhoneAuthBloc, PhoneAuthState>(
          listener: (context, state) {
            if (state is OTPSent) {
              log('Navigating to OTP screen with verificationId: ${state.verificationId}');
              context.push('/otp-verify', extra: {
                'verificationId': state.verificationId,
                'phoneNumber': state.phoneNumber,
              });
            } else if (state is PhoneAuthError) {
              log('PhoneAuth error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
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
                             kToolbarHeight - 48, // AppBar height + padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      Text(
                        'Nhập số điện thoại',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Chúng tôi sẽ gửi mã xác thực đến số điện thoại của bạn',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                        builder: (context, state) {
                          return PhoneInputForm(
                            isLoading: state is PhoneAuthLoading,
                            onPhoneSubmit: (phoneNumber) {
                              log('Submitting phone number: $phoneNumber'); // Debug log
                              phoneAuthBloc.add(SendOTPEvent(phoneNumber));
                            },
                          );
                        },
                      ),
                      
                      const Spacer(),
                      
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          'Bằng cách tiếp tục, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật của chúng tôi',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}