import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/auth/widgets/otp_input.dart';

class OtpVerificationForm extends StatefulWidget {
  final String email;
  final Function(String) onOtpComplete;
  final Function(String) onResendOtp;

  const OtpVerificationForm({
    super.key,
    required this.email,
    required this.onOtpComplete,
    required this.onResendOtp,
  });

  @override
  State<OtpVerificationForm> createState() => _OtpVerificationFormState();
}

class _OtpVerificationFormState extends State<OtpVerificationForm> {
  static const int _resendCooldownSeconds = 60;

  Timer? _resendTimer;
  int _secondsLeft = _resendCooldownSeconds;

  String _otp = '';

  bool get _canSubmit => _otp.length == 6;

  void _submitOtp() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    widget.onOtpComplete(_otp);
  }

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() {
      _secondsLeft = _resendCooldownSeconds;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
        return;
      }

      setState(() {
        _secondsLeft--;
      });
    });
  }

  Future<void> _onResendTap() async {
    if (_secondsLeft > 0) return;
    await widget.onResendOtp(widget.email);
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canResend = _secondsLeft == 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            
                Text(
                  l10n.verify_code_label,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
            
                Text(
                  l10n.verify_code_guide,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
            
                OTPInput(
                  onOTPChanged: (otp) {
                    setState(() {
                      _otp = otp;
                    });
                  },
                  onOTPComplete: () {
                    _submitOtp();
                  },
                ),
            
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: canResend ? _onResendTap : null,
                  child: Text(
                    canResend
                        ? l10n.resend_code
                        : '${l10n.resend_code} (${_secondsLeft}s)',
                    style: TextStyle(
                      color: canResend
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
                      minimumSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    onPressed: _canSubmit ? _submitOtp : null,
                    child: Text(
                      l10n.submit,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}