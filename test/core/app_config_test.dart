import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_config.dart';

void main() {
  group('AppConfig', () {
    test('uses EUR as the default currency', () {
      expect(AppConfig.defaultCurrency, 'EUR');
    });
  });
}
