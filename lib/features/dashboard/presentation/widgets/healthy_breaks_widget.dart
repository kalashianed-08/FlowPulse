import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: "Healthy Breaks" (Дневной баланс активности).
///
/// Отображает суммарное время разминок, количество перерывов,
/// соотношение рабочего времени и активных пауз со светящимся градиентным слайдером.
class HealthyBreaksWidget extends ConsumerWidget {
  const HealthyBreaksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const accentColor = Color(0xFF00F2FE); // Apple Neon Cyan

    final stats = ref.watch(statsProvider);
    final workHours = stats.workHours;
    final breakHours = stats.breakHours;
    final breaksCount = stats.breaksCount;

    // Вычисляем суммарное время расслабления в минутах
    final totalReliefMinutes = (breakHours * 60).round();

    return AppleWidgetCard(
      title: 'Healthy Breaks',
      subtitle: 'Day Summary',
      icon: Icons.directions_walk_rounded,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Основная статистика
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL RELIEF TIME',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(2),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        '$totalReliefMinutes',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(3),
                      Text(
                        'MINS',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Бейдж количества перерывов
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Text(
                  'BREAKS: $breaksCount',
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          
          Text(
            'STRETCH & FOCUS BALANCE',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(8),
          
          // Двухколоночные данные о времени
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeStat('WORK', '${workHours.toStringAsFixed(1)} HR'),
              _buildTimeStat('ACTIVE BREAKS', '${breakHours.toStringAsFixed(1)} HR'),
            ],
          ),
          const Gap(8),
          
          // Светящаяся шкала баланса (прогресс-бар)
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Позволяем пользователю плавно регулировать баланс свайпом
              final delta = details.primaryDelta! / 100.0;
              ref.read(statsProvider.notifier).adjustBalance(delta);
            },
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Задняя подложка шкалы
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.glassBorder, width: 0.6),
                      ),
                    ),
                    
                    // Активное заполнение с градиентом
                    FractionallySizedBox(
                      widthFactor: (workHours + breakHours == 0.0)
                          ? 0.05
                          : (breakHours / (workHours + breakHours)).clamp(0.05, 0.95),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF007AFF), // Синий
                              Color(0xFF00F2FE), // Неоновый циан
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(1),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
