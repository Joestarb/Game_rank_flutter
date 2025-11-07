import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_rank/models/review.dart';
import 'package:game_rank/models/videjuego.dart';
import 'package:game_rank/providers/game_reviews_provider.dart';
import 'package:intl/intl.dart';
import 'package:game_rank/providers/user_profile_provider.dart';

class GameReviewsPage extends ConsumerWidget {
  final Videojuego juego;

  const GameReviewsPage({super.key, required this.juego});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(gameReviewsProvider(juego.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REVIEWS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header con info del juego
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00F0FF),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.games,
                        color: Color(0xFF00F0FF),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            juego.nombre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00F0FF),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Por ${juego.desarrollador}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF607D8B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF00FF),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de reviews
          Expanded(
            child: reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.rate_review,
                          size: 64,
                          color: Color(0xFF607D8B),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aún no hay reviews',
                          style: TextStyle(
                            color: Color(0xFF607D8B),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sé el primero en calificar este juego',
                          style: TextStyle(
                            color: Color(0xFF607D8B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _buildReviewCard(ref, review);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                // Mensaje claro si falta un índice compuesto en Firestore
                if (error is FirebaseException &&
                    error.code == 'failed-precondition') {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Color(0xFFFFFF00),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Se requiere un índice en Firestore para esta consulta.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Crea un índice compuesto para la colección "reviews" con los campos:\n• gameId (ASC)\n• timestamp (DESC)\n\nEn Firebase Console: Firestore → Índices → Crear índice.',
                          style: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tip: En los logs aparece un enlace directo para crear el índice automáticamente.',
                          style: TextStyle(
                            color: Color(0xFF607D8B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Center(
                  child: Text(
                    'Error al cargar reviews: $error',
                    style: const TextStyle(color: Color(0xFFFF0055)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(WidgetRef ref, Review review) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'es');
    final formattedDate = dateFormat.format(review.timestamp);
    final profileAsync = ref.watch(userProfileProvider(review.userId));
    final displayName = profileAsync.when(
      data: (p) => (p?['nombre'] as String?)?.trim().isNotEmpty == true
          ? p!['nombre'] as String
          : (p?['email'] as String?) ?? review.userEmail,
      loading: () => review.userEmail,
      error: (_, __) => review.userEmail,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F0FF), width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3A), Color(0xFF0F1629)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con usuario y fecha
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF00F0FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Color(0xFF00F0FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF607D8B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2A3F54)),
            const SizedBox(height: 12),
            // Estrellas
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.estrellas ? Icons.star : Icons.star_border,
                    color: index < review.estrellas
                        ? const Color(0xFFFFFF00)
                        : const Color(0xFF607D8B),
                    size: 24,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${review.calificacion5.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(
                    color: Color(0xFFFFFF00),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Comentario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E27).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3F54), width: 1),
              ),
              child: Text(
                review.comentario,
                style: const TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
