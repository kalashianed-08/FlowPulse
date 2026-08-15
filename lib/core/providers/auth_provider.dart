// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Провайдер, слушающий состояние авторизации пользователя Firebase.
final authStateProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream.value(null);
  }

  return FirebaseAuth.instance.authStateChanges();
});

/// Провайдер экземпляра FirebaseAuth.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Сервис аутентификации FlowPulse.
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._auth);

  /// Вход в Демо-режиме (Анонимный гостевой аккаунт Firebase)
  ///
  /// Прекрасное решение для быстрого онбординга и отладки без ввода данных.
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Anonymous Auth Error: $e');
      rethrow;
    }
  }

  /// Вход через Google Account
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Инициализируем диалоговое окно входа Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Пользователь закрыл окно

      // Получаем токены авторизации
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Создаем Firebase-учетные данные
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Входим в Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Вход через Apple ID
  ///
  /// Работает на iOS устройствах с включенной capability в Apple Developer.
  /// На Android может быть настроен через Firebase OpenID Connect Redirect.
  Future<UserCredential?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleIdCredential = 
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Apple Sign-In Error: $e');
      // В случае отсутствия аккаунта разработчика Apple, выбрасываем понятную ошибку
      rethrow;
    }
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
      rethrow;
    }
  }
}

/// Провайдер нашего AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});
