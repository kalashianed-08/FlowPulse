import 'package:flutter/material.dart';

/// Дизайн-токены цветов для FlowPulse.
///
/// Разработаны специально для темной темы премиум-класса с эффектом "Spatial UI".
abstract class AppColors {
  // Основные фоновые цвета
  static const Color background = Color(0xFF08090C); // Глубокий обволакивающий оникс
  static const Color surface = Color(0x0DFFFFFF);    // Основа матового стекла (5% белый)
  static const Color surfaceOverlay = Color(0x1AFFFFFF); // Наложение на стекло (10% белый)
  
  // Рамки и разделители
  static const Color glassBorder = Color(0x14FFFFFF);    // Тонкий контур стекла (8% белый)
  static const Color divider = Color(0x12FFFFFF);        // Мягкий внутренний разделитель

  // Текст
  static const Color textPrimary = Color(0xFFF5F5F7);      // Белый сан-франциско (Apple primary)
  static const Color textSecondary = Color(0xFF8E8E93);    // Приглушенный серый
  static const Color textTertiary = Color(0xFF48484A);     // Темно-серый для второстепенных деталей

  // Сигнальные цвета
  static const Color error = Color(0xFFFF453A);            // Apple Red
  static const Color success = Color(0xFF30D158);          // Apple Green

  // Градиенты для состояний
  
  /// Градиент активного фокуса ("Поток" / Flow State)
  static const List<Color> flowGradient = [
    Color(0xFF00F2FE), // Неоновый циан
    Color(0xFF4FACFE), // Энергичный синий
  ];

  /// Градиент расслабления и медитации ("Спокойствие" / Calm & Focus)
  static const List<Color> calmGradient = [
    Color(0xFF89F7FE), // Светлая мята
    Color(0xFF66A6FF), // Мягкий васильковый
  ];

  /// Градиент восстановления сил ("Восстановление" / Restore & Sleep)
  static const List<Color> restoreGradient = [
    Color(0xFFBF88FF), // Светло-фиолетовый
    Color(0xFF7A4FAC), // Глубокая лаванда
  ];

  /// Градиент мягкого заката для фонового свечения
  static const List<Color> ambientGlow = [
    Color(0x1F00F2FE),
    Color(0x1F7A4FAC),
  ];
}
