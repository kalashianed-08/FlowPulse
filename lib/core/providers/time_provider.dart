import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер реального времени для отображения времени в виджетах.
///
/// Обновляется каждые 10 секунд и возвращает строку в формате "HH:mm".
final timeProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>();
  
  void emitCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    controller.add('$hour:$minute');
  }

  // Сразу отправляем текущее время
  emitCurrentTime();

  // Настраиваем таймер для обновлений каждые 10 секунд
  final timer = Timer.periodic(const Duration(seconds: 10), (_) => emitCurrentTime());

  // Освобождаем ресурсы при уничтожении провайдера
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
