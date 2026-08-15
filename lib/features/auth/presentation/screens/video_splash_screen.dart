import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'welcome_screen.dart';

/// Элегантный полноэкранный видео-сплэш на базе splash1.mp4
class VideoSplashScreen extends ConsumerStatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  ConsumerState<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends ConsumerState<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Инициализируем видео-плеер из ассетов
    _controller = VideoPlayerController.asset('assets/videos/splash1.mp4');

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
      
      _controller.play();
      _controller.setLooping(false);

      // Слушаем окончание видео для перехода к следующему экрану
      _controller.addListener(_videoListener);
    }).catchError((error) {
      debugPrint("Video Player initialization failed: $error");
      _navigateToNextScreen("init_failed");
    });
  }

  void _videoListener() {
    if (!mounted) return;
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final isPlaying = _controller.value.isPlaying;
    debugPrint("VideoListener: position=$position, duration=$duration, isPlaying=$isPlaying, hasError=${_controller.value.hasError}");

    if (_controller.value.hasError) {
      debugPrint("Video error during playback: ${_controller.value.errorDescription}");
      _controller.removeListener(_videoListener);
      _navigateToNextScreen("video_error");
      return;
    }
    
    if (duration > Duration.zero && position >= duration) {
      debugPrint("VideoListener: Video finished playing (position >= duration)");
      _controller.removeListener(_videoListener);
      _navigateToNextScreen("video_finished");
    }
  }

  void _navigateToNextScreen([String reason = 'unknown']) {
    if (!mounted) return;
    debugPrint("VideoSplashScreen: Navigating to next screen. Reason: $reason");

    final authStateAsync = ref.read(authStateProvider);

    // Если состояние авторизации все еще загружается, ждем его завершения
    if (authStateAsync.isLoading) {
      debugPrint("VideoSplashScreen: AuthState is loading, delaying navigation...");
      Future.delayed(const Duration(milliseconds: 150), () => _navigateToNextScreen(reason));
      return;
    }

    final user = authStateAsync.value;
    final Widget nextScreen = user != null ? const DashboardScreen() : const WelcomeScreen();

    // Переходим на следующий экран с красивым кросс-фейдом
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Премиальный глубокий черный цвет
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.aspectRatio * 100,
                  height: 100,
                  child: VideoPlayer(_controller),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms)
          else
            // Красивый индикатор инициализации в стиле приложения
            Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF00F2FE).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
