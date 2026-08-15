import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: Таймер микро-разминки "Micro-Stretch".
///
/// Предоставляет круговой прогресс-бар, таймер отсчета, кнопку сброса
/// и циклический селектор различных разминочных асан (шея, плечи, запястья).
class MicroStretchWidget extends ConsumerStatefulWidget {
  const MicroStretchWidget({super.key});

  @override
  ConsumerState<MicroStretchWidget> createState() => _MicroStretchWidgetState();
}

class _MicroStretchWidgetState extends ConsumerState<MicroStretchWidget> {
  bool _isTimerActive = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  final List<String> _postures = [
    'Stretch: Neck Tilt - Hold 15s each side',
    'Stretch: Shoulder Roll - 10 reps backward',
    'Stretch: Wrist Release - Rotate both ways',
    'Stretch: Spinal Twist - Hold 20s each side',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextPosture(int currentIndex) {
    final nextIndex = (currentIndex + 1) % _postures.length;
    ref.read(statsProvider.notifier).setPostureIndex(nextIndex);
  }

  void _prevPosture(int currentIndex) {
    final prevIndex = (currentIndex - 1 + _postures.length) % _postures.length;
    ref.read(statsProvider.notifier).setPostureIndex(prevIndex);
  }

  void _startTimer(int minutes) {
    setState(() {
      _isTimerActive = true;
      _secondsRemaining = minutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _completeStretch();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerActive = false;
      _secondsRemaining = 0;
    });
  }

  void _completeStretch() {
    _timer?.cancel();
    
    // Передаем завершенную разминку в глобальный провайдер
    ref.read(statsProvider.notifier).completeStretchSession();

    setState(() {
      _isTimerActive = false;
      _secondsRemaining = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '🪷 Beautifully stretched! Added active break relief to your daily log.',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF007AFF),
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
    const accentColor = Color(0xFF007AFF); // Apple Royal Blue / Focus Blue

    final stats = ref.watch(statsProvider);
    final postureIndex = stats.postureIndex;
    final stretchTimeMinutes = stats.stretchTimeMinutes;

    // Рассчитываем процент прогресса для круга
    final double progress = _isTimerActive
        ? (1.0 - (_secondsRemaining / (stretchTimeMinutes * 60.0)))
        : 0.0;

    return AppleWidgetCard(
      title: 'Micro-Stretch',
      subtitle: _isTimerActive ? 'Stretching Active' : 'Active Micro-Stretch',
      icon: Icons.accessibility_new_rounded,
      emojiAssetPath: 'assets/images/apple_3d_lotus.png',
      accentColor: accentColor,
      child: Column(
        children: [
          // Круговой таймер
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Полный круговой неоновый индикатор
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      progress: _isTimerActive ? progress : 1.0, // Полный круг в состоянии готовности
                      color: _isTimerActive ? accentColor : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                
                // Текст по центру круга
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isTimerActive ? 'ELAPSED' : 'READY TO',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      _isTimerActive ? _formatTime() : 'STRETCH',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    
                    // Кнопка Старт/Сброс в круге
                    GestureDetector(
                      onTap: () {
                        if (_isTimerActive) {
                          _resetTimer();
                        } else {
                          _startTimer(stretchTimeMinutes);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isTimerActive 
                              ? const Color(0xFFFF5E62).withValues(alpha: 0.15) 
                              : const Color(0xFF00F2FE).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _isTimerActive 
                                ? const Color(0xFFFF5E62).withValues(alpha: 0.4) 
                                : const Color(0xFF00F2FE).withValues(alpha: 0.4), 
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          _isTimerActive ? 'RESET' : 'START 1M',
                          style: TextStyle(
                            color: _isTimerActive ? const Color(0xFFFF5E62) : const Color(0xFF00F2FE),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Кнопка быстрого завершения
                if (_isTimerActive)
                  Positioned(
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _completeStretch,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF30D158).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF30D158).withValues(alpha: 0.3), width: 0.6),
                        ),
                        child: const Text(
                          'COMPLETE',
                          style: TextStyle(
                            color: Color(0xFF30D158),
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(4),
          
          // Панель управления упражнениями
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
                // Стрелка влево
                _buildCircleButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _prevPosture(postureIndex),
                ),
                
                // Описание растяжки
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      _postures[postureIndex],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.95),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Стрелка вправо
                _buildCircleButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _nextPosture(postureIndex),
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
        width: 24,
        height: 24,
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

/// Рисует круговой светящийся циферблат
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Вектор старта — вертикально вверх (-90 градусов или -pi/2)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    
    // 1. Отрисовка фонового круга-трека
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(center, radius, trackPaint);
    
    // Если прогресс нулевой и цвет фоновый, рисуем только трек
    if (progress == 0.0 || color == Colors.white.withValues(alpha: 0.05)) return;
    
    // 2. Свечение активной дуги
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    
    // 3. Активная неоновая дуга с градиентом
    final strokePaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.7), color, color],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(startAngle),
      ).createShader(rect)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(rect, startAngle, sweepAngle, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
