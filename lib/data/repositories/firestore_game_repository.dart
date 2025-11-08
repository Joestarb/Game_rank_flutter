import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_rank/data/datasources/firestore_game_datasource.dart';
import 'package:game_rank/domain/repositories/game_repository.dart';
import 'package:game_rank/models/game_rating.dart';
import 'package:game_rank/models/videjuego.dart';

/// Implementación concreta del repositorio sobre Firestore.
class FirestoreGameRepository implements GameRepository {
  final FirestoreGameDataSource _ds;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirestoreGameRepository({
    FirestoreGameDataSource? dataSource,
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  }) : _ds = dataSource ?? FirestoreGameDataSource(),
       _auth = auth ?? FirebaseAuth.instance,
       _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Videojuego>> streamGames() => _ds.streamGames();

  @override
  Stream<GameRating> streamGameRating(String gameId) =>
      _ds.streamGameRating(gameId);

  @override
  Future<void> submitReview({
    required String gameId,
    required int calificacion,
    String? comentario,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    // Obtener perfil desde users para email/nombre fiables
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final profile = userDoc.data();
    final userEmail = profile?['email'] as String? ?? user.email;
    final userName = profile?['nombre'] as String? ?? user.displayName;

    // Escribimos campos duplicados para compatibilidad hacia atrás y futura
    await _db.collection('reviews').add({
      'gameId': gameId,
      // IDs de usuario en ambos nombres
      'userId': user.uid,
      'usuarioId': user.uid,
      // Correo del usuario para mostrar autor (si está disponible)
      'userEmail': userEmail,
      'userName': userName,
      // Calificación en escala 1..10 con ambos nombres
      'calificacion': calificacion,
      'comentario': comentario ?? '',
      // Timestamp con ambos nombres
      'timestamp': FieldValue.serverTimestamp(),
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // Regla simple de validación: si el juego tiene al menos 1 review,
    // se marca como 'aprobado'.
    try {
      final countSnap = await _db
          .collection('reviews')
          .where('gameId', isEqualTo: gameId)
          .limit(1) // solo necesitamos saber si existe al menos una
          .get();

      if (countSnap.docs.isNotEmpty) {
        await _db.collection('games').doc(gameId).set({
          'estadoValidacion': 'aprobado',
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // Silencioso: si falla, no bloquea el envío de la review
    }
  }
}
