import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(
    const ProviderScope(
      child: StayBookingApp(),
    ),
  );
}

class StayBookingApp extends StatelessWidget {
  const StayBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      home: const BackendConfigTestScreen(),
    );
  }
}

class BackendConfigTestScreen extends StatelessWidget {
  const BackendConfigTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
      ),
      body: Center(
        child: Text(
          'Backend conectado a:\n${AppConfig.apiBaseUrl}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}