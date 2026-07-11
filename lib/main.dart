import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Asegúrate de tener este paquete

import 'core/config/app_config.dart';
import 'presentation/screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: StayBookingApp()));
}

class StayBookingApp extends StatelessWidget {
  const StayBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF0D1B2A); // Un azul más profundo y lujoso
    const Color accentGold = Color(0xFFC5A059);  // Oro mate
    const Color accentRed = Color(0xFFF2051D);
    const Color background = Color(0xFFF8F9FA);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        // Tipografía: Usamos 'Plus Jakarta Sans' o 'Montserrat' para un look elegante
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: accentRed,
          primary: accentRed,
          secondary: accentGold,
          tertiary: primaryNavy,
          surface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: accentRed,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        // Estilo de Tarjetas: Elevadas y con bordes suaves
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),

        // Botones con estilo moderno (bordes redondeados y sombra sutil)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: accentRed.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentRed,
            side: const BorderSide(color: accentRed, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accentRed,
        ),

        // Inputs con "Floating Label" y estilo limpio
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accentGold, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}