import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/apple_widget_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/stats_provider.dart';

/// Виджет: Система удержания "Streak Mode" (Серия дней).
///
/// Отображает огненный индикатор текущей серии дней и интерактивные чекпоинты Пн-Вс.
class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const accentColor = Color(0xFFFF9966); // Теплый оранжевый / Коралловый огонь
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final stats = ref.watch(statsProvider);
    final completedDays = stats.completedDays;
    final streakCount = stats.streakCount;
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);

    return AppleWidgetCard(
      title: 'Active Streak',
      subtitle: 'Retention Tracker',
      icon: Icons.local_fire_department_rounded,
      emojiAssetPath: 'assets/images/apple_3d_flame.png',
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Блок с пламенем и общим показателем
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Анимированное глянцевое 3D-пламя
                  Image.asset(
                    'assets/images/apple_3d_flame.png',
                    width: 32,
                    height: 32,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .slideY(begin: 0.0, end: -0.12, duration: 1500.ms, curve: Curves.easeInOut)
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.12, 1.12), duration: 1500.ms, curve: Curves.easeInOut)
                      .shimmer(duration: 3000.ms, color: Colors.white24),
                  const Gap(8),
                  
                  // Текст серии
                  Text(
                    '$streakCount Days Streak',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              
              // Бейдж достижений
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder, width: 0.8),
                ),
                child: Text(
                  streakCount >= 5 ? 'TOP 3%' : 'DESK PRO',
                  style: const TextStyle(
                    color: Color(0xFF00F2FE),
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),

          // Горизонтальный календарь с отметками
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) => _buildDayCheckpoint(
                dayName: weekdays[index],
                index: index,
                isCompleted: completedDays[index],
                isToday: index == todayIndex,
                onTap: () {
                  ref.read(statsProvider.notifier).toggleStreakDay(index);
                },
              ),
            ),
          ),
          const Gap(10),

          // Текст мотивации
          Text(
            streakCount == 0
                ? "Breathe or focus today to light your wellness streak flame!"
                : "You are active and keeping up! Don't let your flame go out tonight.",
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              fontSize: 9,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCheckpoint({
    required String dayName,
    required int index,
    required bool isCompleted,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    final activeColor = isToday ? const Color(0xFF00F2FE) : const Color(0xFFFF5E62);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Символ дня недели
          Text(
            dayName,
            style: TextStyle(
              color: isToday ? const Color(0xFF00F2FE) : AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          
          // Круглый стеклянный чекпоинт
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFFFF5E62) : Colors.white.withValues(alpha: 0.03),
              border: Border.all(
                color: isToday
                    ? activeColor
                    : isCompleted
                        ? const Color(0xFFFF5E62)
                        : Colors.white.withValues(alpha: 0.08),
                width: isToday ? 1.5 : 1.0,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF5E62).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: -1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 11,
                    )
                  : isToday
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00F2FE),
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
