import 'package:game_rank/models/videjuego.dart';
import 'package:game_rank/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

/// Provider que cuenta juegos pendientes de validación
final pendingGamesCountProvider = Provider.autoDispose<int>((ref) {
  final gamesAsync = ref.watch(gamesStreamProvider);

  return gamesAsync.when(
    data: (games) {
      return games
          .where((game) => game.estadoValidacion == EstadoValidacion.pendiente)
          .length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
