import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_rank/models/game_rating.dart';
import 'package:game_rank/models/videjuego.dart';

/// DataSource de acceso directo a Cloud Firestore.
class FirestoreGameDataSource {
  final FirebaseFirestore _db;
  FirestoreGameDataSource({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Videojuego>> streamGames() {
    return _db
        .collection('games')
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_gameFromDoc).toList());
  }

  Videojuego _gameFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    // Mapear categoria -> GeneroJuego
    final categoria = (data['categoria'] as String?)?.toLowerCase().trim();
    final genero = _mapCategoriaToGenero(categoria);

    // Estado de validación opcional, si existiera en el doc
    final estadoTexto = (data['estadoValidacion'] as String?)?.toLowerCase();
    final estado = _mapEstado(estadoTexto);

    return Videojuego(
      id: doc.id,
      nombre: data['titulo'] ?? 'Sin título',
      descripcion: data['descripcion'] ?? '',
      desarrollador: data['desarrollador'] ?? 'Desconocido',
      genero: genero,
      imagenUrl: data['imagenURL'] as String?,
      fechaRegistro: _tryParseDate(data['creadoEn']) ?? DateTime.now(),
      estadoValidacion: estado,
      // Estos se calculan con reviews, los inicializamos en 0
      puntuacion: 0,
      votos: 0,
      likes: 0,
    );
  }

  GeneroJuego _mapCategoriaToGenero(String? c) {
    switch (c) {
      case 'accion':
      case 'acción':
        return GeneroJuego.accion;
      case 'aventura':
        return GeneroJuego.aventura;
      case 'rpg':
      case 'rol':
        return GeneroJuego.rol;
      case 'estrategia':
        return GeneroJuego.estrategia;
      case 'deportes':
        return GeneroJuego.deportes;
      case 'puzzle':
        return GeneroJuego.puzzle;
      case 'plataformas':
        return GeneroJuego.plataformas;
      case 'shooter':
        return GeneroJuego.shooter;
      case 'simulacion':
      case 'simulación':
        return GeneroJuego.simulacion;
      case 'indie':
      default:
        return GeneroJuego.indie;
    }
  }

  EstadoValidacion _mapEstado(String? v) {
    switch (v) {
      case 'aprobado':
        return EstadoValidacion.aprobado;
      case 'rechazado':
        return EstadoValidacion.rechazado;
      case 'enrevision':
      case 'en_revisión':
      case 'en revisión':
        return EstadoValidacion.enRevision;
      case 'pendiente':
      default:
        return EstadoValidacion.pendiente;
    }
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Stream<GameRating> streamGameRating(String gameId) {
    return _db
        .collection('reviews')
        .where('gameId', isEqualTo: gameId)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return GameRating.empty;
          double sum = 0;
          for (final d in snap.docs) {
            final data = d.data();
            // Tolerar calificacion | calificacion
            final v10 =
                (data['calificacion'] as num?)?.toDouble() ??
                (data['calificacion'] as num?)?.toDouble() ??
                0.0;
            sum += v10;
          }
          final count = snap.docs.length;
          // calificacion viene 1-10; convertimos a 0-5 para estrellas
          final avgOutOf5 = (sum / count) / 2.0;
          return GameRating(averageOutOf5: avgOutOf5, reviewsCount: count);
        });
  }
}
