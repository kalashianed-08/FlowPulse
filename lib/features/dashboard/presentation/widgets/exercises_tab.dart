import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/glass_container.dart';
import '../../../../core/providers/stats_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

/// Модель физического упражнения.
class _Exercise {
  final String name;
  final String instruction;
  final IconData icon;
  final String animationType;
  final int durationSeconds;

  const _Exercise({
    required this.name,
    required this.instruction,
    required this.icon,
    required this.animationType,
    required this.durationSeconds,
  });
}

/// Модель комплекса упражнений для определенной группы мышц.
class _ExerciseComplex {
  final String name;
  final String subtitle;
  final String description;
  final IconData icon;
  final String complexType; // 'spine', 'neck', 'legs', 'arms'
  final Color themeColor;
  final String muscleGroup;
  final List<_Exercise> exercises;

  const _ExerciseComplex({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.complexType,
    required this.themeColor,
    required this.muscleGroup,
    required this.exercises,
  });

  int get totalDurationSeconds =>
      exercises.fold(0, (sum, item) => sum + item.durationSeconds);
}

// ─────────────────────────────────────────────────────────────────────────────
// СПИСОК КОМПЛЕКСОВ УПРАЖНЕНИЙ
// ─────────────────────────────────────────────────────────────────────────────
const _complexes = [
  _ExerciseComplex(
    name: 'Back & Spine Flex',
    subtitle: 'Relieve spinal pressure & stiffness',
    description: 'A soothing sequence designed to extend your range of motion, align vertebrae, and release deep back tension from prolonged sitting.',
    icon: Icons.spa_rounded,
    complexType: 'spine',
    themeColor: Color(0xFF64D2FF), // Голубой
    muscleGroup: 'Spine & Back',
    exercises: [
      _Exercise(
        name: 'Cat-Cow Stretch',
        instruction: 'On all fours, arch your back up towards the ceiling like a cat, then drop your belly down and lift your chest like a cow. Move slowly with deep breaths.',
        icon: Icons.waves_rounded,
        animationType: 'flex',
        durationSeconds: 40,
      ),
      _Exercise(
        name: 'Spinal Twist',
        instruction: 'Sit tall, gently twist your upper body to the right, placing your hand on your knee. Hold, then slowly twist to the left side.',
        icon: Icons.sync_rounded,
        animationType: 'spine',
        durationSeconds: 30,
      ),
      _Exercise(
        name: 'Child\'s Pose Stretch',
        instruction: 'Kneel and sit on your heels, lean forward, stretching your arms flat out on the floor in front of you. Let your chest relax downwards.',
        icon: Icons.airline_seat_flat_rounded,
        animationType: 'fold',
        durationSeconds: 40,
      ),
      _Exercise(
        name: 'Cobra Arch',
        instruction: 'Lie flat on your stomach, place hands under shoulders, and gently press up to lift your chest off the floor. Keep shoulders relaxed down.',
        icon: Icons.trending_up_rounded,
        animationType: 'cobra',
        durationSeconds: 40,
      ),
    ],
  ),
  _ExerciseComplex(
    name: 'Head & Neck Release',
    subtitle: 'Combat desk neck & shoulder tension',
    description: 'Perfect for counteracting forward-head posture from laptops and phones. Stretches cervical joints and neck muscles.',
    icon: Icons.self_improvement_rounded,
    complexType: 'neck',
    themeColor: Color(0xFFFF9F0A), // Оранжевый
    muscleGroup: 'Neck & Head',
    exercises: [
      _Exercise(
        name: 'Neck Rolls',
        instruction: 'Gently roll your head in a slow, wide circle clockwise. Complete a few rotations, then switch direction. Keep motions smooth.',
        icon: Icons.cached_rounded,
        animationType: 'neck',
        durationSeconds: 30,
      ),
      _Exercise(
        name: 'Neck Side Tilts',
        instruction: 'Slowly tilt your right ear down towards your right shoulder until you feel a gentle stretch. Hold, then repeat on the left side.',
        icon: Icons.swap_horiz_rounded,
        animationType: 'tilt',
        durationSeconds: 30,
      ),
      _Exercise(
        name: 'Chin Tucks',
        instruction: 'Sit tall, pull your chin straight back as if making a double chin. Keep eyes looking forward. Do not tilt your head down.',
        icon: Icons.shield_rounded,
        animationType: 'tuck',
        durationSeconds: 30,
      ),
      _Exercise(
        name: 'Shoulder Shrugs',
        instruction: 'Raise your shoulders straight up towards your ears. Hold for a second, then let them fall down completely to release muscle tension.',
        icon: Icons.keyboard_double_arrow_up_rounded,
        animationType: 'shrug',
        durationSeconds: 30,
      ),
    ],
  ),
  _ExerciseComplex(
    name: 'Strong & Active Legs',
    subtitle: 'Energize lower body & boost blood flow',
    description: 'A quick active sequence to activate major muscle groups in your legs, open up hips, and stimulate lymphatic drainage in lower extremities.',
    icon: Icons.directions_run_rounded,
    complexType: 'legs',
    themeColor: Color(0xFFFF375F), // Розовый
    muscleGroup: 'Legs & Thighs',
    exercises: [
      _Exercise(
        name: 'Bodyweight Squats',
        instruction: 'Stand with feet shoulder-width apart. Lower your hips down and back as if sitting in a chair, keeping chest upright. Press through heels to stand.',
        icon: Icons.arrow_downward_rounded,
        animationType: 'squat',
        durationSeconds: 45,
      ),
      _Exercise(
        name: 'Calf Raises',
        instruction: 'Stand upright and slowly raise yourself onto the balls of your feet, squeezing your calves. Slowly lower your heels back to the ground.',
        icon: Icons.arrow_upward_rounded,
        animationType: 'calf',
        durationSeconds: 40,
      ),
      _Exercise(
        name: 'Quad Stretch',
        instruction: 'Stand on one leg, grab your opposite ankle behind you, and gently pull your heel towards your glutes. Hold, then switch legs.',
        icon: Icons.accessibility_new_rounded,
        animationType: 'quad',
        durationSeconds: 40,
      ),
      _Exercise(
        name: 'Glute Bridges',
        instruction: 'Lie on your back, knees bent, feet flat. Press through your heels to lift your hips toward the ceiling, forming a bridge. Squeeze glutes at top.',
        icon: Icons.wb_sunny_rounded,
        animationType: 'bridge',
        durationSeconds: 45,
      ),
    ],
  ),
  _ExerciseComplex(
    name: 'Office Desk Relief',
    subtitle: 'Decompress joints during work hours',
    description: 'Quick micro-movements tailored to relieve typical desk strain in your wrists, forearms, chest, and shoulders without leaving your chair.',
    icon: Icons.desktop_mac_rounded,
    complexType: 'arms',
    themeColor: Color(0xFF30D158), // Зеленый
    muscleGroup: 'Arms & Wrists',
    exercises: [
      _Exercise(
        name: 'Wrist Circles',
        instruction: 'Clench your fists loosely and rotate your wrists clockwise in smooth circles, then counter-clockwise. Great for combating mouse stiffness.',
        icon: Icons.all_inclusive_rounded,
        animationType: 'wrist',
        durationSeconds: 30,
      ),
      _Exercise(
        name: 'Chest Openers',
        instruction: 'Interlace your fingers behind your lower back, roll shoulders back, and gently lift your hands up to expand your lungs and open the chest.',
        icon: Icons.open_in_full_rounded,
        animationType: 'chest',
        durationSeconds: 40,
      ),
      _Exercise(
        name: 'Fist Clenches',
        instruction: 'Squeeze both hands into tight fists, hold for a brief second, then stretch all ten fingers out as wide as possible. Repeat dynamically.',
        icon: Icons.center_focus_strong_rounded,
        animationType: 'clench',
        durationSeconds: 30,
      ),
    ],
  ),
];

/// Состояния тренировочного процесса
enum _WorkoutState {
  idle,
  previewComplex,
  activeWorkout,
  restInterval,
  completed,
}

/// Экран упражнений для тела — вкладка "Exercises".
class ExercisesTab extends ConsumerStatefulWidget {
  const ExercisesTab({super.key});

  @override
  ConsumerState<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends ConsumerState<ExercisesTab>
    with TickerProviderStateMixin {
  // Выбор вкладки: 0 = Комплексы, 1 = Одиночные упражнения
  int _activeCategoryTab = 0;

  _WorkoutState _workoutState = _WorkoutState.idle;

  // Данные активной тренировки
  _ExerciseComplex? _selectedComplex;
  _Exercise? _singleExercise;
  int _currentExerciseIndex = 0;
  bool _isPaused = false;

  // Переменные таймеров
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _remainingRestSeconds = 0;
  Timer? _countdownTimer;

  // Одиночный выбор длительности (в минутах)
  int _selectedSingleDurationIndex = 1;
  final _singleDurations = [1, 2, 3, 5];

  // Инициализация одиночных упражнений (извлеченных из комплексов)
  final List<_Exercise> _allSingleExercises = [];

  @override
  void initState() {
    super.initState();
    // Собираем уникальный список одиночных упражнений
    final Set<String> addedNames = {};
    for (final complex in _complexes) {
      for (final ex in complex.exercises) {
        if (!addedNames.contains(ex.name)) {
          addedNames.add(ex.name);
          _allSingleExercises.add(ex);
        }
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Запуск одиночного упражнения
  void _startSingleExercise(_Exercise exercise) {
    final minutes = _singleDurations[_selectedSingleDurationIndex];
    final totalSec = minutes * 60;

    _countdownTimer?.cancel();
    setState(() {
      _selectedComplex = null;
      _singleExercise = exercise;
      _currentExerciseIndex = 0;
      _workoutState = _WorkoutState.activeWorkout;
      _remainingSeconds = totalSec;
      _totalSeconds = totalSec;
      _isPaused = false;
    });

    _startCountdown(isComplex: false);
  }

  // Предпросмотр комплекса
  void _previewComplex(_ExerciseComplex complex) {
    setState(() {
      _selectedComplex = complex;
      _workoutState = _WorkoutState.previewComplex;
    });
  }

  // Запуск комплекса
  void _startComplex() {
    if (_selectedComplex == null) return;

    _countdownTimer?.cancel();
    final firstEx = _selectedComplex!.exercises[0];

    setState(() {
      _singleExercise = null;
      _currentExerciseIndex = 0;
      _workoutState = _WorkoutState.activeWorkout;
      _remainingSeconds = firstEx.durationSeconds;
      _totalSeconds = firstEx.durationSeconds;
      _isPaused = false;
    });

    _startCountdown(isComplex: true);
  }

  // Запуск отсчета таймера
  void _startCountdown({required bool isComplex}) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;

      if (_workoutState == _WorkoutState.activeWorkout) {
        if (_remainingSeconds > 1) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _onExerciseComplete(isComplex: isComplex);
        }
      } else if (_workoutState == _WorkoutState.restInterval) {
        if (_remainingRestSeconds > 1) {
          setState(() {
            _remainingRestSeconds--;
          });
        } else {
          _startNextExercise();
        }
      }
    });
  }

  // Обработка завершения отдельного упражнения в комплексе или одиночного
  void _onExerciseComplete({required bool isComplex}) {
    _countdownTimer?.cancel();

    if (!isComplex) {
      _onWorkoutFinished(activeMinutes: _singleDurations[_selectedSingleDurationIndex]);
    } else {
      final complex = _selectedComplex!;
      if (_currentExerciseIndex < complex.exercises.length - 1) {
        setState(() {
          _workoutState = _WorkoutState.restInterval;
          _remainingRestSeconds = 10;
        });
        _startCountdown(isComplex: true);
      } else {
        final totalMinutes = (complex.totalDurationSeconds / 60.0).ceil();
        _onWorkoutFinished(activeMinutes: totalMinutes);
      }
    }
  }

  // Переход к следующему упражнению в комплексе
  void _startNextExercise() {
    _currentExerciseIndex++;
    final nextEx = _selectedComplex!.exercises[_currentExerciseIndex];

    setState(() {
      _workoutState = _WorkoutState.activeWorkout;
      _remainingSeconds = nextEx.durationSeconds;
      _totalSeconds = nextEx.durationSeconds;
    });

    _startCountdown(isComplex: true);
  }

  // Полное завершение тренировки
  void _onWorkoutFinished({required int activeMinutes}) {
    final name = _singleExercise != null
        ? _singleExercise!.name
        : '${_selectedComplex!.name} Complex';

    ref.read(statsProvider.notifier).completeExerciseSession(activeMinutes, name);

    setState(() {
      _workoutState = _WorkoutState.completed;
    });
  }

  // Пропуск текущего отдыха
  void _skipRest() {
    if (_workoutState != _WorkoutState.restInterval) return;
    _countdownTimer?.cancel();
    _startNextExercise();
  }

  // Пропуск текущего упражнения
  void _skipExercise(bool isComplex) {
    if (_workoutState != _WorkoutState.activeWorkout) return;
    _countdownTimer?.cancel();
    _onExerciseComplete(isComplex: isComplex);
  }

  // Пауза / Старт
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  // Отмена тренировки
  void _cancelWorkout() {
    _countdownTimer?.cancel();
    setState(() {
      _workoutState = _WorkoutState.idle;
      _selectedComplex = null;
      _singleExercise = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    switch (_workoutState) {
      case _WorkoutState.idle:
        return _buildHomePicker(stats);
      case _WorkoutState.previewComplex:
        return _buildComplexPreview();
      case _WorkoutState.activeWorkout:
        return _buildActiveWorkoutScreen();
      case _WorkoutState.restInterval:
        return _buildRestScreen();
      case _WorkoutState.completed:
        return _buildCompletedScreen();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ЭКРАН 1: ГЛАВНЫЙ ВЫБОР (КОМПЛЕКСЫ ИЛИ ОДИНОЧНЫЕ)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHomePicker(DashboardStats stats) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            _buildHeader(),
            const Gap(24),
            _buildStatsRow(stats),
            const Gap(28),

            // Сегментированный переключатель iOS-Style
            _buildCategorySegmentedControl(),
            const Gap(24),

            // Отображение контента в зависимости от вкладки
            _activeCategoryTab == 0
                ? _buildComplexesList()
                : _buildSingleExercisesGrid(),

            const Gap(110),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WARM-UP & STRETCH',
          style: TextStyle(
            color: const Color(0xFF30D158).withValues(alpha: 0.75),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Gap(4),
        const Text(
          'Muscle Complexes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.8,
          ),
        ),
        const Gap(4),
        Text(
          'Targeted sequences with visual guides to release stiffness',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildStatsRow(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            '${stats.exercisesCompletedToday}',
            'Completed',
            Icons.check_circle_outline_rounded,
            const Color(0xFF30D158),
          ),
        ),
        const Gap(10),
        Expanded(
          child: _buildMiniStat(
            '${stats.totalExerciseMinutes}m',
            'Duration',
            Icons.timer_rounded,
            const Color(0xFF64D2FF),
          ),
        ),
        const Gap(10),
        Expanded(
          child: _buildMiniStat(
            stats.lastExerciseName.isEmpty ? 'None' : stats.lastExerciseName,
            'Last Done',
            Icons.fitness_center_rounded,
            const Color(0xFFBF88FF),
            isTextValue: true,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildMiniStat(
    String value,
    String label,
    IconData icon,
    Color color, {
    bool isTextValue = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      borderRadius: 18,
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const Gap(8),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isTextValue ? 12 : 16,
              fontWeight: FontWeight.bold,
              letterSpacing: isTextValue ? -0.2 : 0,
            ),
          ),
          const Gap(3),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeCategoryTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _activeCategoryTab == 0
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Workouts (${_complexes.length})',
                    style: TextStyle(
                      color: _activeCategoryTab == 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeCategoryTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _activeCategoryTab == 1
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Single Stretches',
                    style: TextStyle(
                      color: _activeCategoryTab == 1
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Построение кастомной неоновой иконки для списка комплексов
  Widget _buildComplexBadge(String type, Color themeColor) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            themeColor.withValues(alpha: 0.16),
            themeColor.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(
            painter: _ComplexMiniIconPainter(
              type: type,
              color: themeColor,
            ),
          ),
        ),
      ),
    );
  }

  // Вкладка A: Комплексы (без emojis)
  Widget _buildComplexesList() {
    return Column(
      children: List.generate(_complexes.length, (index) {
        final complex = _complexes[index];
        final durMin = (complex.totalDurationSeconds / 60.0).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () => _previewComplex(complex),
            child: GlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 24,
              child: Row(
                children: [
                  _buildComplexBadge(complex.complexType, complex.themeColor),
                  const Gap(16),

                  // Тексты
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complex.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          complex.subtitle,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                        const Gap(8),

                        // Теги
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.fitness_center_rounded,
                                      color: complex.themeColor, size: 10),
                                  const Gap(4),
                                  Text(
                                    '${complex.exercises.length} moves',
                                    style: TextStyle(
                                      color: complex.themeColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_rounded,
                                      color: Colors.white60, size: 10),
                                  const Gap(4),
                                  Text(
                                    '$durMin min',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 350.ms, delay: (80 * index).ms)
            .slideX(begin: 0.03, end: 0, curve: Curves.easeOutCubic);
      }),
    );
  }

  // Вкладка B: Сетка одиночных растяжек (без emojis)
  Widget _buildSingleExercisesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'SELECT SINGLE EXERCISE DURATION',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_singleDurations.length, (i) {
            final isSelected = _selectedSingleDurationIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedSingleDurationIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected
                      ? const Color(0xFF30D158).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF30D158)
                        : AppColors.glassBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  '${_singleDurations[i]} min',
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF30D158)
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
        const Gap(24),

        // Сетка
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _allSingleExercises.length,
          itemBuilder: (context, index) {
            final ex = _allSingleExercises[index];
            const itemColor = Color(0xFF30D158);

            return GestureDetector(
              onTap: () => _startSingleExercise(ex),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: 22,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: itemColor.withValues(alpha: 0.08),
                        border: Border.all(
                          color: itemColor.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          ex.icon,
                          color: itemColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Text(
                      ex.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Stretch',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ЭКРАН 2: ПРЕДПРОСМОТР КОМПЛЕКСА (ЭКРАН СТАРТА)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildComplexPreview() {
    final complex = _selectedComplex!;
    final durMin = (complex.totalDurationSeconds / 60.0).toStringAsFixed(1);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            GestureDetector(
              onTap: _cancelWorkout,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary, size: 16),
                ),
              ),
            ),
            const Gap(24),

            // Заголовок без emojis
            Row(
              children: [
                _buildComplexBadge(complex.complexType, complex.themeColor),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: complex.themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          complex.muscleGroup.toUpperCase(),
                          style: TextStyle(
                            color: complex.themeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Gap(6),
                      Text(
                        complex.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Text(
              complex.description,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const Gap(24),

            GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPreviewSummaryNode(
                      '${complex.exercises.length}', 'Exercises', Icons.checklist_rtl_rounded),
                  _buildPreviewSummaryNode(
                      '$durMin min', 'Active Time', Icons.hourglass_top_rounded),
                  _buildPreviewSummaryNode(
                      '10s', 'Rest Breaks', Icons.airline_seat_recline_extra_rounded),
                ],
              ),
            ),
            const Gap(28),

            Text(
              'WORKOUT SCHEDULE',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const Gap(14),

            ...List.generate(complex.exercises.length, (idx) {
              final ex = complex.exercises[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: complex.themeColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: complex.themeColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            ex.icon,
                            color: complex.themeColor,
                            size: 16,
                          ),
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              ex.instruction,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Text(
                        '${ex.durationSeconds}s',
                        style: TextStyle(
                          color: complex.themeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Gap(36),

            Center(
              child: GestureDetector(
                onTap: _startComplex,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        complex.themeColor,
                        complex.themeColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: complex.themeColor.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded,
                            color: Colors.white, size: 22),
                        Gap(8),
                        Text(
                          'Begin Workout Complex',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.02, 1.02),
                    duration: 1500.ms,
                  ),
            ),

            const Gap(60),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildPreviewSummaryNode(String val, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 15),
        const Gap(6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ЭКРАН 3: АКТИВНОЕ УПРАЖНЕНИЕ С ТАЙМЕРОМ И HIGH-FIDELITY CANVASES
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildActiveWorkoutScreen() {
    final isComplex = _selectedComplex != null;
    final themeColor = isComplex
        ? _selectedComplex!.themeColor
        : const Color(0xFF30D158);

    final currentEx = isComplex
        ? _selectedComplex!.exercises[_currentExerciseIndex]
        : _singleExercise!;

    final currentStepString = isComplex
        ? 'STEP ${_currentExerciseIndex + 1} OF ${_selectedComplex!.exercises.length}'
        : 'SINGLE QUICK STRETCH';

    final exerciseProgress = _totalSeconds > 0
        ? 1.0 - (_remainingSeconds / _totalSeconds)
        : 0.0;

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _cancelWorkout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.close_rounded, color: Colors.white60, size: 14),
                          Gap(4),
                          Text(
                            'Quit',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    currentStepString,
                    style: TextStyle(
                      color: themeColor.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Opacity(
                    opacity: 0,
                    child: SizedBox(width: 50),
                  ),
                ],
              ),
              const Gap(30),

              // ВЕЛИКОЛЕПНЫЙ АНИМИРОВАННЫЙ ВИЗУАЛИЗАТОР С ЖИВЫМ ГОЛОГРАФИЧЕСКИМ ЧЕЛОВЕКОМ (3D WIREFRAME MANNEQUIN)
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x22131A26),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.12),
                      blurRadius: 50,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: _isPaused
                      ? Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeColor.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            currentEx.icon,
                            color: themeColor,
                            size: 32,
                          ),
                        )
                      : ExerciseAnimationVisualizer(
                          animationType: currentEx.animationType,
                          themeColor: themeColor,
                        ),
                ),
              ),
              const Gap(32),

              Text(
                currentEx.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(20),

              // Таймер с круговым прогрессом
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _CircularWorkoutProgressPainter(
                          progress: exerciseProgress,
                          color: themeColor,
                          backgroundColor: themeColor.withValues(alpha: 0.08),
                          strokeWidth: 5,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'remaining',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.35),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  currentEx.instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
              const Gap(32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _togglePause,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Center(
                        child: Icon(
                          _isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),

                  GestureDetector(
                    onTap: () => _skipExercise(isComplex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Text(
                            isComplex ? 'Skip Move' : 'Finish',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(6),
                          const Icon(Icons.fast_forward_rounded,
                              color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ЭКРАН 4: ИНТЕРВАЛ ОТДЫХА (REST PHASE)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRestScreen() {
    final complex = _selectedComplex!;
    final themeColor = complex.themeColor;
    final nextEx = complex.exercises[_currentExerciseIndex + 1];

    return SafeArea(
      bottom: false,
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'REST & PREPARE',
                style: TextStyle(
                  color: const Color(0xFF30D158).withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Gap(16),

              Text(
                '${_remainingRestSeconds}s',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 64,
                  fontWeight: FontWeight.w100,
                ),
              ),
              const Gap(32),

              // Карточка превью следующего упражнения (без emojis)
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'UP NEXT',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(16),

                    // Неоновый бадж иконки вместо emoji
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          nextEx.icon,
                          color: themeColor,
                          size: 26,
                        ),
                      ),
                    ),
                    const Gap(14),

                    Text(
                      nextEx.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      nextEx.instruction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(40),

              GestureDetector(
                onTap: _skipRest,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Text(
                    'Skip Rest & Start',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ЭКРАН 5: ЗАВЕРШЕНИЕ И ПОЗДРАВЛЕНИЕ
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCompletedScreen() {
    final isComplex = _selectedComplex != null;
    final themeColor = isComplex
        ? _selectedComplex!.themeColor
        : const Color(0xFF30D158);

    final name = isComplex
        ? _selectedComplex!.name
        : _singleExercise!.name;

    final minutes = isComplex
        ? (_selectedComplex!.totalDurationSeconds / 60.0).ceil()
        : _singleDurations[_selectedSingleDurationIndex];

    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.stars_rounded,
                    color: themeColor,
                    size: 48,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.bounceOut)
                  .then()
                  .shake(duration: 400.ms),

              const Gap(28),
              const Text(
                'Workout Complete!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(8),
              Text(
                'Excellent work focusing on your physical wellness.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const Gap(32),

              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 22,
                child: Column(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    const Divider(color: Colors.white10, height: 1),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultStatNode('+$minutes min', 'Active Time'),
                        _buildResultStatNode('+15%', 'Tension relief'),
                        _buildResultStatNode('+1', 'Streak count'),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(40),

              GestureDetector(
                onTap: _cancelWorkout,
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF131A26),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Done & Return',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildResultStatNode(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(3),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// МИНИ-ОТРИСОВЩИК ВЕКТОРНЫХ ИКОНОК ДЛЯ КАРТОЧЕК СПИСКА
// ─────────────────────────────────────────────────────────────────────────────
class _ComplexMiniIconPainter extends CustomPainter {
  final String type;
  final Color color;

  _ComplexMiniIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case 'spine': // Mini Spine Curve
        final path = Path()
          ..moveTo(cx - 8, cy - 8)
          ..quadraticBezierTo(cx - 1, cy - 8, cx - 4, cy - 1)
          ..quadraticBezierTo(cx - 7, cy + 6, cx, cy + 6)
          ..quadraticBezierTo(cx + 7, cy + 6, cx + 4, cy - 1)
          ..quadraticBezierTo(cx + 1, cy - 8, cx + 8, cy - 8);

        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, paint);

        canvas.drawCircle(Offset(cx - 8, cy - 8), 1.8, dotPaint);
        canvas.drawCircle(Offset(cx - 4, cy - 1), 1.8, dotPaint);
        canvas.drawCircle(Offset(cx, cy + 6), 1.8, dotPaint);
        canvas.drawCircle(Offset(cx + 4, cy - 1), 1.8, dotPaint);
        canvas.drawCircle(Offset(cx + 8, cy - 8), 1.8, dotPaint);
        break;

      case 'neck': // Mini Neck Circles
        canvas.drawLine(Offset(cx - 10, cy + 8), Offset(cx + 10, cy + 8), paint);
        final rect = Rect.fromCircle(center: Offset(cx, cy - 1), radius: 6);
        canvas.drawArc(rect, -pi / 6, 4 * pi / 3, false, paint);
        canvas.drawCircle(Offset(cx - 2, cy - 6), 3.2, dotPaint);
        break;

      case 'legs': // Mini Knee joint pivot
        final foot = Offset(cx + 8, cy + 7);
        final knee = Offset(cx - 6, cy + 3);
        final hip = Offset(cx + 2, cy - 7);

        canvas.drawLine(foot, knee, paint);
        canvas.drawLine(knee, hip, paint);

        canvas.drawCircle(foot, 2.2, dotPaint);
        canvas.drawCircle(knee, 2.8, dotPaint);
        canvas.drawCircle(hip, 2.5, dotPaint);
        break;

      case 'arms': // Mini Wrist loop orbit
        final center = Offset(cx, cy);
        canvas.drawCircle(center, 7, paint);
        final rect = Rect.fromCircle(center: center, radius: 10);
        canvas.drawArc(rect, pi / 4, 3 * pi / 2, false, paint);
        canvas.drawCircle(Offset(cx + 7, cy), 1.8, dotPaint);
        canvas.drawCircle(Offset(cx - 5, cy - 5), 1.8, dotPaint);
        break;

      default:
        canvas.drawCircle(Offset(cx, cy), 8, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ComplexMiniIconPainter old) =>
      old.type != type || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// АНИМИРОВАННЫЙ ВИЗУАЛИЗАТОР ВНУТРИ ТАЙМЕРА ТРЕНИРОВКИ
// ─────────────────────────────────────────────────────────────────────────────
class ExerciseAnimationVisualizer extends StatefulWidget {
  final String animationType;
  final Color themeColor;

  const ExerciseAnimationVisualizer({
    super.key,
    required this.animationType,
    required this.themeColor,
  });

  @override
  State<ExerciseAnimationVisualizer> createState() =>
      _ExerciseAnimationVisualizerState();
}

class _ExerciseAnimationVisualizerState
    extends State<ExerciseAnimationVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getLottieUrl(String animType) {
    switch (animType) {
      // Back & Spine Flex
      case 'flex': // Cat-Cow Stretch
        return 'https://assets5.lottiefiles.com/packages/lf20_9w9ofp1a.json'; // Calming yoga stretch
      case 'spine': // Spinal Twist
        return 'https://assets5.lottiefiles.com/packages/lf20_rjm0y242.json'; // Yoga meditation twist
      case 'fold': // Child\'s Pose Stretch
        return 'https://assets5.lottiefiles.com/packages/lf20_sf9uxph2.json'; // Rest posture/pose
      case 'cobra': // Cobra Arch
        return 'https://assets5.lottiefiles.com/packages/lf20_9w9ofp1a.json'; // Stretching curve

      // Head & Neck Release
      case 'neck': // Neck Rolls
        return 'https://assets3.lottiefiles.com/packages/lf20_sf9uxph2.json'; // Slow relaxing neck/head pose
      case 'tilt': // Neck Side Tilts
        return 'https://assets3.lottiefiles.com/packages/lf20_sf9uxph2.json';
      case 'tuck': // Chin Tucks
        return 'https://assets3.lottiefiles.com/packages/lf20_sf9uxph2.json';
      case 'shrug': // Shoulder Shrugs
        return 'https://assets5.lottiefiles.com/packages/lf20_mhl77k33.json'; // Shoulder/arms warming

      // Strong & Active Legs
      case 'squat': // Bodyweight Squats
        return 'https://assets5.lottiefiles.com/packages/lf20_obh5cwy6.json'; // High-quality gym squatting trainer
      case 'calf': // Calf Raises
        return 'https://assets5.lottiefiles.com/packages/lf20_obh5cwy6.json';
      case 'quad': // Quad Stretch
        return 'https://assets5.lottiefiles.com/packages/lf20_9w9ofp1a.json';
      case 'bridge': // Glute Bridges
        return 'https://assets5.lottiefiles.com/packages/lf20_9w9ofp1a.json';

      // Office Desk Relief
      case 'wrist': // Wrist Circles
        return 'https://assets5.lottiefiles.com/packages/lf20_mhl77k33.json'; // Wrist/hand mobility trainer
      case 'chest': // Chest Openers
        return 'https://assets5.lottiefiles.com/packages/lf20_mhl77k33.json';
      case 'clench': // Fist Clenches
        return 'https://assets5.lottiefiles.com/packages/lf20_mhl77k33.json';

      default:
        return 'https://assets5.lottiefiles.com/packages/lf20_sf9uxph2.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lottieUrl = _getLottieUrl(widget.animationType);

    return ClipOval(
      child: Lottie.network(
        lottieUrl,
        fit: BoxFit.contain,
        width: 170,
        height: 170,
        repeat: true,
        animate: true,
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.themeColor),
                ),
              ),
            );
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) {
          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(220, 220),
                painter: _ExercisePainter(
                  type: widget.animationType,
                  color: widget.themeColor,
                  value: _animController.value,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ПРЕМИАЛЬНЫЙ ГОЛОГРАФИЧЕСКИЙ ЖИВОЙ ЧЕЛОВЕК (3D WIREFRAME MANNEQUIN) НА CANVAS
// ─────────────────────────────────────────────────────────────────────────────
class _ExercisePainter extends CustomPainter {
  final String type;
  final Color color;
  final double value;

  _ExercisePainter({
    required this.type,
    required this.color,
    required this.value,
  });

  // Modern organic colors for athletic character
  static const Color skinColor = Color(0xFFFFD5B4);     // Vibrant warm skin tone
  static const Color shortsColor = Color(0xFF1E293B);   // Sleek dark gym shorts
  static const Color hairColor = Color(0xFF2E221D);     // Stylized dark brown hair

  // Draws a volumetric, beautiful organic tapered limb
  void _drawDetailedLimb(
    Canvas canvas,
    Offset p1,
    Offset p2, {
    required double startWidth,
    required double endWidth,
    required Color color,
    Color? clothingColor,
    double clothingRatio = 0.0,
  }) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;
    final nx = -uy;
    final ny = ux;

    if (clothingRatio > 0 && clothingColor != null) {
      final midPoint = p1 + Offset(ux * len * clothingRatio, uy * len * clothingRatio);
      final midWidth = startWidth + (endWidth - startWidth) * clothingRatio;

      _drawFleshPath(canvas, p1, midPoint, startWidth, midWidth, nx, ny, clothingColor);
      _drawFleshPath(canvas, midPoint, p2, midWidth, endWidth, nx, ny, color);
    } else {
      _drawFleshPath(canvas, p1, p2, startWidth, endWidth, nx, ny, color);
    }

    // Add subtle structural highlight
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(p1, p2, linePaint);
  }

  void _drawFleshPath(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double w1,
    double w2,
    double nx,
    double ny,
    Color col,
  ) {
    final p1L = p1 + Offset(nx * w1 / 2, ny * w1 / 2);
    final p1R = p1 - Offset(nx * w1 / 2, ny * w1 / 2);
    final p2L = p2 + Offset(nx * w2 / 2, ny * w2 / 2);
    final p2R = p2 - Offset(nx * w2 / 2, ny * w2 / 2);

    final path = Path()
      ..moveTo(p1L.dx, p1L.dy)
      ..lineTo(p2L.dx, p2L.dy)
      ..arcToPoint(p2R, radius: Radius.circular(w2 / 2), clockwise: false)
      ..lineTo(p1R.dx, p1R.dy)
      ..arcToPoint(p1L, radius: Radius.circular(w1 / 2), clockwise: false)
      ..close();

    // Drop-shadow for character depth
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Solid fill
    canvas.drawPath(path, Paint()..color = col..style = PaintingStyle.fill);

    // Inner highlight
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // Draws a beautiful detailed sporty sneaker
  void _drawSneaker(Canvas canvas, Offset ankle, Offset foot, Color col) {
    final dx = foot.dx - ankle.dx;
    final dy = foot.dy - ankle.dy;
    final len = sqrt(dx * dx + dy * dy);
    final ux = len > 0 ? dx / len : 1.0;
    final uy = len > 0 ? dy / len : 0.0;

    final shoePaint = Paint()
      ..color = const Color(0xFFF8FAFC) // Sleek white sneaker
      ..style = PaintingStyle.fill;

    final solePaint = Paint()
      ..color = col
      ..style = PaintingStyle.fill;

    canvas.drawCircle(foot, 7.5, shoePaint);
    canvas.drawCircle(foot + Offset(ux * 4, uy * 2), 6.5, shoePaint);

    // Sole
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: foot + Offset(0, 5), width: 16, height: 3.5),
        const Radius.circular(1),
      ),
      solePaint,
    );
  }

  // Draws an athletic head with trendy hair and glowing fitness headband
  void _drawDetailedHead(Canvas canvas, Offset pos, Color col, {double angle = 0.0}) {
    // Face skin
    canvas.drawCircle(pos, 12.0, Paint()..color = skinColor..style = PaintingStyle.fill);

    // Dark hair silhouette
    final hairPaint = Paint()..color = hairColor..style = PaintingStyle.fill;
    final hairPath = Path()
      ..addArc(Rect.fromCircle(center: pos, radius: 12.0), pi + angle - 0.4, pi + 0.8)
      ..quadraticBezierTo(
        pos.dx + sin(angle) * 8,
        pos.dy - cos(angle) * 8,
        pos.dx + cos(angle + pi / 2) * 12,
        pos.dy + sin(angle + pi / 2) * 12,
      )
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Neon headband matching the complex's theme color
    final bandPaint = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8;

    canvas.drawArc(
      Rect.fromCircle(center: pos, radius: 12.5),
      pi + angle + 0.3,
      pi - 0.6,
      false,
      bandPaint,
    );
  }

  // Draws a beautiful sporty chest, torso, and gym clothing segments
  void _drawDetailedTorso(Canvas canvas, Offset pelvis, Offset chest, Color col) {
    final dx = chest.dx - pelvis.dx;
    final dy = chest.dy - pelvis.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final ux = dx / len;
    final uy = dy / len;
    final nx = -uy;
    final ny = ux;

    final mid = pelvis + Offset(ux * len * 0.35, uy * len * 0.35); // Shorts vs Shirt division

    final pW = 22.0; // Pelvis width
    final cW = 26.0; // Chest width
    final mW = 23.5; // Waist width

    final pL = pelvis + Offset(nx * pW / 2, ny * pW / 2);
    final pR = pelvis - Offset(nx * pW / 2, ny * pW / 2);
    final mL = mid + Offset(nx * mW / 2, ny * mW / 2);
    final mR = mid - Offset(nx * mW / 2, ny * mW / 2);
    final cL = chest + Offset(nx * cW / 2, ny * cW / 2);
    final cR = chest - Offset(nx * cW / 2, ny * cW / 2);

    // Shorts
    final shortsPath = Path()
      ..moveTo(pL.dx, pL.dy)
      ..lineTo(mL.dx, mL.dy)
      ..lineTo(mR.dx, mR.dy)
      ..lineTo(pR.dx, pR.dy)
      ..close();
    canvas.drawPath(shortsPath, Paint()..color = shortsColor..style = PaintingStyle.fill);

    // T-shirt
    final shirtPath = Path()
      ..moveTo(mL.dx, mL.dy)
      ..lineTo(cL.dx, cL.dy)
      ..lineTo(cR.dx, cR.dy)
      ..lineTo(mR.dx, mR.dy)
      ..close();
    canvas.drawPath(shirtPath, Paint()..color = col..style = PaintingStyle.fill);

    // Outlines for crisp vector styling
    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(shortsPath, outlinePaint);
    canvas.drawPath(shirtPath, outlinePaint);
  }

  // Draw joints as elegant accent rings instead of plain dot nodes
  void _drawJointNode(Canvas canvas, Offset pos, double size, Color col) {
    canvas.drawCircle(
      pos,
      size + 3,
      Paint()
        ..color = col.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      pos,
      size,
      Paint()
        ..color = col.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      pos,
      max(1.2, size * 0.4),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Biometric holographic background grids
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotGridPaint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.85, gridPaint);
    canvas.drawCircle(center, radius * 0.55, gridPaint);
    canvas.drawLine(center - Offset(radius * 0.9, 0), center + Offset(radius * 0.9, 0), gridPaint);
    canvas.drawLine(center - Offset(0, radius * 0.9), center + Offset(0, radius * 0.9), gridPaint);

    for (int angle = 0; angle < 360; angle += 45) {
      final rad = angle * pi / 180;
      canvas.drawCircle(center + Offset(cos(rad) * radius * 0.85, sin(rad) * radius * 0.85), 1.5, dotGridPaint);
    }

    final double phase = value * 2 * pi;
    final double cycle = (sin(phase) + 1.0) / 2.0;

    final glowDotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final paintSolid = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintGlowMid = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final paintGlowWide = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    // 2. Physical solid human trainer complex actions
    switch (type) {
      case 'flex': // Cat-Cow Stretch
        final groundY = center.dy + 40;
        final foot = center + const Offset(55, 40);
        final knee = center + const Offset(35, 40);
        final pelvis = center + Offset(35, 12 + (cycle * 8));

        final hand = center + const Offset(-45, 40);
        final shoulder = center + const Offset(-45, -10);

        final chest = center + Offset(-5, -5 + (cycle * 16));
        final neck = center + Offset(-35, -16 + (cycle * 12));
        final head = center + Offset(-50, -22 + (cycle * 10) - (1.0 - cycle) * 10);

        // Ground Floor Line
        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        // Diaphragm/Breathing energy
        final stomachY = (pelvis.dy + chest.dy) / 2 + 10;
        canvas.drawCircle(Offset(center.dx - 5, stomachY), 12 + (1.0 - cycle) * 12, glowDotPaint);

        // Volumetric character segments
        _drawDetailedLimb(canvas, foot, knee, startWidth: 8.5, endWidth: 10.0, color: skinColor);
        _drawDetailedLimb(canvas, knee, pelvis, startWidth: 10.0, endWidth: 14.0, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.4);
        _drawDetailedTorso(canvas, pelvis, chest, color);
        _drawDetailedLimb(canvas, shoulder, hand, startWidth: 9.5, endWidth: 7.5, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, chest, neck, startWidth: 10.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, knee, 5.5, color);
        _drawJointNode(canvas, pelvis, 7.0, color);
        _drawJointNode(canvas, chest, 6.5, color);
        _drawJointNode(canvas, shoulder, 6.0, color);
        _drawJointNode(canvas, neck, 5.0, color);

        _drawDetailedHead(canvas, head, color);

        // Spine energy trail
        final t = (value * 1.5) % 1.0;
        final ex = pelvis.dx + t * (head.dx - pelvis.dx);
        final ey = pelvis.dy + sin(t * pi) * (chest.dy - pelvis.dy - 10) + t * (head.dy - pelvis.dy);
        canvas.drawCircle(Offset(ex, ey), 6, glowDotPaint);
        canvas.drawCircle(Offset(ex, ey), 3, Paint()..color = Colors.white);
        break;

      case 'squat': // Bodyweight Squats
        final groundY = center.dy + 55;
        final foot = center + const Offset(-15, 55);
        final ankle = center + const Offset(0, 55);
        
        final knee = center + Offset(-25 * cycle, 16 + (cycle * 22));
        final pelvis = center + Offset(-35 * cycle, -18 + (cycle * 48));
        
        final neck = pelvis + Offset(6, -42);
        final head = neck + Offset(3, -12);

        final shoulder = pelvis + Offset(-10, -32);
        final elbow = shoulder + Offset(-15 - (cycle * 15), -5 + (cycle * 5));
        final hand = elbow + const Offset(-18, 0);

        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        // Athletic limbs & sneakers
        _drawDetailedLimb(canvas, foot, ankle, startWidth: 10.0, endWidth: 10.0, color: skinColor);
        _drawDetailedLimb(canvas, ankle, knee, startWidth: 9.0, endWidth: 11.0, color: skinColor);
        _drawDetailedLimb(canvas, knee, pelvis, startWidth: 11.0, endWidth: 15.0, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.5);
        _drawDetailedTorso(canvas, pelvis, neck, color);
        _drawDetailedLimb(canvas, shoulder, elbow, startWidth: 9.0, endWidth: 8.0, color: skinColor, clothingColor: color, clothingRatio: 0.35);
        _drawDetailedLimb(canvas, elbow, hand, startWidth: 8.0, endWidth: 7.0, color: skinColor);

        _drawJointNode(canvas, ankle, 5.5, color);
        _drawJointNode(canvas, knee, 7.0, color);
        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, shoulder, 6.5, color);
        _drawJointNode(canvas, elbow, 5.5, color);
        _drawJointNode(canvas, hand, 4.5, color);

        _drawSneaker(canvas, ankle, foot, color);
        _drawDetailedHead(canvas, head, color);
        break;

      case 'neck': // Sitting Neck Rolls
        final pelvis = center + const Offset(0, 45);
        final chest = center + const Offset(0, 5);
        final neck = center + const Offset(0, -18);
        
        final shoulderL = center + const Offset(-35, -12);
        final shoulderR = center + const Offset(35, -12);

        final headX = neck.dx + cos(phase) * 16;
        final headY = neck.dy - 16 + sin(phase) * 8;
        final head = Offset(headX, headY);

        _drawDetailedTorso(canvas, pelvis, chest, color);
        _drawDetailedLimb(canvas, chest, neck, startWidth: 10.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, chest, shoulderL, startWidth: 11.0, endWidth: 9.0, color: skinColor, clothingColor: color, clothingRatio: 0.4);
        _drawDetailedLimb(canvas, chest, shoulderR, startWidth: 11.0, endWidth: 9.0, color: skinColor, clothingColor: color, clothingRatio: 0.4);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, chest, 7.5, color);
        _drawJointNode(canvas, neck, 5.5, color);
        _drawJointNode(canvas, shoulderL, 6.0, color);
        _drawJointNode(canvas, shoulderR, 6.0, color);

        _drawDetailedHead(canvas, head, color, angle: phase);
        break;

      case 'tilt': // Neck Side Tilts
        final pelvis = center + const Offset(0, 45);
        final chest = center + const Offset(0, 5);
        final neck = center + const Offset(0, -18);
        
        final shoulderL = center + const Offset(-35, -12);
        final shoulderR = center + const Offset(35, -12);

        final tiltAngle = sin(phase) * (pi / 7.5);
        final head = neck + Offset(-sin(tiltAngle) * 20, -cos(tiltAngle) * 20);

        _drawDetailedTorso(canvas, pelvis, chest, color);
        _drawDetailedLimb(canvas, chest, neck, startWidth: 10.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, chest, shoulderL, startWidth: 11.0, endWidth: 9.0, color: skinColor, clothingColor: color, clothingRatio: 0.4);
        _drawDetailedLimb(canvas, chest, shoulderR, startWidth: 11.0, endWidth: 9.0, color: skinColor, clothingColor: color, clothingRatio: 0.4);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, chest, 7.5, color);
        _drawJointNode(canvas, neck, 5.5, color);
        _drawJointNode(canvas, shoulderL, 6.0, color);
        _drawJointNode(canvas, shoulderR, 6.0, color);

        _drawDetailedHead(canvas, head, color, angle: tiltAngle);
        break;

      case 'tuck': // Chin Tucks
        final pelvis = center + const Offset(20, 45);
        final chest = center + const Offset(20, 5);
        final neck = center + const Offset(15, -18);
        
        final head = center + Offset(15 - (cycle * 15), -38);

        canvas.drawLine(Offset(pelvis.dx, center.dy + 50), Offset(pelvis.dx, center.dy - 60), gridPaint);

        _drawDetailedTorso(canvas, pelvis, chest, color);
        _drawDetailedLimb(canvas, chest, neck, startWidth: 10.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, chest, 7.5, color);
        _drawJointNode(canvas, neck, 5.5, color);

        _drawDetailedHead(canvas, head, color);
        break;

      case 'spine': // Spinal Twist
        final pelvis = center + const Offset(0, 45);
        final chest = center + const Offset(0, 5);
        final neck = center + const Offset(0, -18);

        final twist = sin(phase) * (pi / 5);
        final shoulderL = center + Offset(-cos(twist) * 35, -12 + sin(twist) * 8);
        final shoulderR = center + Offset(cos(twist) * 35, -12 - sin(twist) * 8);
        
        final head = neck + Offset(-sin(twist) * 8, -18);

        _drawDetailedTorso(canvas, pelvis, chest, color);
        _drawDetailedLimb(canvas, chest, neck, startWidth: 10.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, chest, shoulderL, startWidth: 11.0, endWidth: 9.0, color: skinColor, clothingColor: color, clothingRatio: 0.4);
        _drawDetailedLimb(canvas, chest, shoulderR, startWidth: 11.0, endWidth: 9.0, color: skinColor, clothingColor: color, clothingRatio: 0.4);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, chest, 7.5, color);
        _drawJointNode(canvas, neck, 5.5, color);
        _drawJointNode(canvas, shoulderL, 6.0, color);
        _drawJointNode(canvas, shoulderR, 6.0, color);

        _drawDetailedHead(canvas, head, color, angle: twist);
        break;

      case 'fold': // Child's Pose Stretch
        final groundY = center.dy + 45;
        
        final foot = center + const Offset(55, 42);
        final knee = center + const Offset(25, 42);
        final pelvis = center + Offset(40 - (cycle * 8), 35 - (cycle * 5));

        final chest = center + Offset(10 - (cycle * 30), 25 - (cycle * 18));
        final head = center + Offset(-15 - (cycle * 35), 26 - (cycle * 22));
        final hand = center + Offset(-35 - (cycle * 40), 40 - (cycle * 2));

        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        _drawDetailedLimb(canvas, foot, knee, startWidth: 8.0, endWidth: 9.5, color: skinColor);
        _drawDetailedLimb(canvas, knee, pelvis, startWidth: 9.5, endWidth: 13.0, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.6);
        _drawDetailedTorso(canvas, pelvis, chest, color);
        _drawDetailedLimb(canvas, chest, head, startWidth: 8.5, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, chest, hand, startWidth: 8.0, endWidth: 6.5, color: skinColor, clothingColor: color, clothingRatio: 0.3);

        _drawJointNode(canvas, knee, 5.5, color);
        _drawJointNode(canvas, pelvis, 7.0, color);
        _drawJointNode(canvas, chest, 6.5, color);
        _drawJointNode(canvas, hand, 4.0, color);

        _drawDetailedHead(canvas, head, color);
        break;

      case 'cobra': // Cobra Arch
        final groundY = center.dy + 45;
        final foot = center + const Offset(65, 42);
        final hip = center + const Offset(25, 42);
        
        final chest = center + Offset(-10, 22 - (cycle * 22));
        final head = center + Offset(-25 - (cycle * 12), -2 - (cycle * 26));

        final hand = center + const Offset(-30, 42);
        final elbow = center + Offset(-24, 28 - (cycle * 8));

        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        _drawDetailedLimb(canvas, foot, hip, startWidth: 9.5, endWidth: 12.0, color: skinColor);
        _drawDetailedTorso(canvas, hip, chest, color);
        _drawDetailedLimb(canvas, chest, head, startWidth: 9.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, chest, elbow, startWidth: 9.5, endWidth: 8.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, elbow, hand, startWidth: 8.0, endWidth: 7.0, color: skinColor);

        _drawJointNode(canvas, hip, 7.0, color);
        _drawJointNode(canvas, chest, 7.0, color);
        _drawJointNode(canvas, elbow, 5.5, color);
        _drawJointNode(canvas, hand, 4.5, color);

        _drawDetailedHead(canvas, head, color);
        break;

      case 'calf': // Calf Raises
        final groundY = center.dy + 55;
        final toes = center + const Offset(15, 55);
        
        final heel = center + Offset(-25, 53 - (cycle * 24));
        final ankle = center + Offset(0, 50 - (cycle * 20));
        
        final knee = center + Offset(5, 12 - (cycle * 20));
        final pelvis = center + Offset(0, -18 - (cycle * 20));
        
        final head = pelvis + const Offset(0, -42);

        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        _drawDetailedLimb(canvas, toes, heel, startWidth: 9.5, endWidth: 9.5, color: skinColor);
        _drawDetailedLimb(canvas, heel, ankle, startWidth: 9.5, endWidth: 10.0, color: skinColor);
        _drawDetailedLimb(canvas, ankle, knee, startWidth: 10.0, endWidth: 11.5, color: skinColor);
        _drawDetailedLimb(canvas, knee, pelvis, startWidth: 11.5, endWidth: 14.5, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.5);
        _drawDetailedTorso(canvas, pelvis, head + const Offset(0, 42), color);

        _drawJointNode(canvas, ankle, 5.5, color);
        _drawJointNode(canvas, knee, 7.0, color);
        _drawJointNode(canvas, pelvis, 8.0, color);

        _drawSneaker(canvas, ankle, toes, color);
        _drawDetailedHead(canvas, head, color);
        break;

      case 'quad': // Quad Stretch
        final groundY = center.dy + 55;
        
        final standFoot = center + const Offset(-15, 55);
        final standHip = center + const Offset(-10, -15);
        
        final stretchKnee = center + const Offset(10, 18);
        final stretchAnkle = center + Offset(26 + (cycle * 12), -2 - (cycle * 18));

        final neck = standHip + const Offset(0, -42);
        final head = neck + const Offset(0, -12);

        final shoulder = standHip + const Offset(-5, -30);
        
        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        _drawDetailedLimb(canvas, standFoot, standHip, startWidth: 10.5, endWidth: 13.5, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.4);
        _drawDetailedTorso(canvas, standHip, neck, color);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.5, endWidth: 8.0, color: skinColor);
        
        _drawDetailedLimb(canvas, standHip, stretchKnee, startWidth: 13.5, endWidth: 11.5, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.5);
        _drawDetailedLimb(canvas, stretchKnee, stretchAnkle, startWidth: 11.5, endWidth: 8.5, color: skinColor);
        _drawDetailedLimb(canvas, shoulder, stretchAnkle, startWidth: 9.0, endWidth: 7.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);

        _drawJointNode(canvas, standHip, 7.5, color);
        _drawJointNode(canvas, stretchKnee, 7.0, color);
        _drawJointNode(canvas, stretchAnkle, 5.5, color);
        _drawJointNode(canvas, shoulder, 6.5, color);

        _drawSneaker(canvas, standFoot, standFoot + const Offset(6, 0), color);
        _drawDetailedHead(canvas, head, color);
        break;

      case 'bridge': // Glute Bridge
        final groundY = center.dy + 45;
        
        final shoulder = center + const Offset(-55, 38);
        final foot = center + const Offset(45, 38);
        
        final knee = center + const Offset(25, 5);
        final pelvis = center + Offset(-10 + (cycle * 22), 34 - (cycle * 55));
        
        final head = shoulder + const Offset(-15, 0);

        canvas.drawLine(Offset(center.dx - 80, groundY), Offset(center.dx + 80, groundY), paintSolid);

        _drawDetailedTorso(canvas, shoulder, pelvis, color);
        _drawDetailedLimb(canvas, pelvis, knee, startWidth: 14.5, endWidth: 11.5, color: skinColor, clothingColor: shortsColor, clothingRatio: 0.5);
        _drawDetailedLimb(canvas, knee, foot, startWidth: 11.5, endWidth: 9.0, color: skinColor);
        _drawDetailedLimb(canvas, shoulder, head, startWidth: 9.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, shoulder, 7.5, color);
        _drawJointNode(canvas, pelvis, 8.5, color);
        _drawJointNode(canvas, knee, 7.0, color);
        _drawJointNode(canvas, foot, 6.0, color);

        _drawSneaker(canvas, foot, foot + const Offset(5, 0), color);
        _drawDetailedHead(canvas, head, color);
        break;

      case 'wrist': // Wrist Circles
        final pelvis = center + const Offset(0, 45);
        final neck = center + const Offset(0, -22);
        final head = neck + const Offset(0, -14);
        
        final shoulder = center + const Offset(0, -12);
        final hand = center + const Offset(-45, -12);
        final handFist = hand + Offset(cos(phase) * 12, sin(phase) * 12);

        _drawDetailedTorso(canvas, pelvis, neck, color);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, shoulder, hand, startWidth: 10.5, endWidth: 8.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, hand, handFist, startWidth: 8.0, endWidth: 6.5, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, shoulder, 7.0, color);
        _drawJointNode(canvas, hand, 5.5, color);
        _drawJointNode(canvas, handFist, 4.5, color);

        _drawDetailedHead(canvas, head, color);
        break;

      case 'chest': // Chest Openers
        final pelvis = center + const Offset(0, 45);
        final neck = center + const Offset(0, -22);
        final head = neck + const Offset(0, -14);

        final shoulderL = center + const Offset(-18, -12);
        final shoulderR = center + const Offset(18, -12);

        final handL = center + Offset(-18 - 30 - (cycle * 22), -12 + (1.0 - cycle) * 8);
        final handR = center + Offset(18 + 30 + (cycle * 22), -12 + (1.0 - cycle) * 8);

        _drawDetailedTorso(canvas, pelvis, neck, color);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, neck, shoulderL, startWidth: 11.0, endWidth: 10.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, neck, shoulderR, startWidth: 11.0, endWidth: 10.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, shoulderL, handL, startWidth: 10.0, endWidth: 7.5, color: skinColor);
        _drawDetailedLimb(canvas, shoulderR, handR, startWidth: 10.0, endWidth: 7.5, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, neck, 6.5, color);
        _drawJointNode(canvas, shoulderL, 6.5, color);
        _drawJointNode(canvas, shoulderR, 6.5, color);
        _drawJointNode(canvas, handL, 5.0, color);
        _drawJointNode(canvas, handR, 5.0, color);

        _drawDetailedHead(canvas, head, color);
        break;

      case 'shrug': // Shoulder Shrugs
        final pelvis = center + const Offset(0, 45);
        final neck = center + const Offset(0, -22);
        final head = neck + const Offset(0, -14);

        final shoulderL = center + Offset(-35, -12 - (cycle * 16));
        final shoulderR = center + Offset(35, -12 - (cycle * 16));

        final handL = center + Offset(-35, 18);
        final handR = center + Offset(35, 18);

        _drawDetailedTorso(canvas, pelvis, neck, color);
        _drawDetailedLimb(canvas, neck, head, startWidth: 8.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, neck, shoulderL, startWidth: 11.0, endWidth: 10.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, neck, shoulderR, startWidth: 11.0, endWidth: 10.0, color: skinColor, clothingColor: color, clothingRatio: 0.3);
        _drawDetailedLimb(canvas, shoulderL, handL, startWidth: 10.0, endWidth: 8.0, color: skinColor);
        _drawDetailedLimb(canvas, shoulderR, handR, startWidth: 10.0, endWidth: 8.0, color: skinColor);

        _drawJointNode(canvas, pelvis, 8.0, color);
        _drawJointNode(canvas, neck, 6.5, color);
        _drawJointNode(canvas, shoulderL, 6.5, color);
        _drawJointNode(canvas, shoulderR, 6.5, color);
        _drawJointNode(canvas, handL, 5.0, color);
        _drawJointNode(canvas, handR, 5.0, color);

        _drawDetailedHead(canvas, head, color);
        break;

      case 'clench': // Fist Clenches
        final wrist = center + const Offset(0, 25);
        final palm = center + const Offset(0, -5);

        _drawDetailedLimb(canvas, wrist, palm, startWidth: 16.0, endWidth: 20.0, color: skinColor);
        _drawJointNode(canvas, wrist, 8.0, color);
        _drawJointNode(canvas, palm, 9.0, color);

        const fingersCount = 5;
        for (int i = 0; i < fingersCount; i++) {
          final double angle = -pi / 6 - (i * (2 * pi / 3) / (fingersCount - 1));
          final double fLength = 16.0 + (1.0 - cycle) * 16.0;

          final joint = palm + Offset(cos(angle) * fLength * 0.5, sin(angle) * fLength * 0.5);
          final tip = palm + Offset(cos(angle) * fLength, sin(angle) * fLength);

          _drawDetailedLimb(canvas, palm, joint, startWidth: 7.0, endWidth: 5.5, color: skinColor);
          _drawDetailedLimb(canvas, joint, tip, startWidth: 5.5, endWidth: 4.5, color: skinColor);

          canvas.drawCircle(joint, 2.8, dotPaint);
          canvas.drawCircle(tip, 2.8, dotPaint);
          canvas.drawCircle(tip, 1.2, Paint()..color = Colors.white);
        }
        break;

      default:
        final sizeMult = 18.0 + (sin(value * 2 * pi) + 1.0) * 14.0;
        canvas.drawCircle(center, sizeMult, paintGlowWide);
        canvas.drawCircle(center, sizeMult, paintGlowMid);
        canvas.drawCircle(center, sizeMult, Paint()..color = color..style = PaintingStyle.fill);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ExercisePainter old) {
    return old.value != value || old.type != type || old.color != color;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// КРУГОВОЙ ПРОГРЕСС ДЛЯ АКТИВНОГО ТАЙМЕРА ТРЕНИРОВКИ
// ─────────────────────────────────────────────────────────────────────────────
class _CircularWorkoutProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularWorkoutProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularWorkoutProgressPainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.backgroundColor != backgroundColor;
  }
}
