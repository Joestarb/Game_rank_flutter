# Game Rank (Flutter)

Aplicación Flutter para listar, evaluar y comentar videojuegos. Usa Firebase (Auth + Firestore) y Riverpod para estado. La arquitectura separa UI, controladores, dominio y datos para facilitar mantenimiento y escalabilidad.

• Tecnologías principales: Flutter, Riverpod, Firebase Auth, Cloud Firestore, intl (localización ES)

## Características

- Lista de juegos desde la colección `games` en Firestore.
- Calificación por estrellas (1 a 5) y comentario por usuario (se guarda como escala 1..10 para precisión).
- Promedio de rating (0..5) y cantidad de votos por juego.
- Al enviar la primera review, el juego cambia de estado a “Evaluado”.
- Búsqueda por nombre, desarrollador y género.
- Soporte de localización en español (fechas formateadas con `intl`).

## Arquitectura (MVC + Riverpod)

Separación por capas con contrato de repositorio en dominio y una implementación concreta para Firestore.

- UI (pages): dibuja pantallas y observa providers.
- Controllers (Riverpod Notifier): estados simples (p. ej. filtro y búsqueda).
- Providers: exponen streams (juegos, ratings) y controladores a la UI.
- Domain: contrato `GameRepository` (sin Firebase).
- Data: `FirestoreGameDataSource` (acceso directo a Firestore) y `FirestoreGameRepository` (implementación del contrato).

Diagrama simple de flujo de datos:

UI (Home) → Providers → GameRepository (contrato) → FirestoreGameRepository → FirestoreGameDataSource → Firestore

Documentación más detallada: `docs/ARQUITECTURA.md`.

## Estructura de carpetas

```
lib/
	models/
		game_rating.dart
		videjuego.dart

	domain/
		repositories/
			game_repository.dart

	data/
		datasources/
			firestore_game_datasource.dart
		repositories/
			firestore_game_repository.dart

	controllers/
		home_filter_controller.dart
		search_query_controller.dart

	providers/
		providers.dart

	pages/
		main_tabs.dart
		login_page.dart
		tabs/
			home_page.dart
			settings_page.dart
```

## Estados de un juego

Internamente el enum es `pendiente | aprobado | rechazado | enRevision`, pero en la UI se muestran con texto:

- Pendiente → “Pendiente”
- Aprobado → “Evaluado” (visible en la app)
- Rechazado → “Rechazado”
- En revisión → “En Revisión”

En Firestore el campo `estadoValidacion` se escribe como `'evaluado'` cuando el juego recibe su primera review. También se tolera `'aprobado'` por compatibilidad con datos antiguos.

## Datos en Firestore

Colecciones mínimas esperadas:

- `games` (documentos = juegos)

  - `titulo` (String)
  - `descripcion` (String)
  - `desarrollador` (String)
  - `categoria` (String: accion/aventura/rol/…)
  - `imagenURL` (String?)
  - `creadoEn` (Timestamp/String)
  - `estadoValidacion` (String: 'pendiente' | 'evaluado' | 'rechazado' | 'enRevision')

- `reviews` (documentos = calificaciones/comentarios)

  - `gameId` (String)
  - `usuarioId` o `userId` (String)
  - `calificacion` (num 1..10) → se muestra como estrellas dividiendo entre 2
  - `comentario` (String)
  - `creadoEn` o `timestamp` (Timestamp/String)
  - `userEmail` (String?) y `userName` (String?) para mostrar autor

- `users` (documentos con id = uid de FirebaseAuth)
  - `nombre` (String?)
  - `email` (String)
  - `rol` (String?)

Notas de compatibilidad:

- El código tolera distintos nombres de campos (p. ej., `usuarioId`/`userId`, `creadoEn`/`timestamp`).
- Para `estadoValidacion`, se aceptan `'evaluado'` y `'aprobado'` al leer.

## Providers clave (UI)

- `gameRepositoryProvider`: inyecta `FirestoreGameRepository`.
- `gamesStreamProvider`: `Stream<List<Videojuego>>` para la Home.
- `gameRatingProvider(gameId)`: `Stream<GameRating>` por juego.
- `homeFilterProvider`: estado del filtro (Todos/Pendientes/Evaluados).
- `searchQueryProvider`: cadena de búsqueda libre (Notifier simple).

Uso típico en la UI:

```dart
// Leer lista de juegos
final gamesAsync = ref.watch(gamesStreamProvider);

// Leer filtro actual
final filtro = ref.watch(homeFilterProvider);

// Cambiar filtro
ref.read(homeFilterProvider.notifier).setFiltro('Pendientes');

// Rating de un juego
final ratingAsync = ref.watch(gameRatingProvider(juego.id));

// Actualizar texto de búsqueda
ref.read(searchQueryProvider.notifier).setQuery('plataformas');

// Enviar review
await ref.read(gameRepositoryProvider).submitReview(
	gameId: juego.id,
	calificacion: 8, // 4 estrellas
	comentario: 'Muy buen gameplay',
);
```

## Configuración y ejecución

Requisitos previos:

- Flutter SDK instalado y dispositivo/emulador configurado.
- Proyecto Firebase con Auth y Firestore habilitados.

Pasos de configuración básicos:

1. Android: coloca tu `google-services.json` en `android/app/`.
2. iOS: coloca tu `GoogleService-Info.plist` en `ios/Runner/`.
3. Web: asegúrate de tener inicialización de Firebase en `web/index.html` (si compilas para web).
4. Revisa reglas de Firestore y crea las colecciones `games`, `reviews`, `users`.

Comandos útiles (opcionales):

```bash
flutter pub get
flutter run
flutter test
```

## Internacionalización

Se inicializa `intl` para español en `main.dart` (formato de fechas ‘es’). Si cambias el locale, recuerda inicializarlo antes de `runApp`.

## Buenas prácticas y notas

- Las vistas no dependen directamente de Firebase; usan providers y repositorios.
- Se prefiere `Notifier` de Riverpod para controladores simples (`homeFilter`, `searchQuery`).
- El listado de reviews ordena por fecha en memoria para tolerar variaciones de campos; puedes volver a `orderBy` cuando unifiques esquema e índices.
- Hay advertencias cosméticas por APIs de estilo (p. ej., `withOpacity` deprecado). Se puede migrar gradualmente.

## Extender la arquitectura (ejemplo rápido)

Para “marcar como favorito”:

1. Dominio: agrega `toggleFavorite(String gameId)` en `game_repository.dart`.
2. Datos: implementa en `firestore_game_repository.dart` e idealmente en el datasource.
3. Provider/controlador: expón la acción vía provider o método de Notifier.
4. UI: invoca desde la vista.
5. Tests: añade pruebas de repo y providers.

## Próximos pasos sugeridos

- Unificar el esquema de Firestore (nombres de campos) y añadir índices si vuelves a ordenar del lado del servidor.
- Añadir tests widget para flujos críticos (enviar review, filtrar, buscar).
- Soportar estados adicionales (p. ej., “En revisión” avanzado, moderación/admin).

---

Autor: Equipo Game Rank

```

```
