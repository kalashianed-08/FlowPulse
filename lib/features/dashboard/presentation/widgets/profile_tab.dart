import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/glass_container.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/stats_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Виджет: Раздел аккаунта и профиля "Profile & Settings" (4-я вкладка).
///
/// Полностью спроектирован в стиле Apple HIG и Glass UI:
/// - Стеклянный интерактивный аватар с рамкой
/// - Селекторы целей фокусировки
/// - Динамические переключатели уведомлений и синхронизации
/// - Кнопка выхода со светоотражающим кантом.
class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _notificationsEnabled = true;
  bool _googleFitEnabled = false;
  int _targetGoalMinutes = 90;

  void _showGoalPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFB0D1520),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0x33FFFFFF), width: 1.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              const Text(
                'Daily Focus Goal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              const Text(
                'Adjust your target work sprint time for posture breaks.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [60, 90, 120, 150].map((mins) {
                  final isSelected = _targetGoalMinutes == mins;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _targetGoalMinutes = mins;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF00F2FE).withValues(alpha: 0.15) 
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF00F2FE) 
                              : AppColors.glassBorder, 
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$mins min',
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF00F2FE) : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFBF88FF); // Apple Lavender
    final authState = ref.watch(authStateProvider);
    final stats = ref.watch(statsProvider);
    final user = authState.value;

    final name = user?.displayName ?? (user?.isAnonymous == true ? 'Guest Creator' : 'Creator');
    final email = user?.email ?? (user?.isAnonymous == true ? 'Demo guest access' : 'No email linked');
    final photoUrl = user?.photoURL;
    final isGoogle = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            const Gap(16),
            
            // 1. Стеклянный хедер профиля (Profile Card)
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              borderRadius: 28,
              child: Column(
                children: [
                  // Стеклянная рамка аватара с неоновой подсветкой
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x33131A26),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(name),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: accentColor,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                            )
                          : _buildInitialAvatar(name),
                    ),
                  ),
                  const Gap(16),
                  
                  // Имя
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Gap(4),
                  
                  // Email
                  Text(
                    email,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(14),
                  
                  // Бейдж провайдера авторизации
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isGoogle 
                          ? const Color(0xFF4285F4).withValues(alpha: 0.1) 
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isGoogle 
                            ? const Color(0xFF4285F4).withValues(alpha: 0.3) 
                            : AppColors.glassBorder, 
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGoogle ? Icons.g_mobiledata_rounded : Icons.person_rounded,
                          color: isGoogle ? const Color(0xFF4285F4) : const Color(0xFF00F2FE),
                          size: isGoogle ? 18 : 12,
                        ),
                        const Gap(6),
                        Text(
                          isGoogle ? 'Google Account' : 'Demo Drive Guest',
                          style: TextStyle(
                            color: isGoogle ? const Color(0xFF4285F4) : const Color(0xFF00F2FE),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // 2. Сводная статистика из statsProvider (Stats Summary)
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard(
                    title: 'Active Streak',
                    value: '${stats.streakCount} Days',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF9966),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _buildMiniStatCard(
                    title: 'Focus Today',
                    value: '${stats.focusMinutesToday} Min',
                    icon: Icons.psychology_outlined,
                    color: const Color(0xFF00F2FE),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _buildMiniStatCard(
                    title: 'Stretches',
                    value: '${stats.stretchSessionsToday} Done',
                    icon: Icons.accessibility_new_rounded,
                    color: const Color(0xFF30D158),
                  ),
                ),
              ],
            ),
            const Gap(20),

            // 3. Раздел настроек (Settings Group)
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: 24,
              child: Column(
                children: [
                  _buildSettingsRow(
                    title: 'Postures Reminders',
                    subtitle: 'Haptic neck stretch alerts',
                    icon: Icons.notifications_active_rounded,
                    color: accentColor,
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      activeThumbColor: const Color(0xFF00F2FE),
                      activeTrackColor: const Color(0xFF00F2FE),
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    title: 'Google Fit Sync',
                    subtitle: 'Export posture break logs',
                    icon: Icons.fitbit_rounded,
                    color: const Color(0xFFFF5E62),
                    trailing: Switch.adaptive(
                      value: _googleFitEnabled,
                      activeThumbColor: const Color(0xFF00F2FE),
                      activeTrackColor: const Color(0xFF00F2FE),
                      onChanged: (val) {
                        setState(() {
                          _googleFitEnabled = val;
                        });
                      },
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    title: 'Daily Focus Target',
                    subtitle: 'Current goal: $_targetGoalMinutes mins',
                    icon: Icons.track_changes_rounded,
                    color: const Color(0xFF30D158),
                    onTap: _showGoalPicker,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // 4. Кнопка выхода из системы (Sign Out Button)
            GestureDetector(
              onTap: () {
                if (Firebase.apps.isEmpty) return;
                ref.read(authServiceProvider).signOut();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131A26),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF5E62).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFFF5E62),
                      size: 16,
                    ),
                    Gap(10),
                    Text(
                      'Log Out Account',
                      style: TextStyle(
                        color: Color(0xFFFF5E62),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(120), // Буфер под Bottom Bar
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF007AFF),
            Color(0xFFBF88FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: 18,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const Gap(10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    required Widget trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 18),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      indent: 52,
    );
  }
}
