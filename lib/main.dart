import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_rank/pages/login_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    print("❌ Error al conectar Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          background: Color(0xFF0A0E27),
          error: Color(0xFFFF0055),
          onPrimary: Color(0xFF0A0E27),
          onSecondary: Color(0xFF0A0E27),
          onSurface: Color(0xFF00F0FF),
          onBackground: Color(0xFFFFFFFF),
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
