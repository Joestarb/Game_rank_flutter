import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review.dart';

/// Provider que obtiene todas las reviews de un juego específico
final gameReviewsProvider = StreamProvider.family<List<Review>, String>((
  ref,
  gameId,
) {
  // No usamos orderBy en la consulta para ser compatibles con colecciones
  // que usan distintos nombres de campo de fecha (timestamp | creadoEn).
  // Ordenamos en memoria por la fecha mapeada en el modelo.
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('gameId', isEqualTo: gameId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
      });
});
