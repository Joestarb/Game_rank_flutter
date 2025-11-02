import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Datasource que maneja toda la lógica de Firebase Auth
class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream de cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  /// Iniciar sesión con email y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Registrar nuevo usuario
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    String rol = 'usuario',
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Crear documento en Firestore 'users/{uid}'
      final user = cred.user;
      if (user != null) {
        final doc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await doc.set({
          'id': user.uid,
          'email': user.email ?? email.trim(),
          'nombre': nombre.trim(),
          'rol': rol,
          'creadoEn': DateTime.now().toUtc().toIso8601String(),
        }, SetOptions(merge: true));
        // Opcional: actualizar displayName en Auth
        await user.updateDisplayName(nombre.trim());
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Iniciar sesión con Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Iniciar flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        throw Exception('Inicio de sesión con Google cancelado');
      }

      // 2. Obtener detalles de autenticación de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crear credencial de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase con la credencial
      final cred = await _firebaseAuth.signInWithCredential(credential);
      // Asegurar documento en Firestore
      final user = cred.user;
      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            'id': user.uid,
            'email': user.email ?? '',
            'nombre': user.displayName ?? 'Usuario',
            'rol': 'usuario',
            'creadoEn': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  /// Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Maneja excepciones de Firebase Auth y las convierte en mensajes legibles
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son inválidas';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
