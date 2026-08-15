import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: Таймлайн дня "Focus Map".
///
/// Отрисовывает пространственную интерактивную карту-таймлайн
/// пройденных практик за день на координатной сетке со светящимися нодами.
class FocusMapWidget extends ConsumerWidget {
  const FocusMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const accentColor = Color(0xFFBF88FF); // Apple Lavender / Soft Purple

    final stats = ref.watch(statsProvider);
    final stretchSessions = stats.stretchSessionsToday;

    // Задаем относительные координаты (X, Y) нод на карте (от 0.0 до 1.0)
    const node1 = Offset(0.18, 0.60);
    const node2 = Offset(0.44, 0.60);
    const node3 = Offset(0.70, 0.60);
    const node4 = Offset(0.88, 0.30);

    // Ноды разблокируются последовательно в зависимости от завершенных сессий
    final activeNodesCount = (stretchSessions + 1).clamp(1, 4);

    return AppleWidgetCard(
      title: 'Focus Map',
      subtitle: 'Daily Progress',
      icon: Icons.map_outlined,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Подпись с количеством пройденных сессий
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STRETCH SESSIONS: $stretchSessions',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const Icon(
                Icons.directions_run_rounded,
                color: Color(0xFF00F2FE),
                size: 14,
              ),
            ],
          ),
          const Gap(8),
          
          // Поле карты-сетки с нодами
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                final List<Offset> physicalNodes = [
                  Offset(node1.dx * w, node1.dy * h),
                  Offset(node2.dx * w, node2.dy * h),
                  Offset(node3.dx * w, node3.dy * h),
                  Offset(node4.dx * w, node4.dy * h),
                ];

                return Stack(
                  children: [
                    // Рисуем сетку и соединительную светящуюся линию
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MapGridPainter(
                          accentColor: accentColor,
                          nodes: physicalNodes,
                          unlockedCount: activeNodesCount,
                        ),
                      ),
                    ),
                    
                    // Размещаем иконки поверх отрисованных нод
                    _buildNodeIcon(node1, Icons.headset_rounded, w, h, isUnlocked: activeNodesCount >= 1, isTarget: activeNodesCount == 1),
                    _buildNodeIcon(node2, Icons.accessibility_new_rounded, w, h, isUnlocked: activeNodesCount >= 2, isTarget: activeNodesCount == 2),
                    _buildNodeIcon(node3, Icons.back_hand_rounded, w, h, isUnlocked: activeNodesCount >= 3, isTarget: activeNodesCount == 3),
                    _buildNodeIcon(node4, Icons.work_rounded, w, h, isUnlocked: activeNodesCount >= 4, isTarget: activeNodesCount == 4),
                  ],
                );
              },
            ),
          ),
          const Gap(4),
          
          // Информация о следующем перерыве
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stretchSessions >= 3
                    ? '🎉 ALL GOALS REACHED!'
                    : 'NEXT BREAK: 15:00',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stretchSessions >= 3
                    ? 'Great recovery day!'
                    : 'Complete stretch to unlock next node',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodeIcon(
    Offset relativeOffset,
    IconData icon,
    double w,
    double h, {
    required bool isUnlocked,
    required bool isTarget,
  }) {
    const nodeSize = 22.0;
    
    // Рассчитываем физические координаты верхнего левого угла иконки
    final left = relativeOffset.dx * w - (nodeSize / 2);
    final top = relativeOffset.dy * h - (nodeSize / 2);

    final circleColor = isTarget 
        ? const Color(0xFF00F2FE) 
        : isUnlocked 
            ? const Color(0xFFBF88FF) 
            : const Color(0x33131A26);
            
    final borderColor = isTarget 
        ? Colors.white 
        : isUnlocked 
            ? const Color(0xFFBF88FF) 
            : Colors.white.withValues(alpha: 0.1);

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circleColor,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: isTarget
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isTarget ? Colors.black : Colors.white.withValues(alpha: isUnlocked ? 0.9 : 0.25),
            size: 11,
          ),
        ),
      ),
    );
  }
}

/// Рисует координатную сетку и светящуюся тропу прохождения дня
class _MapGridPainter extends CustomPainter {
  final Color accentColor;
  final List<Offset> nodes;
  final int unlockedCount;

  _MapGridPainter({
    required this.accentColor,
    required this.nodes,
    required this.unlockedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Отрисовка координатной сетки (Grid)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 0.8;

    // Рисуем вертикальные линии
    const gridCols = 8;
    final stepX = width / gridCols;
    for (var i = 1; i < gridCols; i++) {
      final x = i * stepX;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Рисуем горизонтальные линии
    const gridRows = 6;
    final stepY = height / gridRows;
    for (var i = 1; i < gridRows; i++) {
      final y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    if (nodes.length < 2) return;

    // 2. Создаем путь прохождения активностей (только для разблокированных нод)
    final path = Path();
    path.moveTo(nodes[0].dx, nodes[0].dy);
    for (var i = 1; i < unlockedCount; i++) {
      path.lineTo(nodes[i].dx, nodes[i].dy);
    }

    // Рисуем тусклый фоновый путь для заблокированных нод
    final lockedPath = Path();
    lockedPath.moveTo(nodes[unlockedCount - 1].dx, nodes[unlockedCount - 1].dy);
    for (var i = unlockedCount; i < nodes.length; i++) {
      lockedPath.lineTo(nodes[i].dx, nodes[i].dy);
    }

    // 3. Рисуем тусклую линию заблокированного пути
    if (unlockedCount < nodes.length) {
      canvas.drawPath(
        lockedPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // 4. Рисуем неоновое свечение тропы
    if (unlockedCount > 1) {
      final glowPaint = Paint()
        ..color = const Color(0xFF00F2FE).withValues(alpha: 0.35)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);

      // 5. Рисуем саму неоновую тропу
      final strokePaint = Paint()
        ..color = const Color(0xFF00F2FE)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, strokePaint);
    }

    // 6. Отрисовываем внешнее свечение колец нод
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final isUnlocked = i < unlockedCount;

      canvas.drawCircle(
        node,
        15.0,
        Paint()
          ..color = isUnlocked 
              ? const Color(0xFF00F2FE).withValues(alpha: 0.08) 
              : Colors.white.withValues(alpha: 0.01)
          ..style = PaintingStyle.fill,
      );
      
      canvas.drawCircle(
        node,
        15.0,
        Paint()
          ..color = isUnlocked 
              ? const Color(0xFF00F2FE).withValues(alpha: 0.2) 
              : Colors.white.withValues(alpha: 0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..maskFilter = isUnlocked 
              ? const MaskFilter.blur(BlurStyle.normal, 2) 
              : null,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || 
           oldDelegate.nodes != nodes || 
           oldDelegate.unlockedCount != unlockedCount;
  }
}
