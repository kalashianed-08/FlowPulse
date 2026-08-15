import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/common_widgets/glass_container.dart';
import '../../../../core/providers/stats_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Модель режима дыхания.
class _BreathingMode {
  final String name;
  final String subtitle;
  final String emoji;
  final Color color;

  /// Длительности фаз в секундах: [вдох, задержка, выдох, пауза].
  final List<int> phases;
  final List<String> phaseLabels;

  const _BreathingMode({
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.phases,
    required this.phaseLabels,
  });

  int get cycleDuration => phases.reduce((a, b) => a + b);
}

const _breathingModes = [
  _BreathingMode(
    name: 'Box Breathing',
    subtitle: 'Classic focus & clarity',
    emoji: '🌊',
    color: Color(0xFF64D2FF),
    phases: [4, 4, 4, 4],
    phaseLabels: ['Inhale', 'Hold', 'Exhale', 'Rest'],
  ),
  _BreathingMode(
    name: '4-7-8 Relax',
    subtitle: 'Deep relaxation before sleep',
    emoji: '🌙',
    color: Color(0xFFBF88FF),
    phases: [4, 7, 8, 2],
    phaseLabels: ['Inhale', 'Hold', 'Exhale', 'Rest'],
  ),
  _BreathingMode(
    name: 'Relaxation',
    subtitle: 'Unwind & restore balance',
    emoji: '🍃',
    color: Color(0xFF00C7BE), // Beautiful calm teal
    phases: [5, 2, 6, 2], // 5s Inhale, 2s Hold, 6s Exhale, 2s Rest
    phaseLabels: ['Inhale', 'Hold', 'Exhale', 'Rest'],
  ),
  _BreathingMode(
    name: 'Energize',
    subtitle: 'Quick energy boost',
    emoji: '🔥',
    color: Color(0xFFFF9F0A),
    phases: [3, 1, 3, 1],
    phaseLabels: ['Inhale', 'Hold', 'Exhale', 'Rest'],
  ),
  _BreathingMode(
    name: 'Deep Calm',
    subtitle: 'Meditative deep breathing',
    emoji: '🧘',
    color: Color(0xFF30D158),
    phases: [5, 5, 5, 5],
    phaseLabels: ['Inhale', 'Hold', 'Exhale', 'Rest'],
  ),
];

/// Экран аудио-дыхательных сессий — вкладка "Breathe".
///
/// Анимированный дыхательный круг, выбор режимов и таймера,
/// реальное обновление статистики через Riverpod.
class BreathingTab extends ConsumerStatefulWidget {
  const BreathingTab({super.key});

  @override
  ConsumerState<BreathingTab> createState() => _BreathingTabState();
}

class _BreathingTabState extends ConsumerState<BreathingTab>
    with TickerProviderStateMixin {
  int _selectedMode = 0;
  int _selectedDurationIndex = 1; // индекс из [1, 2, 3, 5] минут
  final _sessionDurations = [1, 2, 3, 5]; // минуты

  bool _isSessionActive = false;
  int _totalSessionSeconds = 0;
  int _elapsedSeconds = 0;
  int _currentCycle = 0;
  int _totalCycles = 0;
  int _currentPhaseIndex = 0;
  int _phaseElapsed = 0;

  AnimationController? _sessionController;
  AnimationController? _breathAnimController;

  void _startSession() {
    final mode = _breathingModes[_selectedMode];
    final minutes = _sessionDurations[_selectedDurationIndex];
    final totalSec = minutes * 60;
    final cycleDur = mode.cycleDuration;
    final cycles = (totalSec / cycleDur).ceil();

    _sessionController?.dispose();
    _sessionController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSec),
    );

    _breathAnimController?.dispose();
    _breathAnimController = AnimationController(
      vsync: this,
      duration: Duration(seconds: cycleDur),
    );

    setState(() {
      _isSessionActive = true;
      _totalSessionSeconds = totalSec;
      _elapsedSeconds = 0;
      _currentCycle = 1;
      _totalCycles = cycles;
      _currentPhaseIndex = 0;
      _phaseElapsed = 0;
    });

    // Ticker для отслеживания времени и фаз
    _sessionController!.addListener(() {
      if (!mounted) return;
      final elapsed = (_sessionController!.value * _totalSessionSeconds).round();
      final mode = _breathingModes[_selectedMode];
      final cycleDur = mode.cycleDuration;

      // Определяем текущую фазу
      final posInCycle = elapsed % cycleDur;
      final cycle = (elapsed ~/ cycleDur) + 1;

      int accumulated = 0;
      int phaseIdx = 0;
      int phaseElap = 0;
      for (int i = 0; i < mode.phases.length; i++) {
        if (posInCycle < accumulated + mode.phases[i]) {
          phaseIdx = i;
          phaseElap = posInCycle - accumulated;
          break;
        }
        accumulated += mode.phases[i];
      }

      setState(() {
        _elapsedSeconds = elapsed;
        _currentCycle = cycle.clamp(1, _totalCycles);
        _currentPhaseIndex = phaseIdx;
        _phaseElapsed = phaseElap;
      });
    });

    _sessionController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSessionComplete();
      }
    });

    // Запуск зацикленной дыхательной анимации
    _breathAnimController!.repeat();
    _sessionController!.forward();
  }

  void _onSessionComplete() {
    if (!mounted) return;
    final minutes = _sessionDurations[_selectedDurationIndex];

    ref.read(statsProvider.notifier).completeBreathingSession(minutes);

    _breathAnimController?.stop();
    _sessionController?.stop();

    setState(() {
      _isSessionActive = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(_breathingModes[_selectedMode].emoji,
                style: const TextStyle(fontSize: 20)),
            const Gap(10),
            Expanded(
              child: Text(
                'Session complete! $minutes min of deep calm 🙏',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor:
            _breathingModes[_selectedMode].color.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _cancelSession() {
    _breathAnimController?.stop();
    _breathAnimController?.dispose();
    _breathAnimController = null;
    _sessionController?.stop();
    _sessionController?.dispose();
    _sessionController = null;
    setState(() {
      _isSessionActive = false;
    });
  }

  @override
  void dispose() {
    _breathAnimController?.dispose();
    _sessionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    if (_isSessionActive) {
      return _buildActiveSession();
    }

    return _buildSessionPicker(stats);
  }

  // ─── Выбор сессии ───

  Widget _buildSessionPicker(DashboardStats stats) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            _buildHeader(stats),
            const Gap(24),

            // Сводная статистика
            _buildStatsRow(stats),
            const Gap(28),

            // Режимы дыхания
            Text(
              'BREATHING PATTERNS',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const Gap(14),

            ...List.generate(_breathingModes.length, (index) {
              final mode = _breathingModes[index];
              final isSelected = _selectedMode == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMode = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: isSelected
                          ? mode.color.withValues(alpha: 0.08)
                          : const Color(0x0DFFFFFF),
                      border: Border.all(
                        color: isSelected
                            ? mode.color.withValues(alpha: 0.4)
                            : AppColors.glassBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: mode.color.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: mode.color.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Text(mode.emoji,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? mode.color
                                      : AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const Gap(3),
                              Text(
                                mode.subtitle,
                                style: TextStyle(
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Фазы
                        Text(
                          mode.phases.join('-'),
                          style: TextStyle(
                            color: mode.color.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (60 * index).ms)
                  .slideX(begin: 0.02, end: 0);
            }),

            const Gap(24),

            // Выбор длительности
            Center(
              child: Text(
                'SESSION DURATION',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_sessionDurations.length, (i) {
                final isSelected = _selectedDurationIndex == i;
                final mode = _breathingModes[_selectedMode];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedDurationIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected
                          ? mode.color.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: isSelected ? mode.color : AppColors.glassBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '${_sessionDurations[i]}m',
                      style: TextStyle(
                        color: isSelected ? mode.color : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const Gap(32),

            // Кнопка Start
            Center(
              child: GestureDetector(
                onTap: _startSession,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        _breathingModes[_selectedMode].color,
                        _breathingModes[_selectedMode].color.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _breathingModes[_selectedMode]
                            .color
                            .withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 22),
                        Gap(8),
                        Text(
                          'Begin Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
            const Gap(120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUDIO-BREATHING',
          style: TextStyle(
            color: const Color(0xFFBF88FF).withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Gap(4),
        const Text(
          'Breathing Sessions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.8,
          ),
        ),
        const Gap(4),
        Text(
          'Find deep inner calm through guided breathing',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildStatsRow(DashboardStats stats) {
    final calmPercent = (stats.currentCalmLevel * 100).round();
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            '${stats.breathingSessionsToday}',
            'Sessions',
            Icons.self_improvement_rounded,
            const Color(0xFFBF88FF),
          ),
        ),
        const Gap(10),
        Expanded(
          child: _buildMiniStat(
            '${stats.totalBreathingMinutes}',
            'Minutes',
            Icons.timer_rounded,
            const Color(0xFF64D2FF),
          ),
        ),
        const Gap(10),
        Expanded(
          child: _buildMiniStat(
            '$calmPercent%',
            'Calm Level',
            Icons.favorite_rounded,
            const Color(0xFF30D158),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildMiniStat(
      String value, String label, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      borderRadius: 18,
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(2),
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

  // ─── Активная сессия ───

  Widget _buildActiveSession() {
    final mode = _breathingModes[_selectedMode];
    final phaseDuration = mode.phases[_currentPhaseIndex];
    final phaseProgress =
        phaseDuration > 0 ? (_phaseElapsed / phaseDuration).clamp(0.0, 1.0) : 0.0;
    final phaseLabel = mode.phaseLabels[_currentPhaseIndex];

    final totalRemaining = _totalSessionSeconds - _elapsedSeconds;
    final remMin = totalRemaining ~/ 60;
    final remSec = totalRemaining % 60;

    // Размер дыхательного круга зависит от фазы:
    // Вдох (0) → расширяется, Задержка (1) → максимум, Выдох (2) → сжимается, Пауза (3) → минимум
    double circleScale;
    switch (_currentPhaseIndex) {
      case 0: // Вдох — расширение
        circleScale = 0.6 + (0.4 * phaseProgress);
        break;
      case 1: // Задержка — максимум
        circleScale = 1.0;
        break;
      case 2: // Выдох — сжатие
        circleScale = 1.0 - (0.4 * phaseProgress);
        break;
      case 3: // Пауза — минимум
        circleScale = 0.6;
        break;
      default:
        circleScale = 0.8;
    }

    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Название режима
              Text(
                mode.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const Gap(6),
              Text(
                mode.name,
                style: TextStyle(
                  color: mode.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const Gap(40),

              // Дыхательный анимированный круг
              SizedBox(
                width: 240,
                height: 240,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: 200 * circleScale,
                    height: 200 * circleScale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          mode.color.withValues(alpha: 0.25),
                          mode.color.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      border: Border.all(
                        color: mode.color.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mode.color.withValues(alpha: 0.2),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            phaseLabel,
                            style: TextStyle(
                              color: mode.color,
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            '${phaseDuration - _phaseElapsed}s',
                            style: TextStyle(
                              color: mode.color.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(36),

              // Счётчик циклов
              Text(
                'Cycle $_currentCycle / $_totalCycles',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(10),

              // Оставшееся время
              Text(
                '${remMin.toString().padLeft(2, '0')}:${remSec.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2,
                ),
              ),
              const Gap(40),

              // Индикаторы фаз
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isActive = _currentPhaseIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? mode.color
                          : mode.color.withValues(alpha: 0.15),
                    ),
                  );
                }),
              ),
              const Gap(40),

              // Кнопка отмены
              GestureDetector(
                onTap: _cancelSession,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF131A26),
                    border: Border.all(
                      color: const Color(0xFFFF5E62).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text(
                    'End Session',
                    style: TextStyle(
                      color: Color(0xFFFF5E62),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
}
