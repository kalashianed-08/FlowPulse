import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/common_widgets/glass_container.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

/// Премиальный стартовый экран приветствия и авторизации "Welcome Screen".
///
/// Полностью спроектирован в стиле Apple Glass UI:
/// - Сверхвысокое размытие BackdropFilter (30px)
/// - Светоотражающие торцы кнопок авторизации
/// - Светящийся 3D Apple-логотип Flame
/// - Интерактивный гостевой вход "Demo Drive".
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isLoading = false;

  void _showLoading(bool show) {
    setState(() {
      _isLoading = show;
    });
  }

  Future<void> _handleAnonymousSignIn() async {
    _showLoading(true);
    try {
      if (Firebase.apps.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        return;
      }
      await ref.read(authServiceProvider).signInAnonymously();
    } catch (e) {
      _showErrorSnackBar('Anonymous Login Failed: $e');
    } finally {
      _showLoading(false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _showLoading(true);
    try {
      if (Firebase.apps.isEmpty) {
        _showErrorSnackBar('Google Login Disabled on this device.');
        return;
      }
      final credentials = await ref.read(authServiceProvider).signInWithGoogle();
      if (credentials == null) {
        // Пользователь сам закрыл окно входа
        _showLoading(false);
      }
    } catch (e) {
      _showErrorSnackBar(
        'Google Login Failed.\nEnsure SHA-1 key is registered in Firebase Console.',
      );
      _showLoading(false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    _showLoading(true);
    try {
      if (Firebase.apps.isEmpty) {
        _showErrorSnackBar('Apple Sign-In Disabled on this device.');
        return;
      }
      await ref.read(authServiceProvider).signInWithApple();
    } catch (e) {
      _showErrorSnackBar(
        'Apple Sign-In Failed.\nApple Developer Account is required for native iOS entitlements.',
      );
    } finally {
      _showLoading(false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Динамический фоновый градиент (Glowing Blobs)
          const Positioned.fill(
            child: _AnimatedWelcomeGlow(),
          ),

          // 2. Основное содержимое (Центрированный контент)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Gap(40),
                  
                  // Логотип и Название (Center Block)
                  Column(
                    children: [
                      // Стеклянный светящийся логотип с оригинальным 🔥 Apple
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x22131A26),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5E62).withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/apple_3d_flame.png',
                            width: 48,
                            height: 48,
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .slideY(begin: 0.0, end: -0.1, duration: 1800.ms, curve: Curves.easeInOut)
                              .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 1800.ms, curve: Curves.easeInOut)
                              .shimmer(duration: 4000.ms, color: Colors.white24),
                        ),
                      )
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.easeOutBack)
                          .fadeIn(duration: 600.ms),
                      const Gap(24),
                      
                      // Название FlowPulse
                      Text(
                        'FlowPulse',
                        style: Theme.of(context).textTheme.displayLarge,
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.15, end: 0),
                      const Gap(6),
                      
                      // Девиз
                      Text(
                        'Breathe. Focus. Recover.',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),
                    ],
                  ),

                  // Кнопки входа (Bottom Block)
                  Column(
                    children: [
                      // Кнопка Apple Sign-In
                      _buildAuthButton(
                        text: 'Continue with Apple',
                        icon: Icons.apple_rounded,
                        isApple: true,
                        onTap: _handleAppleSignIn,
                      ).animate().fadeIn(duration: 500.ms, delay: 350.ms).slideY(begin: 0.2, end: 0),
                      const Gap(14),
                      
                      // Кнопка Google Sign-In
                      _buildAuthButton(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata_rounded, // Красивый плоский префикс-заглушка Google
                        isApple: false,
                        onTap: _handleGoogleSignIn,
                      ).animate().fadeIn(duration: 500.ms, delay: 450.ms).slideY(begin: 0.2, end: 0),
                      const Gap(20),
                      
                      // Разделитель
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1)),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                      const Gap(18),
                      
                      // Кнопка Демо-входа (Demo Drive / Guest)
                      GestureDetector(
                        onTap: _handleAnonymousSignIn,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF00F2FE).withValues(alpha: 0.25),
                              width: 1,
                            ),
                            color: const Color(0xFF00F2FE).withValues(alpha: 0.03),
                          ),
                          child: const Center(
                            child: Text(
                              'Quick Demo Drive',
                              style: TextStyle(
                                color: Color(0xFF00F2FE),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 550.ms).slideY(begin: 0.2, end: 0),
                      const Gap(14),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Загрузочный экран-заглушка (Frosted loading spinner)
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: GlassContainer(
                    width: 90,
                    height: 90,
                    padding: EdgeInsets.zero,
                    borderRadius: 20,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00F2FE),
                        strokeWidth: 3.5,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildAuthButton({
    required String text,
    required IconData icon,
    required bool isApple,
    required VoidCallback onTap,
  }) {
    final bgColor = isApple ? const Color(0xFF0F1621) : const Color(0x0EFFFFFF);
    final fgColor = Colors.white;
    final borderColor = isApple 
        ? Colors.white.withValues(alpha: 0.08) 
        : Colors.white.withValues(alpha: 0.14);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: fgColor,
              size: isApple ? 20 : 26, // Google иконка-заглушка крупнее
            ),
            const Gap(12),
            Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Анимированный фоновый неоновый перелив для экрана приветствия
class _AnimatedWelcomeGlow extends StatelessWidget {
  const _AnimatedWelcomeGlow();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WelcomeGlowPainter(),
    );
  }
}

class _WelcomeGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Верхний правый циан
    final paint1 = Paint()
      ..color = const Color(0xFF00F2FE).withValues(alpha: 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    // 2. Средний левый коралловый
    final paint2 = Paint()
      ..color = const Color(0xFFFF5E62).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 110);

    canvas.drawCircle(Offset(width * 0.85, height * 0.20), 190, paint1);
    canvas.drawCircle(Offset(width * 0.15, height * 0.60), 200, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
