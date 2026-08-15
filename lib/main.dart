import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

void main() async {
  // Гарантируем инициализацию связки с движком Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем Firebase бэкенд
  if (!(kDebugMode && defaultTargetPlatform == TargetPlatform.android)) {
    await Firebase.initializeApp();
  }
  
  // Запускаем приложение, обернутое в ProviderScope для работы Riverpod
  runApp(
    const ProviderScope(
      child: FlowPulseApp(),
    ),
  );
}
