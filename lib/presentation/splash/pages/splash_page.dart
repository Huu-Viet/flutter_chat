import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/presentation/splash/bloc/splash_bloc.dart';
import 'package:flutter_chat/presentation/splash/providers/splash_bloc_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_content.dart';
import '../widgets/splash_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));
    
    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // await Future.wait([
      //   Future.delayed(const Duration(milliseconds: 500)),
      //   _controller.forward()
      // ]);

      if (mounted) {
        ref.read(splashBlocProvider).add(CheckAuthEvent());
      }
    } catch (e) {
      if (mounted) context.go('/phone-auth');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashBloc = ref.read(splashBlocProvider);
    return BlocProvider<SplashBloc>.value(
      value: splashBloc,
      child: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashInfoSetupComplete) {
              splashBloc.add(SendDeviceTokenEvent());
              context.go("/home");
            } else if (state is SplashUnauthenticated) {
              context.go("/login");
            } else if (state is SplashNotSetupInfo) {
              splashBloc.add(SendDeviceTokenEvent());
              context.go("/set-profile");
            }
          },
          child: Scaffold(
            body: SplashBackground(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SplashContent(
                    fadeAnimation: _fadeAnimation,
                    logo: SplashLogo(scaleAnimation: _scaleAnimation),
                  );
                },
              ),
            ),
          )
      ),
    );
  }
}