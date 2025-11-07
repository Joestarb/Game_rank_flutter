import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review.dart';

/// Provider que obtiene todas las reviews de un juego específico
final gameReviewsProvider = StreamProvider.family<List<Review>, String>((
  ref,
  gameId,
) {
  // Para compatibilidad con esquemas mixtos (timestamp | creadoEn),
  // no usamos orderBy en Firestore y ordenamos en memoria por review.timestamp.
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('gameId', isEqualTo: gameId)
      .snapshots()
      .map((snapshot) {
        final reviews = snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList();
        reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return reviews;
      });
});
