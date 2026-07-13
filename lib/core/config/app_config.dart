import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'StayBooking';
  }

  static String get apiBaseUrl {
    const urlFromCommand = String.fromEnvironment('API_BASE_URL');

    final url = urlFromCommand.isNotEmpty
        ? urlFromCommand
        : dotenv.env['API_BASE_URL'] ?? '';

    if (url.isEmpty) {
      throw Exception('API_BASE_URL no está configurada');
    }

    return url.endsWith('/') ? url : '$url/';
  }
}
