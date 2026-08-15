import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowpulse/app/app.dart';
import 'package:flowpulse/core/providers/auth_provider.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Рендерим наше приложение, подменяя провайдер авторизации на Mock-стрим
    // для обхода живой инициализации Firebase во время тестов.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const FlowPulseApp(),
      ),
    );

    // Даем завершиться всем вступительным анимациям Glass UI
    await tester.pumpAndSettle();

    // Проверяем, что заголовок "FlowPulse" отобразился на экране приветствия
    expect(find.text('FlowPulse'), findsOneWidget);
    
    // Проверяем, что кнопка продолжения с Google на месте
    expect(find.text('Continue with Google'), findsOneWidget);
    
    // Проверяем наличие кнопки быстрого Демо-входа
    expect(find.text('Quick Demo Drive'), findsOneWidget);
  });
}
