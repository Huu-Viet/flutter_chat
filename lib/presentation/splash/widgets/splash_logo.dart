import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  
  const SplashLogo({
    super.key,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Hero(
        tag: 'app-logo',
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 60,
            color: Color(0xFF6C63FF),
          ),
        ),
      ),
    );
  }
}