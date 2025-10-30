import 'package:game_rank/controllers/home_filter_controller.dart';
import 'package:game_rank/data/repositories/firestore_game_repository.dart';
import 'package:game_rank/domain/repositories/game_repository.dart';
import 'package:game_rank/models/game_rating.dart';
import 'package:game_rank/models/videjuego.dart';
import 'package:riverpod/riverpod.dart';

// Repository provider (inyecta la implementación concreta)
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return FirestoreGameRepository();
});

// Stream de juegos para la UI
final gamesStreamProvider = StreamProvider.autoDispose<List<Videojuego>>((ref) {
  final repo = ref.watch(gameRepositoryProvider);
  return repo.streamGames();
});

// Stream del rating por juego
final gameRatingProvider = StreamProvider.autoDispose
    .family<GameRating, String>((ref, gameId) {
      final repo = ref.watch(gameRepositoryProvider);
      return repo.streamGameRating(gameId);
    });

// Filtro seleccionado en Home (Todos / Pendientes / Aprobados)
final homeFilterProvider = NotifierProvider<HomeFilterController, String>(
  HomeFilterController.new,
);
