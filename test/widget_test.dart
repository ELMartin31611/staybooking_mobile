import 'package:flutter_test/flutter_test.dart';
import 'package:staybooking_mobile/main.dart';

void main() {
  test(
    'StayBookingApp puede construirse',
    () {
      expect(
        const StayBookingApp(),
        isA<StayBookingApp>(),
      );
    },
  );
}
