import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/common_widgets/floating_bottom_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/consistency_widget.dart';
import '../widgets/focus_map_widget.dart';
import '../widgets/focus_session_widget.dart';
import '../widgets/healthy_breaks_widget.dart';
import '../widgets/micro_stretch_widget.dart';
import '../widgets/tension_log_widget.dart';
import '../widgets/streak_widget.dart';
import '../widgets/profile_tab.dart';
import '../widgets/exercises_tab.dart';
import '../widgets/breathing_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';


/// Пересобранный главный экран (Dashboard) FlowPulse с просторной iOS-версткой.
///
/// Виджеты теперь не сжаты, а отображаются как просторные, полноразмерные карточки
/// с точной высотой. Настроен плавающий стеклянный Bottom Bar с 4-й вкладкой "Account".
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Контент скроллится под стеклянный Floating Bottom Bar
      body: Stack(
        children: [
          // 1. Задний фоновый динамический градиент (Ambient Glow)
          const Positioned.fill(
            child: _AmbientGlowBackground(),
          ),

          // 2. Основной контент в зависимости от выбранного таба
          Positioned.fill(
            child: _buildBody(),
          ),

          // 3. Плавающий стеклянный Floating Bottom Bar с 4-й кнопкой Account
          FloatingGlassBottomBar(
            selectedIndex: _currentTabIndex,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const ExercisesTab();
      case 2:
        return const BreathingTab();
      case 3:
        return const ProfileTab();
      default:
        return _buildDashboardTab();
    }
  }


  Widget _buildDashboardTab() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            // Хедер
            _buildHeader(),
            const Gap(28),

            // Просторный вертикальный список карточек (Spacious Apple UI)
            // Каждая карточка обернута в SizedBox с фиксированной высотой для
            // исключения конфликтов Expanded элементов внутри SingleChildScrollView.
            Column(
              children: [
                // 0. Streak Activity Card (Новый стрейк-виджет удержания)
                const SizedBox(
                  height: 200,
                  child: StreakWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 50.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                const Gap(20),

                // 1. Focus Session Card (Полноразмерный герой-таймер)
                const SizedBox(
                  height: 200,
                  child: FocusSessionWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 50.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                const Gap(20),
                
                // 2. Consistency Card (Просторный светящийся график волны Безье)
                const SizedBox(
                  height: 220,
                  child: ConsistencyWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 150.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                const Gap(20),
                
                // 3. Tension Log Card (Просторный столбчатый неоновый логгер)
                const SizedBox(
                  height: 230,
                  child: TensionLogWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 250.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                const Gap(20),
                
                // 4. Micro-Stretch Card (Круговой таймер растяжки)
                const SizedBox(
                  height: 210,
                  child: MicroStretchWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 350.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                const Gap(20),
                
                // 5. Healthy Breaks Card (Шкала баланса активности)
                const SizedBox(
                  height: 210,
                  child: HealthyBreaksWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 450.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                const Gap(20),
                
                // 6. Focus Map Card (Координатный таймлайн дня)
                const SizedBox(
                  height: 210,
                  child: FocusMapWidget(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 550.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
            
            // Буферный отступ внизу под плавающий Bottom Bar
            const Gap(110),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final userName = user?.displayName ?? (user?.isAnonymous == true ? 'Guest Creator' : 'Creator');

    final now = DateTime.now();
    final weekdays = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    final months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    final dateString = '${weekdays[(now.weekday - 1).clamp(0, 6)]}, ${months[(now.month - 1).clamp(0, 11)]} ${now.day}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateString,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const Gap(3),
            Text(
              'Hello, $userName',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        
        // Стеклянная интерактивная кнопка выхода (Sign Out)
        GestureDetector(
          onTap: () {
            if (Firebase.apps.isEmpty) return;
            ref.read(authServiceProvider).signOut();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder, width: 1.2),
              color: Colors.white.withValues(alpha: 0.04),
            ),
            child: const Center(
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

}


class _AmbientGlowBackground extends StatelessWidget {
  const _AmbientGlowBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(),
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Верхняя левая неоновая сфера (Cyan)
    final paint1 = Paint()
      ..color = const Color(0xFF00F2FE).withValues(alpha: 0.13)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    // 2. Средняя правая неоновая сфера (Purple)
    final paint2 = Paint()
      ..color = const Color(0xFFBF88FF).withValues(alpha: 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // 3. Нижняя левая неоновая сфера (Coral/Pink)
    final paint3 = Paint()
      ..color = const Color(0xFFFF5E62).withValues(alpha: 0.09)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95);

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.22), 170, paint1);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.50), 220, paint2);
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.78), 180, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
