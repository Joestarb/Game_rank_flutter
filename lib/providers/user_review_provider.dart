import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que verifica si el usuario actual ya calificó un juego específico
/// Retorna la calificación del usuario si existe, null si no ha calificado
final userReviewProvider = StreamProvider.family<Map<String, dynamic>?, String>((
  ref,
  gameId,
) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value(null);
  }

  // Tolerar userId | usuarioId en los documentos
  // No es posible hacer OR en Firestore; por compatibilidad, probamos primero userId
  // y si viene vacío, probamos con usuarioId.
  final baseQuery = FirebaseFirestore.instance
      .collection('reviews')
      .where('gameId', isEqualTo: gameId);

  final streamUserId = baseQuery
      .where('userId', isEqualTo: user.uid)
      .limit(1)
      .snapshots()
      .map((snapshot) => snapshot.docs);

  // Si no hay con userId, buscar con usuarioId
  return streamUserId.asyncExpand((docs) {
    if (docs.isNotEmpty) {
      final doc = docs.first;
      final data = doc.data();
      return Stream.value({
        'id': doc.id,
        'calificacion': data['calificacion'] ?? data['calificacion'] ?? 0,
        'comentario': data['comentario'] ?? '',
        'fecha': data['timestamp'] ?? data['creadoEn'],
      });
    }
    // Buscar por usuarioId
    return baseQuery
        .where('usuarioId', isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          final data = doc.data();
          return {
            'id': doc.id,
            'calificacion': data['calificacion'] ?? data['calificacion'] ?? 0,
            'comentario': data['comentario'] ?? '',
            'fecha': data['timestamp'] ?? data['creadoEn'],
          };
        });
  });
});
