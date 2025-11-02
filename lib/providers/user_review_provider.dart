import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que verifica si el usuario actual ya calificó un juego específico
/// Retorna la calificación del usuario si existe, null si no ha calificado
final userReviewProvider = StreamProvider.family<Map<String, dynamic>?, String>(
  (ref, gameId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection('reviews')
        .where('gameId', isEqualTo: gameId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          final doc = snapshot.docs.first;
          return {
            'id': doc.id,
            'calificacion': doc.data()['calificacion10'] ?? 0,
            'comentario': doc.data()['comentario'] ?? '',
            'fecha': doc.data()['timestamp'],
          };
        });
  },
);
