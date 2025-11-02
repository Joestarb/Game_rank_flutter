import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String gameId;
  final String userId;
  final String userEmail;
  final int calificacion10;
  final String comentario;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userEmail,
    required this.calificacion10,
    required this.comentario,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      gameId: data['gameId'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? 'Usuario anónimo',
      calificacion10: data['calificacion10'] ?? 0,
      comentario: data['comentario'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convierte calificación de 10 a 5 estrellas
  int get estrellas => (calificacion10 / 2).round();

  /// Calificación en formato de 5
  double get calificacion5 => calificacion10 / 2.0;
}
