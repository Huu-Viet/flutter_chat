import 'package:flutter/material.dart';
import 'dart:async';

class ResendOTPWidget extends StatefulWidget {
  final Function() onResend;
  final int initialSeconds;

  const ResendOTPWidget({
    super.key,
    required this.onResend,
    this.initialSeconds = 60,
  });

  @override
  State<ResendOTPWidget> createState() => _ResendOTPWidgetState();
}

class _ResendOTPWidgetState extends State<ResendOTPWidget> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = widget.initialSeconds;
      _canResend = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    widget.onResend();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Không nhận được mã? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        
        if (_canResend)
          TextButton(
            onPressed: _handleResend,
            child: const Text(
              'Gửi lại',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          )
        else
          Text(
            'Gửi lại sau ${_remainingSeconds}s',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }
}