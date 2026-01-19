import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Widget logo;
  
  const SplashContent({
    super.key,
    required this.fadeAnimation,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          logo,
          const SizedBox(height: 32),
          
          // App name
          const Text(
            'Flutter Chat',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Connect with everyone',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Loading indicator
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.3),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Loading text
          const Text(
            'Đang khởi tạo...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}