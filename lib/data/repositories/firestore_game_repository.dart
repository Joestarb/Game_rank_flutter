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
    required int calificacion10,
    String? comentario,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _db.collection('reviews').add({
      'gameId': gameId,
      'usuarioId': user.uid,
      'calificacion': calificacion10,
      'comentario': comentario ?? '',
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }
}
