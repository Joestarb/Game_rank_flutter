import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_rank/pages/login_page.dart';
// import 'package:game_rank/services/fcm_background_handler.dart';
import 'package:game_rank/services/notification_service.dart';

import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Registrar handler de mensajes en background
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // // Inicializar servicio de notificaciones
    // await NotificationService().initialize();

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error al inicializar Firebase: $e',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );  
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Cuando la app pasa a background, mostrar notificación de recordatorio
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Mostrar notificación después de un pequeño delay para asegurar que la app esté en background
      Future.delayed(const Duration(seconds: 1), () {
        NotificationService().showValidationReminder(pendingCount: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Rank - Evento Gaming',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF), // Cyan neón
          secondary: Color(0xFFFF00FF), // Magenta neón
          tertiary: Color(0xFF39FF14), // Verde neón
          surface: Color(0xFF1A1F3A),
          error: Color(0xFFFF0055),
          onPrimary: Color(0xFF0A0E27),
          onSecondary: Color(0xFF0A0E27),
          onSurface: Color(0xFF00F0FF),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1F3A),
          elevation: 8,
          shadowColor: const Color(0xFF00F0FF).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00F0FF), width: 2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F3A),
          foregroundColor: Color(0xFF00F0FF),
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00F0FF),
            foregroundColor: const Color(0xFF0A0E27),
            elevation: 8,
            shadowColor: const Color(0xFF00F0FF).withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00F0FF),
            letterSpacing: 4,
            shadows: [Shadow(color: Color(0xFF00F0FF), blurRadius: 10)],
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF00FF),
            letterSpacing: 3,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00F0FF),
            letterSpacing: 2,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            letterSpacing: 1.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00F0FF),
            letterSpacing: 1,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0F1629),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 3),
          ),
          labelStyle: const TextStyle(color: Color(0xFF00F0FF)),
          hintStyle: const TextStyle(color: Color(0xFF607D8B)),
          prefixIconColor: Color(0xFF00F0FF),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00F0FF)),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
