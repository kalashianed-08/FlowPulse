import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: Помодоро-таймер "Focus Session".
///
/// Предоставляет полукруглый светящийся индикатор и кнопки регулировки
/// длительности сессии работы, а также интерактивный таймер с симуляцией.
class FocusSessionWidget extends ConsumerStatefulWidget {
  const FocusSessionWidget({super.key});

  @override
  ConsumerState<FocusSessionWidget> createState() => _FocusSessionWidgetState();
}

class _FocusSessionWidgetState extends ConsumerState<FocusSessionWidget> {
  int _minutes = 25;
  bool _isRunning = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _increment() {
    if (_minutes < 90) {
      setState(() => _minutes += 5);
    }
  }

  void _decrement() {
    if (_minutes > 5) {
      setState(() => _minutes -= 5);
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _secondsRemaining = _minutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    
    // Передаем завершенные минуты в глобальный провайдер
    ref.read(statsProvider.notifier).completeFocusSession(_minutes);

    setState(() {
      _isRunning = false;
      _secondsRemaining = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Awesome job! You completed a $_minutes mins focus sprint!',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF30D158),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
      ),
    );
  }

  String _formatTime() {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00F2FE);

    // Расчет прогресса для дуги
    final double arcProgress = _isRunning
        ? (_secondsRemaining / (_minutes * 60.0))
        : (_minutes / 60.0);

    return AppleWidgetCard(
      title: 'Focus Session',
      subtitle: _isRunning ? 'Session Active' : 'Posture Timer',
      icon: Icons.psychology_outlined,
      emojiAssetPath: 'assets/images/apple_3d_brain.png',
      accentColor: accentColor,
      child: Column(
        children: [
          // Блок с графиком-дугой
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Полукруглая неоновая дуга
                SizedBox(
                  width: 140,
                  height: 90,
                  child: CustomPaint(
                    painter: _FocusArcPainter(
                      progress: arcProgress,
                      color: accentColor,
                    ),
                  ),
                ),
                
                // Текст по центру дуги
                Positioned(
                  top: 28,
                  child: Column(
                    children: [
                      Text(
                        _isRunning ? 'REMAINING' : 'WORK SPRINT',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        _isRunning ? _formatTime() : '$_minutes MINS',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        _isRunning ? 'FOCUSING' : 'READY',
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Интерактивная панель управления
          if (!_isRunning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка Минус
                  _buildCircleButton(
                    icon: Icons.remove,
                    onTap: _decrement,
                  ),
                  
                  // Кнопка Старта по центру
                  GestureDetector(
                    onTap: _startTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: const Text(
                        'START SPRINT',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  
                  // Кнопка Плюс
                  _buildCircleButton(
                    icon: Icons.add,
                    onTap: _increment,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Кнопка Паузы
                  GestureDetector(
                    onTap: _pauseTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder, width: 0.8),
                      ),
                      child: const Text(
                        'PAUSE',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Кнопка быстрого завершения для тестирования показателей
                  GestureDetector(
                    onTap: _completeSession,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30D158).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF30D158).withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: const Text(
                        'COMPLETE NOW',
                        style: TextStyle(
                          color: Color(0xFF30D158),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 14,
        ),
      ),
    );
  }
}

/// Рисование неоновой полукруглой дуги прогресса таймера
class _FocusArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _FocusArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2.2;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Начало дуги — слева снизу (180 градусов или pi)
    const startAngle = math.pi;
    const sweepAngle = math.pi; // Общий размер дуги — полкруга (180 град)
    
    // 1. Рисуем фоновую дугу (Track)
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    
    // Вычисляем угол заполнения
    final activeSweep = sweepAngle * progress.clamp(0.0, 1.0);
    
    // 2. Рисуем свечение под активным треком
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
    canvas.drawArc(rect, startAngle, activeSweep, false, glowPaint);
    
    // 3. Рисуем саму неоновую линию (Active Track)
    final activePaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.8), color],
      ).createShader(rect)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(rect, startAngle, activeSweep, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _FocusArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
