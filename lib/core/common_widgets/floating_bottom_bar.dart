import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';

/// Высокотехнологичная плавающая стеклянная нижняя панель навигации (Floating Glass Bottom Bar).
///
/// Визуально подвешена над контентом с размытием BackdropFilter, скруглениями
/// и светящимися точками-индикаторами под выбранной вкладкой.
class FloatingGlassBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const FloatingGlassBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00F2FE); // Apple Neon Cyan

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 26),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xE60D1520), // Глубокое стекло Apple Dark UI
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: Icons.grid_view_rounded,
                    label: 'Dashboard',
                    activeColor: activeColor,
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.fitness_center_rounded,
                    label: 'Exercises',
                    activeColor: const Color(0xFF30D158),
                  ),
                  _buildTabItem(
                    index: 2,
                    icon: Icons.self_improvement_rounded,
                    label: 'Breathe',
                    activeColor: const Color(0xFFBF88FF),
                  ),
                  _buildTabItem(
                    index: 3,
                    icon: Icons.person_rounded,
                    label: 'Account',
                    activeColor: const Color(0xFFBF88FF),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50,
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, isActive ? -2.0 : 0, 0),
              child: Icon(
                icon,
                color: isActive ? activeColor : AppColors.textSecondary.withValues(alpha: 0.4),
                size: isActive ? 24 : 21,
              ),
            ),
            
            if (isActive) ...[
              const Gap(3),
              // Маленькая светящаяся неоновая точка
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
            ] else ...[
              const Gap(7), // Компенсация высоты точки для сохранения вертикального центра
            ],
          ],
        ),
      ),
    );
  }
}
