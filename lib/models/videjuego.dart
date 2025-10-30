enum GeneroJuego {
  accion,
  aventura,
  rol,
  estrategia,
  deportes,
  puzzle,
  plataformas,
  shooter,
  simulacion,
  indie,
}

enum EstadoValidacion { pendiente, aprobado, rechazado, enRevision }

class Videojuego {
  final String id;
  final String nombre;
  final String descripcion;
  final String desarrollador;
  final GeneroJuego genero;
  EstadoValidacion estadoValidacion;
  int likes;
  List<String> comentarios;
  double puntuacion; // 0.0 - 5.0
  int votos;
  final String? imagenUrl;
  final DateTime fechaRegistro;

  // Criterios de evaluación
  Map<String, double> criterios; // gameplay, graficos, sonido, originalidad

  Videojuego({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.desarrollador,
    required this.genero,
    this.estadoValidacion = EstadoValidacion.pendiente,
    this.likes = 0,
    List<String>? comentarios,
    this.puntuacion = 0.0,
    this.votos = 0,
    this.imagenUrl,
    DateTime? fechaRegistro,
    Map<String, double>? criterios,
  }) : comentarios = comentarios ?? [],
       fechaRegistro = fechaRegistro ?? DateTime.now(),
       criterios =
           criterios ??
           {
             'gameplay': 0.0,
             'graficos': 0.0,
             'sonido': 0.0,
             'originalidad': 0.0,
           };

  String get generoTexto {
    switch (genero) {
      case GeneroJuego.accion:
        return 'Acción';
      case GeneroJuego.aventura:
        return 'Aventura';
      case GeneroJuego.rol:
        return 'RPG';
      case GeneroJuego.estrategia:
        return 'Estrategia';
      case GeneroJuego.deportes:
        return 'Deportes';
      case GeneroJuego.puzzle:
        return 'Puzzle';
      case GeneroJuego.plataformas:
        return 'Plataformas';
      case GeneroJuego.shooter:
        return 'Shooter';
      case GeneroJuego.simulacion:
        return 'Simulación';
      case GeneroJuego.indie:
        return 'Indie';
    }
  }

  String get estadoTexto {
    switch (estadoValidacion) {
      case EstadoValidacion.pendiente:
        return 'Pendiente';
      case EstadoValidacion.aprobado:
        return 'Aprobado';
      case EstadoValidacion.rechazado:
        return 'Rechazado';
      case EstadoValidacion.enRevision:
        return 'En Revisión';
    }
  }

  void actualizarPuntuacion(double nuevaPuntuacion) {
    puntuacion = ((puntuacion * votos) + nuevaPuntuacion) / (votos + 1);
    votos++;
  }

  double get puntuacionPromedio {
    if (criterios.isEmpty) return 0.0;
    final suma = criterios.values.reduce((a, b) => a + b);
    return suma / criterios.length;
  }
}
