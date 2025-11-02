import 'package:firebase_auth/firebase_auth.dart';

/// Contrato del repositorio de autenticación
/// Define las operaciones disponibles sin depender de Firebase
abstract class AuthRepository {
  /// Stream que emite el usuario actual cuando cambia el estado de autenticación
  Stream<User?> get authStateChanges;

  /// Usuario actual autenticado (null si no hay sesión)
  User? get currentUser;

  /// Iniciar sesión con email y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registrar nuevo usuario con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    String rol = 'usuario',
  });

  /// Iniciar sesión con Google
  Future<UserCredential> signInWithGoogle();

  /// Cerrar sesión
  Future<void> signOut();

  /// Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email);
}
