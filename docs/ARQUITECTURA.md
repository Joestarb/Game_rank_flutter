# Arquitectura MVC + Riverpod

Esta app usa una separación por capas (estilo MVC) y Riverpod para el estado. El objetivo es:

- Separar responsabilidades (UI, controladores, dominio, datos)
- Aislar Firebase en la capa de datos
- Mejorar testabilidad y escalabilidad

## Estructura de carpetas

```
lib/
  models/
    game_rating.dart           # Entidad de rating agregada
    videjuego.dart             # Entidad de dominio Juego

  domain/
    repositories/
      game_repository.dart     # Contrato del repositorio (sin Firebase)

  data/
    datasources/
      firestore_game_datasource.dart  # Acceso directo a Cloud Firestore
    repositories/
      firestore_game_repository.dart  # Implementación del contrato usando el datasource

  controllers/
    home_filter_controller.dart # Controlador del filtro (Riverpod Notifier)

  providers/
    providers.dart              # Providers (repo, streams y controladores)

  pages/
    login_page.dart             # Vista de login (UI)
    main_tabs.dart              # Shell de navegación
    tabs/
      home_page.dart           # Vista de juegos (consume providers)
      settings_page.dart       # Vista de ajustes
```

## Flujo de datos

1. La vista observa providers (p. ej., `gamesStreamProvider` y `homeFilterProvider`).
2. Los providers delegan en `GameRepository` (contrato), que a su vez usa el `FirestoreGameDataSource`.
3. `HomeFilterController` mantiene el estado del filtro actual (Todos/Pendientes/Aprobados).
4. Para enviar una review, la vista llama `submitReview` a través de `gameRepositoryProvider`.

## Providers clave (Riverpod)

- `gameRepositoryProvider`: inyecta `FirestoreGameRepository`.
- `gamesStreamProvider`: `Stream<List<Videojuego>>` para Home.
- `gameRatingProvider(gameId)`: `Stream<GameRating>` por juego.
- `homeFilterProvider`: estado del filtro vía `HomeFilterController` (Notifier).

Ejemplos de uso en la UI:

```dart
// Leer lista de juegos
final gamesAsync = ref.watch(gamesStreamProvider);

// Leer filtro actual
final filtro = ref.watch(homeFilterProvider);

// Cambiar filtro
ref.read(homeFilterProvider.notifier).setFiltro('Pendientes');

// Rating de un juego
final ratingAsync = ref.watch(gameRatingProvider(juego.id));

// Enviar review
await ref.read(gameRepositoryProvider).submitReview(
  gameId: juego.id,
  calificacion: 8,
  comentario: 'Muy buen gameplay',
);
```

## Inicialización

En `main.dart`, envolver toda la app con `ProviderScope`:

```dart
runApp(const ProviderScope(child: MyApp()));
```

## Estado del proyecto tras la migración

- Se eliminaron los artefactos legados:
  - `lib/services/firestore_repository.dart`
  - `lib/pages/tabs/videjuego_model.dart`
- La vista `home_page.dart` ya no depende de servicios concretos, solo de providers.
- Toda la lógica de acceso a datos queda aislada en `data/`.

## Extender la arquitectura

Para un nuevo caso de uso (p. ej., “marcar como favorito”):

1. Dominio: agregar al contrato en `game_repository.dart` el método `toggleFavorite(String gameId)`.
2. Datos: implementar el método en `firestore_game_repository.dart` (y, si aplica, en el datasource).
3. Provider/controlador: exponerlo via un provider o método del controlador.
4. Vista: invocar el provider/controlador desde el UI.
5. Tests: añadir pruebas a la implementación del repo y a los providers.

## Tests y calidad

- Tests: `flutter test`
- El proyecto compila con advertencias cosméticas por API deprecadas en estilos (p. ej., `withOpacity`). Se pueden refactorizar gradualmente con `.withValues()` y `onSurface`.

## Notas

- Evita que las vistas importen directamente `cloud_firestore` o `firebase_auth`.
- Prefiere `Notifier` de Riverpod (v3) para controladores simples; usa `AsyncNotifier`/`StateNotifier` si necesitas manejo explícito de estados asíncronos.
