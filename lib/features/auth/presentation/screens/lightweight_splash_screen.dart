import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'welcome_screen.dart';

class LightweightSplashScreen extends ConsumerStatefulWidget {
  const LightweightSplashScreen({super.key});

  @override
  ConsumerState<LightweightSplashScreen> createState() => _LightweightSplashScreenState();
}

class _LightweightSplashScreenState extends ConsumerState<LightweightSplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 900), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final authStateAsync = ref.read(authStateProvider);

    if (authStateAsync.isLoading) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 150), _navigateToNextScreen);
      return;
    }

    final user = authStateAsync.value;
    final Widget nextScreen = user != null ? const DashboardScreen() : const WelcomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final showSpinner = !reduceMotion;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/apple_3d_flame.png',
                width: 72,
                height: 72,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 18),
              const Text(
                'FlowPulse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 18),
              if (showSpinner)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF00F2FE).withValues(alpha: 0.85),
                    ),
                  ),
                )
              else
                Text(
                  kIsWeb ? 'Loading…' : 'Loading…',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
