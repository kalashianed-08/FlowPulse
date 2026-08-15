import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: Логгер напряжения шеи "Neck Tension Log".
///
/// Предоставляет столбчатый неоновый график уровня стресса и
/// интерактивную панель для фиксации текущих ощущений боли по шкале 1-10.
class TensionLogWidget extends ConsumerStatefulWidget {
  const TensionLogWidget({super.key});

  @override
  ConsumerState<TensionLogWidget> createState() => _TensionLogWidgetState();
}

class _TensionLogWidgetState extends ConsumerState<TensionLogWidget> {
  int _selectedRating = 4;
  String _selectedZone = 'Neck';

  void _saveLog() {
    ref.read(statsProvider.notifier).logTension(_selectedRating);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📊 Neck Tension logged: Level $_selectedRating for $_selectedZone',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF5E62),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFFF5E62); // Apple Coral / Rose

    final stats = ref.watch(statsProvider);
    final tensionData = stats.weeklyTensionLevels;

    return AppleWidgetCard(
      title: 'Log',
      subtitle: 'Neck Tension',
      icon: Icons.favorite_border_rounded,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Столбчатый график
          Expanded(
            child: Row(
              children: [
                // Шкала Y
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => Text(
                      '${10 - index * 2}',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                
                // Сами столбцы графика
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _TensionBarPainter(
                          accentColor: accentColor,
                          tensionData: tensionData,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          
          // Подписи оси X под графиком
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _AxisLabel('Mon'),
                _AxisLabel('Tue'),
                _AxisLabel('Wed'),
                _AxisLabel('Thu'),
                _AxisLabel('Fri'),
                _AxisLabel('Sat'),
                _AxisLabel('Sun'),
              ],
            ),
          ),
          const Gap(10),
          
          // Интерактивные кнопки логирования
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate Tension (1-10):',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const Gap(6),
              
              Row(
                children: [
                  // Кнопка выбора зоны
                  Expanded(
                    child: _buildSelectorButton(
                      text: _selectedZone,
                      onTap: () {
                        setState(() {
                          _selectedZone = _selectedZone == 'Neck' ? 'Back' : 'Neck';
                        });
                      },
                    ),
                  ),
                  const Gap(8),
                  
                  // Кнопка выбора уровня
                  Expanded(
                    child: _buildSelectorButton(
                      text: 'Lvl $_selectedRating',
                      onTap: () {
                        setState(() {
                          _selectedRating = (_selectedRating % 10) + 1;
                        });
                      },
                    ),
                  ),
                  const Gap(8),

                  // Кнопка сохранения лога
                  GestureDetector(
                    onTap: _saveLog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;
  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.4),
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Рисует премиальные градиентные столбцы-пилюли с неоновым свечением
class _TensionBarPainter extends CustomPainter {
  final Color accentColor;
  final List<double> tensionData;

  _TensionBarPainter({required this.accentColor, required this.tensionData});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final barCount = tensionData.length;
    
    // Расстояние между центрами колонок
    final colStep = width / (barCount - 1);
    
    // Ширина столбца
    const barWidth = 8.0;

    for (var i = 0; i < barCount; i++) {
      final val = tensionData[i].clamp(0.0, 10.0);
      if (val == 0.0) {
        // Отрисуем только пустой полупрозрачный паз, если лог за день еще не внесен
        final x = i * colStep - (barWidth / 2);
        final trackRect = Rect.fromLTWH(x, 0, barWidth, height);
        final trackRRect = RRect.fromRectAndRadius(trackRect, const Radius.circular(10.0));
        canvas.drawRRect(
          trackRRect,
          Paint()..color = Colors.white.withValues(alpha: 0.02),
        );
        continue;
      }
      
      // Вычисляем высоту столбца
      final barHeight = (val / 10.0) * height;
      
      // Координаты верхнего левого угла прямоугольника столбца
      final x = i * colStep - (barWidth / 2);
      final y = height - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10.0));

      // 1. Отрисовка фонового паза под столбцом
      final trackRect = Rect.fromLTWH(x, 0, barWidth, height);
      final trackRRect = RRect.fromRectAndRadius(trackRect, const Radius.circular(10.0));
      canvas.drawRRect(
        trackRRect,
        Paint()..color = Colors.white.withValues(alpha: 0.03),
      );

      // 2. Свечение под столбцом
      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(rrect, glowPaint);

      // 3. Сам градиентный столбец
      final barPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            accentColor,
            const Color(0xFF00F2FE), // Переходит в неоновый циан сверху
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TensionBarPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || oldDelegate.tensionData != tensionData;
  }
}
