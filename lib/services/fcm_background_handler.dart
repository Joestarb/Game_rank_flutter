import 'package:firebase_messaging/firebase_messaging.dart';

/// Background handler para FCM (debe ser top-level function)
/// Se ejecuta cuando la app está en background o terminada
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message recibido: ${message.messageId}');
  // Aquí puedes procesar data-only messages en background
}
