import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/time_provider.dart';
import '../theme/app_colors.dart';

/// Премиальный виджет-карточка в стиле Apple iOS Glass UI (Frosted Glass Complication).
///
/// Реализует физические свойства матового стекла:
/// - BackdropFilter с глубоким размытием (30px)
/// - Тонкую светоотражающую белую рамку (физический торец стекла)
/// - Полупрозрачный темно-серый стеклянный оттенок
/// - Автоматическую синхронизацию времени.
class AppleWidgetCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? emojiAssetPath;
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const AppleWidgetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.emojiAssetPath,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Синхронизация локального времени
    final timeAsync = ref.watch(timeProvider);
    final timeStr = timeAsync.value ?? '--:--';
    
    final coreAccent = accentColor ?? const Color(0xFF00F2FE);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Рассеянное свечение под стеклом
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: coreAccent.withValues(alpha: 0.04),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0), // Плотный frosted-эффект
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Аутентичный полупрозрачный темно-серый стеклянный оттенок (iOS Ultra-Thin Material)
              color: const Color(0x22131A26),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                // Белая светоотражающая рамка (имитирует торец стекла)
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Верхний хедер виджета (Header Complication)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Круглая неоновая иконка
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: coreAccent.withValues(alpha: 0.12),
                              border: Border.all(
                                color: coreAccent.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: emojiAssetPath != null
                                  ? Image.asset(
                                      emojiAssetPath!,
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                    )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 2000.ms, curve: Curves.easeInOut)
                                      .shimmer(duration: 3000.ms, color: Colors.white24)
                                  : Icon(
                                      icon,
                                      color: coreAccent,
                                      size: 15,
                                    ),
                            ),
                          ),
                          const Gap(10),
                          // Двухстрочный заголовок категории
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subtitle.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const Gap(1),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    // Часы правого верхнего угла (Apple local time indicator)
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                // Рабочее пространство виджета
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
