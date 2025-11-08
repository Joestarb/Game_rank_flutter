import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_rank/models/game_rating.dart';
import 'package:game_rank/models/videjuego.dart';
import 'package:game_rank/pages/game_reviews_page.dart';
import 'package:game_rank/providers/providers.dart';
import 'package:game_rank/providers/user_review_provider.dart';

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

    int estrellas = 0; // Sin calificación inicial
    final comentarioController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1629),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00F0FF), width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.rate_review, color: Color(0xFF00F0FF), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Calificar Juego',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cuántas estrellas le das?',
                    style: TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setLocal) {
                      return Column(
                        children: [
                          // Estrellas interactivas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starValue = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  setLocal(() => estrellas = starValue);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Icon(
                                    estrellas >= starValue
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: estrellas >= starValue
                                        ? const Color(0xFFFFFF00)
                                        : const Color(0xFF607D8B),
                                    size: 40,
                                    shadows: estrellas >= starValue
                                        ? [
                                            const Shadow(
                                              color: Color(0xFFFFFF00),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          // Texto de calificación
                          Text(
                            estrellas == 0
                                ? 'Toca para calificar'
                                : '$estrellas ${estrellas == 1 ? "estrella" : "estrellas"}',
                            style: TextStyle(
                              color: estrellas == 0
                                  ? const Color(0xFF607D8B)
                                  : const Color(0xFFFFFF00),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          if (estrellas == 0) ...[
                            const SizedBox(height: 8),
                            const Text(
                              '⚠️ Debes seleccionar al menos 1 estrella',
                              style: TextStyle(
                                color: Color(0xFFFF0055),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tu comentario (obligatorio)',
                    style: TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: comentarioController,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          '¿Qué te pareció el juego? Comparte tu opinión...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF607D8B),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1F3A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF00F0FF),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF00F0FF),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF00FF),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF0055),
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF0055),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '⚠️ El comentario es obligatorio';
                      }
                      if (value.trim().length < 10) {
                        return '⚠️ El comentario debe tener al menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF607D8B)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                foregroundColor: const Color(0xFF0A0E27),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Enviar Review',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              onPressed: () async {
                // Validar que haya seleccionado estrellas
                if (estrellas == 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Debes seleccionar al menos 1 estrella'),
                      backgroundColor: Color(0xFFFF0055),
                    ),
                  );
                  return;
                }

                // Validar el formulario (comentario)
                if (!formKey.currentState!.validate()) {
                  return;
                }

                try {
                  final repo = ref.read(gameRepositoryProvider);

                  // Convertir estrellas (1-5) a calificación de 10
                  // 1 estrella = 2/10, 2 estrellas = 4/10, etc.
                  final calificacion = estrellas * 2;

                  await repo.submitReview(
                    gameId: gameId,
                    calificacion: calificacion,
                    comentario: comentarioController.text.trim(),
                  );

                  if (context.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF39FF14),
                            ),
                            const SizedBox(width: 8),
                            const Text('Review enviada con éxito'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1A1F3A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF39FF14),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Color(0xFFFF0055)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Error: $e')),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1A1F3A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFFFF0055),
                            width: 2,
                          ),
                        ),
                      ),
                    );
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
              // Buscador
              TextField(
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).setQuery(v.trim()),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, desarrollador o género...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFF0F1629),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF00F0FF),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF00F0FF),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF00FF),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
              final filtroTexto = ref
                  .watch(searchQueryProvider)
                  .toLowerCase()
                  .trim();

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

              // Filtro por texto
              final buscados = filtroTexto.isEmpty
                  ? filtrados
                  : filtrados.where((j) {
                      final nombre = j.nombre.toLowerCase();
                      final dev = j.desarrollador.toLowerCase();
                      final genero = j.generoTexto.toLowerCase();
                      return nombre.contains(filtroTexto) ||
                          dev.contains(filtroTexto) ||
                          genero.contains(filtroTexto);
                    }).toList();

              if (buscados.isEmpty) {
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
                        'No hay resultados con los filtros actuales',
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
                itemCount: buscados.length,
                itemBuilder: (context, index) {
                  final juego = buscados[index];
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
                // Rating y botones
                Consumer(
                  builder: (context, ref, _) {
                    final ratingAsync = ref.watch(gameRatingProvider(juego.id));
                    final userReviewAsync = ref.watch(
                      userReviewProvider(juego.id),
                    );

                    final rating =
                        ratingAsync.asData?.value ?? GameRating.empty;
                    final userReview = userReviewAsync.asData?.value;
                    final hasReviewed = userReview != null;

                    final avg = rating.averageOutOf5;
                    final count = rating.reviewsCount;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating promedio
                        Row(
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
                              '($count ${count == 1 ? "voto" : "votos"})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF607D8B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Botones de acción
                        Row(
                          children: [
                            // Botón ver reviews
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          GameReviewsPage(juego: juego),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.comment, size: 18),
                                label: Text('VER REVIEWS ($count)'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF00F0FF),
                                  side: const BorderSide(
                                    color: Color(0xFF00F0FF),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón calificar o estado
                            Expanded(
                              child: hasReviewed
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF39FF14,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF39FF14),
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF39FF14),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'YA VALIDASTE',
                                            style: const TextStyle(
                                              color: Color(0xFF39FF14),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () => _mostrarDialogoCalificar(
                                        context,
                                        ref,
                                        juego.id,
                                      ),
                                      icon: const Icon(
                                        Icons.rate_review,
                                        size: 18,
                                      ),
                                      label: const Text('CALIFICAR'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFF00FF,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF0A0E27,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        // Mostrar calificación del usuario si ya validó
                        if (hasReviewed) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF39FF14).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF39FF14).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Color(0xFF39FF14),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tu calificación: ',
                                  style: TextStyle(
                                    color: Color(0xFF607D8B),
                                    fontSize: 12,
                                  ),
                                ),
                                ...List.generate(5, (index) {
                                  final stars = (userReview['calificacion'] / 2)
                                      .round();
                                  return Icon(
                                    index < stars
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: index < stars
                                        ? const Color(0xFFFFFF00)
                                        : const Color(0xFF607D8B),
                                    size: 16,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  '${(userReview['calificacion'] / 2).toStringAsFixed(1)} / 5.0',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFF00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
