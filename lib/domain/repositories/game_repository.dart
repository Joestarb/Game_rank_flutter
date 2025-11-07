import 'package:game_rank/models/game_rating.dart';
import 'package:game_rank/models/videjuego.dart';

/// Contrato del repositorio de juegos.
/// Define las operaciones de lectura y escritura que la capa de presentación
/// (controladores/vistas) puede usar sin conocer detalles de Firebase.
abstract class GameRepository {
  /// Lista reactiva de juegos para la pantalla principal.
  Stream<List<Videojuego>> streamGames();

  /// Rating agregado para un juego (promedio 0..5 y cantidad de votos).
  Stream<GameRating> streamGameRating(String gameId);

  /// Enviar una review (1..10) con comentario opcional.
  Future<void> submitReview({
    required String gameId,
    required int calificacion,
    String? comentario,
  });
}
