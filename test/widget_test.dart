import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:staybooking_mobile/main.dart';

void main() {
  testWidgets('renderiza app base', (WidgetTester tester) async {
    dotenv.testLoad(
      fileInput: 'APP_NAME=StayBooking\nAPI_BASE_URL=http://localhost:8000/',
    );

    await tester.pumpWidget(const StayBookingApp());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
