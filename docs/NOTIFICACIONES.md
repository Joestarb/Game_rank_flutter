# Notificaciones Push - Game Rank

## Implementación completada

✅ Se ha integrado Firebase Cloud Messaging (FCM) y notificaciones locales en la aplicación.

### Características implementadas

1. **Servicio de notificaciones** (`lib/services/notification_service.dart`)

   - Gestión centralizada de FCM y `flutter_local_notifications`
   - Canal de notificaciones Android: `game_rank_reminders`
   - Solicitud de permisos (Android 13+ e iOS)
   - Manejo de mensajes en foreground con notificaciones locales

2. **Detección de cierre de app** (`lib/main.dart`)

   - `WidgetsBindingObserver` que detecta cuando la app pasa a background
   - Dispara notificación local automáticamente: "Todavía hay juegos que debes validar..."

3. **Background handler** (`lib/services/fcm_background_handler.dart`)

   - Función top-level para procesar mensajes cuando la app está cerrada/background

4. **Configuración Android**

   - Permiso `POST_NOTIFICATIONS` para Android 13+
   - Metadata de canal por defecto en `AndroidManifest.xml`
   - Google Services plugin ya configurado en Gradle

5. **Provider de juegos pendientes** (`lib/providers/pending_games_provider.dart`)
   - Cuenta juegos con estado `EstadoValidacion.pendiente`
   - Disponible para uso futuro en notificación con conteo real

## Cómo funciona

1. Al iniciar la app, se inicializa FCM y se solicitan permisos.
2. Cuando el usuario cierra la app (o la pone en background), se dispara una notificación local.
3. La notificación muestra: "🎮 Juegos pendientes" / "Todavía hay juegos que debes validar..."

## Próximos pasos opcionales

### Mejorar con conteo real de pendientes

Para mostrar el número exacto de juegos pendientes, puedes modificar `_MyAppState` en `main.dart`:

```dart
// En lugar de usar ConsumerStatefulWidget, mantener referencia al container
class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Leer el conteo de juegos pendientes
      final pendingCount = ref.read(pendingGamesCountProvider);
      Future.delayed(const Duration(seconds: 1), () {
        NotificationService().showValidationReminder(pendingCount: pendingCount);
      });
    }
  }
}
```

### Enviar notificaciones desde servidor

#### 1. Obtener token del dispositivo

```dart
final token = await NotificationService().getToken();
// Enviar este token a tu backend
```

#### 2. Enviar desde Firebase Console

- Ve a Firebase Console → Cloud Messaging
- Click en "New notification"
- Ingresa título y mensaje
- En Target, selecciona "Single device" y pega el token

#### 3. Enviar con curl (legacy API - solo pruebas)

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Recordatorio",
      "body": "Tienes 5 juegos pendientes de validar"
    },
    "data": {
      "route": "/home"
    }
  }'
```

#### 4. Enviar con firebase-admin (Node.js - recomendado)

```javascript
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const message = {
  token: "DEVICE_FCM_TOKEN",
  notification: {
    title: "🎮 Juegos pendientes",
    body: "Tienes 3 juegos que debes validar",
  },
  data: {
    route: "/home",
    gameId: "abc123",
  },
};

admin
  .messaging()
  .send(message)
  .then((response) => console.log("Enviado:", response))
  .catch((error) => console.log("Error:", error));
```

### Testing

1. Ejecutar la app:

```bash
flutter run
```

2. Minimizar la app (Home button en Android/iOS)
3. Deberías ver la notificación: "🎮 Juegos pendientes - Todavía hay juegos que debes validar..."

### Debugging

- Ver logs FCM: `adb logcat | grep FCM`
- Ver token en consola al iniciar la app
- Verificar permisos en Configuración → Apps → Game Rank → Notificaciones

## Archivos modificados/creados

- ✅ `lib/services/notification_service.dart` - Servicio de notificaciones
- ✅ `lib/services/fcm_background_handler.dart` - Handler background FCM
- ✅ `lib/providers/pending_games_provider.dart` - Provider conteo pendientes
- ✅ `lib/main.dart` - Integración lifecycle observer + FCM init
- ✅ `android/app/src/main/AndroidManifest.xml` - Permisos y metadata
- ✅ `pubspec.yaml` - Dependencias firebase_messaging y flutter_local_notifications

## Notas importantes

- El permiso `POST_NOTIFICATIONS` solo se solicita en Android 13+ (API 33)
- En versiones anteriores de Android, las notificaciones están habilitadas por defecto
- Para iOS necesitas configurar APNs y el archivo `GoogleService-Info.plist`
- El icono de notificación es `@mipmap/ic_launcher` (puedes personalizarlo)
