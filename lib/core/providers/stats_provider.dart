import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Модель данных состояния панели мониторинга (Dashboard).
class DashboardStats {
  /// Серия выполнения целей за неделю (Пн-Вс).
  final List<bool> completedDays;

  /// Текущая серия дней (Streak).
  final int streakCount;

  /// Минуты фокусировки за сегодня.
  final int focusMinutesToday;

  /// Пройденные сессии разминки за сегодня.
  final int stretchSessionsToday;

  /// Время текущего таймера разминки (в минутах).
  final int stretchTimeMinutes;

  /// Текущая выбранная асана/поза.
  final int postureIndex;

  /// Отработанные рабочие часы за день.
  final double workHours;

  /// Часы активных перерывов за день.
  final double breakHours;

  /// Количество перерывов за день.
  final int breaksCount;

  /// Минуты фокусировки за каждый день недели (Пн-Вс) для графика Безье.
  final List<double> weeklyFocusMinutes;

  /// Показатели напряжения шеи/спины за каждый день недели (Пн-Вс).
  final List<double> weeklyTensionLevels;

  // ─── Новые поля: Дыхательные сессии ───

  /// Количество завершённых дыхательных сессий за сегодня.
  final int breathingSessionsToday;

  /// Общее количество минут дыхательных сессий за сегодня.
  final int totalBreathingMinutes;

  /// Текущий уровень спокойствия (0.0 = стресс, 1.0 = полный покой).
  final double currentCalmLevel;

  // ─── Новые поля: Физические упражнения ───

  /// Количество завершённых упражнений за сегодня.
  final int exercisesCompletedToday;

  /// Общее количество минут упражнений за сегодня.
  final int totalExerciseMinutes;

  /// Имя последнего выполненного упражнения.
  final String lastExerciseName;

  DashboardStats({
    required this.completedDays,
    required this.streakCount,
    required this.focusMinutesToday,
    required this.stretchSessionsToday,
    required this.stretchTimeMinutes,
    required this.postureIndex,
    required this.workHours,
    required this.breakHours,
    required this.breaksCount,
    required this.weeklyFocusMinutes,
    required this.weeklyTensionLevels,
    required this.breathingSessionsToday,
    required this.totalBreathingMinutes,
    required this.currentCalmLevel,
    required this.exercisesCompletedToday,
    required this.totalExerciseMinutes,
    required this.lastExerciseName,
  });

  /// Состояние "Нового пользователя" / "Сброс в нуль" при регистрации.
  factory DashboardStats.zero() {
    return DashboardStats(
      completedDays: List.filled(7, false),
      streakCount: 0,
      focusMinutesToday: 0,
      stretchSessionsToday: 0,
      stretchTimeMinutes: 1,
      postureIndex: 0,
      workHours: 0.0,
      breakHours: 0.0,
      breaksCount: 0,
      weeklyFocusMinutes: List.filled(7, 0.0),
      weeklyTensionLevels: List.filled(7, 0.0),
      breathingSessionsToday: 0,
      totalBreathingMinutes: 0,
      currentCalmLevel: 0.0,
      exercisesCompletedToday: 0,
      totalExerciseMinutes: 0,
      lastExerciseName: '',
    );
  }

  DashboardStats copyWith({
    List<bool>? completedDays,
    int? streakCount,
    int? focusMinutesToday,
    int? stretchSessionsToday,
    int? stretchTimeMinutes,
    int? postureIndex,
    double? workHours,
    double? breakHours,
    int? breaksCount,
    List<double>? weeklyFocusMinutes,
    List<double>? weeklyTensionLevels,
    int? breathingSessionsToday,
    int? totalBreathingMinutes,
    double? currentCalmLevel,
    int? exercisesCompletedToday,
    int? totalExerciseMinutes,
    String? lastExerciseName,
  }) {
    return DashboardStats(
      completedDays: completedDays ?? this.completedDays,
      streakCount: streakCount ?? this.streakCount,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
      stretchSessionsToday: stretchSessionsToday ?? this.stretchSessionsToday,
      stretchTimeMinutes: stretchTimeMinutes ?? this.stretchTimeMinutes,
      postureIndex: postureIndex ?? this.postureIndex,
      workHours: workHours ?? this.workHours,
      breakHours: breakHours ?? this.breakHours,
      breaksCount: breaksCount ?? this.breaksCount,
      weeklyFocusMinutes: weeklyFocusMinutes ?? this.weeklyFocusMinutes,
      weeklyTensionLevels: weeklyTensionLevels ?? this.weeklyTensionLevels,
      breathingSessionsToday: breathingSessionsToday ?? this.breathingSessionsToday,
      totalBreathingMinutes: totalBreathingMinutes ?? this.totalBreathingMinutes,
      currentCalmLevel: currentCalmLevel ?? this.currentCalmLevel,
      exercisesCompletedToday: exercisesCompletedToday ?? this.exercisesCompletedToday,
      totalExerciseMinutes: totalExerciseMinutes ?? this.totalExerciseMinutes,
      lastExerciseName: lastExerciseName ?? this.lastExerciseName,
    );
  }
}

/// Управляющий нотифайер состояния статистики.
class StatsNotifier extends StateNotifier<DashboardStats> {
  final Ref _ref;

  StatsNotifier(this._ref) : super(DashboardStats.zero()) {
    // Слушаем изменение авторизации: если пользователь выходит или входит заново,
    // сбрасываем показатели в нули.
    _ref.listen(authStateProvider, (previous, next) {
      if (next.value == null) {
        resetStats();
      } else {
        // При логировании нового/демо аккаунта инициализируем нулевые показатели
        resetStats();
      }
    });
  }

  /// Сброс всех показателей в 0.
  void resetStats() {
    state = DashboardStats.zero();
  }

  /// Отметить/снять отметку дня недели (Пн-Вс).
  void toggleStreakDay(int index) {
    final updatedDays = List<bool>.from(state.completedDays);
    updatedDays[index] = !updatedDays[index];

    // Динамический пересчет серии (Streak) последовательных отмеченных дней
    var currentStreak = 0;
    for (final day in updatedDays) {
      if (day) {
        currentStreak++;
      } else {
        break;
      }
    }

    state = state.copyWith(
      completedDays: updatedDays,
      streakCount: currentStreak,
    );
  }

  /// Завершение сессии фокусировки Pomodoro (добавление минут).
  void completeFocusSession(int minutes) {
    final todayWeekday = DateTime.now().weekday; // 1 (Mon) - 7 (Sun)
    final todayIndex = (todayWeekday - 1).clamp(0, 6);

    // Добавляем минуты к сегодняшнему показателю
    final newTodayMinutes = state.focusMinutesToday + minutes;

    // Обновляем точки на еженедельном графике (максимум нормируем к 120 минутам)
    final updatedWeeklyFocus = List<double>.from(state.weeklyFocusMinutes);
    // Добавляем к существующему прогрессу дня и нормируем от 0.0 до 1.0 (1.0 = 120 минут)
    final totalMins = (updatedWeeklyFocus[todayIndex] * 120.0) + minutes;
    updatedWeeklyFocus[todayIndex] = (totalMins / 120.0).clamp(0.0, 1.0);

    // Также плавно обновляем баланс работы/отдыха
    final newWorkHours = state.workHours + (minutes / 60.0);

    state = state.copyWith(
      focusMinutesToday: newTodayMinutes,
      weeklyFocusMinutes: updatedWeeklyFocus,
      workHours: newWorkHours,
    );
  }

  /// Логирование уровня напряжения (Pain level 1-10) шеи/спины.
  void logTension(int rating) {
    final todayWeekday = DateTime.now().weekday;
    final todayIndex = (todayWeekday - 1).clamp(0, 6);

    final updatedWeeklyTension = List<double>.from(state.weeklyTensionLevels);
    updatedWeeklyTension[todayIndex] = rating.toDouble().clamp(0.0, 10.0);

    state = state.copyWith(
      weeklyTensionLevels: updatedWeeklyTension,
    );
  }

  /// Изменение выбранной позы/асаны.
  void setPostureIndex(int index) {
    state = state.copyWith(postureIndex: index);
  }

  /// Завершение сессии микро-разминки (Micro-Stretch).
  void completeStretchSession() {
    final newSessionsCount = state.stretchSessionsToday + 1;

    // Добавляем 0.15 часа (9 минут) активного перерыва за сессию
    final newBreakHours = state.breakHours + 0.15;
    final newBreaksCount = state.breaksCount + 1;

    state = state.copyWith(
      stretchSessionsToday: newSessionsCount,
      breakHours: newBreakHours,
      breaksCount: newBreaksCount,
    );
  }

  /// Ручная регулировка баланса слайдером.
  void adjustBalance(double delta) {
    final newWorkHours = (state.workHours + delta).clamp(0.0, 12.0);
    // Перерывы пропорциональны рабочему времени (18%) плюс накопленный эффект разминок
    final newBreakHours = (newWorkHours * 0.18).clamp(0.0, 3.0);
    final newBreaksCount = (newBreakHours * 7).round();

    state = state.copyWith(
      workHours: newWorkHours,
      breakHours: newBreakHours,
      breaksCount: newBreaksCount,
    );
  }

  /// Обновление времени таймера разминки.
  void setStretchTimeMinutes(int minutes) {
    state = state.copyWith(stretchTimeMinutes: minutes);
  }

  // ─── Новые методы ───

  /// Завершение дыхательной сессии.
  ///
  /// Увеличивает счётчик сессий, добавляет минуты и плавно повышает
  /// уровень спокойствия (calm level) с каждой сессией.
  void completeBreathingSession(int minutes) {
    final newSessionsCount = state.breathingSessionsToday + 1;
    final newTotalMinutes = state.totalBreathingMinutes + minutes;

    // Уровень спокойствия растёт с каждой сессией (макс 1.0)
    // Каждая минута добавляет ~0.05 к спокойствию
    final newCalmLevel = (state.currentCalmLevel + (minutes * 0.05)).clamp(0.0, 1.0);

    // Дыхание также улучшает баланс: добавляем к перерывам
    final newBreakHours = state.breakHours + (minutes / 60.0);
    final newBreaksCount = state.breaksCount + 1;

    state = state.copyWith(
      breathingSessionsToday: newSessionsCount,
      totalBreathingMinutes: newTotalMinutes,
      currentCalmLevel: newCalmLevel,
      breakHours: newBreakHours,
      breaksCount: newBreaksCount,
    );
  }

  /// Завершение упражнения для тела.
  ///
  /// Увеличивает счётчик упражнений, добавляет минуты, обновляет
  /// имя последнего упражнения и вносит вклад в streak/баланс.
  void completeExerciseSession(int minutes, String exerciseName) {
    final newExercisesCount = state.exercisesCompletedToday + 1;
    final newTotalMinutes = state.totalExerciseMinutes + minutes;

    // Упражнения уменьшают напряжение
    final todayWeekday = DateTime.now().weekday;
    final todayIndex = (todayWeekday - 1).clamp(0, 6);
    final updatedTension = List<double>.from(state.weeklyTensionLevels);
    // Каждое упражнение снижает напряжение на 0.5 (минимум 0)
    updatedTension[todayIndex] = (updatedTension[todayIndex] - 0.5).clamp(0.0, 10.0);

    // Упражнения добавляют к перерывам
    final newBreakHours = state.breakHours + (minutes / 60.0);
    final newBreaksCount = state.breaksCount + 1;

    // Также увеличиваем stretch sessions (упражнения = разминка)
    final newStretchSessions = state.stretchSessionsToday + 1;

    state = state.copyWith(
      exercisesCompletedToday: newExercisesCount,
      totalExerciseMinutes: newTotalMinutes,
      lastExerciseName: exerciseName,
      weeklyTensionLevels: updatedTension,
      breakHours: newBreakHours,
      breaksCount: newBreaksCount,
      stretchSessionsToday: newStretchSessions,
    );
  }
}

/// Провайдер состояния статистики.
final statsProvider = StateNotifierProvider<StatsNotifier, DashboardStats>((ref) {
  return StatsNotifier(ref);
});
