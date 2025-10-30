import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_rank/models/game_rating.dart';
import 'package:game_rank/models/videjuego.dart';
import 'package:game_rank/providers/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _mostrarDialogoCalificar(
    BuildContext context,
    WidgetRef ref,
    String gameId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para calificar')),
      );
      return;
    }

    int valor = 8; // por defecto 8/10
    String comentario = '';

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1629),
          title: const Text('Calificar juego (1 - 10)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setLocal) {
                  return Column(
                    children: [
                      Slider(
                        value: valor.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$valor',
                        onChanged: (v) => setLocal(() => valor = v.round()),
                      ),
                      TextField(
                        onChanged: (v) => comentario = v,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Comentario (opcional)',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () async {
                try {
                  final repo = ref.read(gameRepositoryProvider);
                  await repo.submitReview(
                    gameId: gameId,
                    calificacion10: valor,
                    comentario: comentario.trim().isEmpty ? null : comentario,
                  );
                  if (context.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review enviada')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroSeleccionado = ref.watch(homeFilterProvider);
    final gamesAsync = ref.watch(gamesStreamProvider);
    return Column(
      children: [
        // Header con filtros
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
            ),
            border: Border(
              bottom: BorderSide(color: const Color(0xFF00F0FF), width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.videogame_asset,
                    color: const Color(0xFF00F0FF),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'VALIDACIÓN DE JUEGOS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00F0FF),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(ref, filtroSeleccionado, 'Todos'),
                    const SizedBox(width: 8),
                    _buildFilterChip(ref, filtroSeleccionado, 'Pendientes'),
                    const SizedBox(width: 8),
                    _buildFilterChip(ref, filtroSeleccionado, 'Aprobados'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Lista de juegos
        Expanded(
          child: gamesAsync.when(
            data: (juegos) {
              // Filtrar por estado si corresponde
              final filtrados = () {
                if (filtroSeleccionado == 'Pendientes') {
                  return juegos
                      .where(
                        (j) => j.estadoValidacion == EstadoValidacion.pendiente,
                      )
                      .toList();
                } else if (filtroSeleccionado == 'Aprobados') {
                  return juegos
                      .where(
                        (j) => j.estadoValidacion == EstadoValidacion.aprobado,
                      )
                      .toList();
                }
                return juegos;
              }();

              if (filtrados.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Color(0xFF607D8B),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay juegos en esta categoría',
                        style: TextStyle(
                          color: Color(0xFF607D8B),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final juego = filtrados[index];
                  return _buildGameCard(ref, juego);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String selected, String label) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () {
        ref.read(homeFilterProvider.notifier).setFiltro(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00F0FF), width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF0A0E27)
                : const Color(0xFF00F0FF),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(WidgetRef ref, Videojuego juego) {
    Color estadoColor;
    IconData estadoIcon;

    switch (juego.estadoValidacion) {
      case EstadoValidacion.aprobado:
        estadoColor = const Color(0xFF39FF14);
        estadoIcon = Icons.check_circle;
        break;
      case EstadoValidacion.rechazado:
        estadoColor = const Color(0xFFFF0055);
        estadoIcon = Icons.cancel;
        break;
      case EstadoValidacion.enRevision:
        estadoColor = const Color(0xFFFFFF00);
        estadoIcon = Icons.hourglass_empty;
        break;
      default:
        estadoColor = const Color(0xFF607D8B);
        estadoIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: estadoColor, width: 3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
        ),
        boxShadow: [
          BoxShadow(
            color: estadoColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.games, color: estadoColor, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        juego.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00F0FF),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por ${juego.desarrollador}',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF607D8B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        estadoIcon,
                        size: 16,
                        color: const Color(0xFF0A0E27),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        juego.estadoTexto.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A0E27),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenido del card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Género
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF00FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF00FF),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${juego.generoTexto.toUpperCase()} GAME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF00FF),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  juego.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFE0E0E0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Rating
                Consumer(
                  builder: (context, ref, _) {
                    final ratingAsync = ref.watch(gameRatingProvider(juego.id));
                    final rating =
                        ratingAsync.asData?.value ?? GameRating.empty;
                    final avg = rating.averageOutOf5;
                    final count = rating.reviewsCount;
                    return Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFFF00),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          avg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFFF00),
                          ),
                        ),
                        const Text(
                          ' / 5.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF607D8B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($count votos)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF607D8B),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _mostrarDialogoCalificar(context, ref, juego.id),
                          icon: const Icon(Icons.rate_review, size: 18),
                          label: const Text('CALIFICAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF00FF),
                            foregroundColor: const Color(0xFF0A0E27),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF2A3F54)),
                const SizedBox(height: 16),
                // ...existing code...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
