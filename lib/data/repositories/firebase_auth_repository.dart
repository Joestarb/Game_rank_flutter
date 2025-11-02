import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implementación del repositorio de autenticación usando Firebase
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  FirebaseAuthRepository({FirebaseAuthDatasource? datasource})
    : _datasource = datasource ?? FirebaseAuthDatasource();

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  @override
  User? get currentUser => _datasource.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _datasource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _datasource.registerWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    return _datasource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _datasource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _datasource.sendPasswordResetEmail(email);
  }
}
