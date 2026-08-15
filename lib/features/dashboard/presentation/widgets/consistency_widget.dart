import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: "Consistency" (Еженедельный фокус).
///
/// Отрисовывает сглаженную неоновую кривую Безье активности за неделю
/// и выводит процентные метрики удержания фокуса на основе statsProvider.
class ConsistencyWidget extends ConsumerWidget {
  const ConsistencyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const accentColor = Color(0xFF30D158); // Apple Green / Neon Mint

    final stats = ref.watch(statsProvider);
    final dataPoints = stats.weeklyFocusMinutes;

    // Вычисляем средний процент фокусировки за неделю
    final double totalSum = dataPoints.reduce((a, b) => a + b);
    final int focusPercent = ((totalSum / dataPoints.length) * 100).round();

    return AppleWidgetCard(
      title: 'Consistency',
      subtitle: 'Weekly Focus',
      icon: Icons.track_changes_outlined,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Область интерактивного графика
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _BezierWavePainter(
                    accentColor: accentColor,
                    dataPoints: dataPoints,
                  ),
                );
              },
            ),
          ),
          const Gap(6),
          
          // Буквенные индикаторы дней недели
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayLabel('M'),
              _DayLabel('T'),
              _DayLabel('W'),
              _DayLabel('T'),
              _DayLabel('F'),
              _DayLabel('S'),
              _DayLabel('S'),
            ],
          ),
          const Gap(10),
          
          // Описание прогресса
          Text(
            focusPercent == 0
                ? "Start a Pomodoro work sprint to begin drawing your weekly consistency curve!"
                : "You've stayed focused $focusPercent% of your goal this week! Maintain the flow!",
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.95),
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String char;
  const _DayLabel(this.char);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: Text(
        char,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Рисует сглаженный светящийся волновой график активности
class _BezierWavePainter extends CustomPainter {
  final Color accentColor;
  final List<double> dataPoints;

  _BezierWavePainter({required this.accentColor, required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;

    // Расстояние между точками по горизонтали
    final stepX = width / (dataPoints.length - 1);
    
    // Преобразуем относительные точки (0..1) во фрейм координат canvas (инверсия по Y)
    final points = <Offset>[];
    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      // Ограничим график сверху и снизу отступами в 8px, чтобы неоновые линии не обрезались
      final y = height - (dataPoints[i] * (height - 16) + 8);
      points.add(Offset(x, y));
    }

    // Создаем сглаженный путь с помощью кривых Безье
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      
      // Контрольные точки для кубического Безье
      final controlPoint1 = Offset(p1.dx + stepX / 2, p1.dy);
      final controlPoint2 = Offset(p2.dx - stepX / 2, p2.dy);
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    // 1. Рисуем градиентную заливку ПОД кривой
    final fillPath = Path.from(path);
    // Закрываем контур по нижней границе
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0.22),
          accentColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 2. Рисуем свечение кривой
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, glowPaint);

    // 3. Рисуем саму неоновую кривую Безье
    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 4. Добавляем активный светящийся маркер на последнюю (пиковую) точку
    final peakPoint = points[6];
    
    // Внешнее кольцо свечения
    canvas.drawCircle(
      peakPoint,
      6.0,
      Paint()
        ..color = accentColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    // Внутренняя белая точка
    canvas.drawCircle(
      peakPoint,
      2.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _BezierWavePainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || oldDelegate.dataPoints != dataPoints;
  }
}
