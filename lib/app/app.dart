import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/screens/lightweight_splash_screen.dart';
import '../features/auth/presentation/screens/video_splash_screen.dart';

/// Главный корневой виджет приложения FlowPulse.
///
/// Конфигурирует общую тему приложения, системные шрифты, а также
/// запускает видео-сплэш [VideoSplashScreen], который затем перенаправляет
/// пользователя на [DashboardScreen] или [WelcomeScreen].
class FlowPulseApp extends ConsumerWidget {
  const FlowPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget home = defaultTargetPlatform == TargetPlatform.android
        ? const LightweightSplashScreen()
        : const VideoSplashScreen();

    return MaterialApp(
      title: 'FlowPulse',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: home,
    );
  }
}
