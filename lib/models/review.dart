import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String gameId;
  final String userId;
  final String userEmail;
  final int calificacion;
  final String comentario;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userEmail,
    required this.calificacion,
    required this.comentario,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // gameId
    final gameId = (data['gameId'] ?? '') as String;

    // userId tolerante
    final userId = (data['userId'] ?? data['usuarioId'] ?? '') as String;

    // email tolerante
    final userEmail =
        (data['userEmail'] ?? data['email'] ?? 'Usuario anónimo') as String;

    // calificacion tolerante (num o String), soporta calificacion10/calificacion
    final dynamic calRaw = data['calificacion'] ?? data['calificacion10'] ?? 0;
    int cal;
    if (calRaw is num) {
      cal = calRaw.round();
    } else if (calRaw is String) {
      cal = int.tryParse(calRaw) ?? 0;
    } else {
      cal = 0;
    }

    // comentario
    final comentario = (data['comentario'] ?? '') as String;

    // timestamp tolerante: Timestamp | String ISO | num epoch (ms o s)
    final dynamic tsRaw = data['timestamp'] ?? data['creadoEn'];
    DateTime ts;
    if (tsRaw is Timestamp) {
      ts = tsRaw.toDate();
    } else if (tsRaw is num) {
      final int v = tsRaw.toInt();
      ts = DateTime.fromMillisecondsSinceEpoch(
        v > 100000000000 ? v : v * 1000,
        isUtc: true,
      );
    } else if (tsRaw is String) {
      ts = DateTime.tryParse(tsRaw) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }

    return Review(
      id: doc.id,
      gameId: gameId,
      userId: userId,
      userEmail: userEmail,
      calificacion: cal,
      comentario: comentario,
      timestamp: ts,
    );
  }

  /// Convierte calificación de 10 a 5 estrellas
  int get estrellas => (calificacion / 2).round();

  /// Calificación en formato de 5
  double get calificacion5 => calificacion / 2.0;
}
