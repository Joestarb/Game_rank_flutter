import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio centralizado para gestionar notificaciones push (FCM) y locales.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'game_rank_reminders', // id
    'Recordatorios de Validación', // title
    description: 'Notificaciones para recordar validar juegos pendientes',
    importance: Importance.high,
  );

  bool _initialized = false;

  /// Inicializa el servicio de notificaciones locales y FCM
  Future<void> initialize() async {
    if (_initialized) return;

    // Configurar notificaciones locales (Android + iOS)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crear canal de notificaciones en Android (8.0+)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Solicitar permisos (iOS y Android 13+)
    await _requestPermissions();

    // Configurar listeners de FCM para foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    _initialized = true;
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('📱 Permiso de notificaciones: ${settings.authorizationStatus}');
  }

  /// Obtener token FCM del dispositivo (para envío desde servidor)
  Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('🔑 FCM Token: $token');
    return token;
  }

  /// Manejo de mensajes FCM en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['route'], // para navegación
      );
    }
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('📲 Notificación tocada con payload: $payload');
      // Aquí puedes agregar navegación: navigatorKey.currentState?.pushNamed(payload);
    }
  }

  /// Mostrar notificación local de recordatorio de validación
  Future<void> showValidationReminder({required int pendingCount}) async {
    const id = 1; // ID fijo para recordatorios de validación
    final title = '🎮 Juegos pendientes';
    final body = pendingCount > 0
        ? 'Todavía hay $pendingCount ${pendingCount == 1 ? "juego" : "juegos"} que debes validar...'
        : 'Todavía hay juegos que debes validar...';

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
