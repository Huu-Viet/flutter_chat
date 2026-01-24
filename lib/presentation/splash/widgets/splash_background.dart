import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;
  
  const SplashBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                  theme.primaryColor.withValues(alpha: 0.9),
                ],
        ),
      ),
      child: child,
    );
  }
}