import 'package:altme/app/app.dart';
import 'package:test/test.dart';

void main() {
  group('OIDC4VCType Extension Tests', () {
    test('OIDC4VCType isEnabled returns correct value', () {
      expect(OIDC4VCType.DEFAULT.isEnabled, equals(true));
      expect(OIDC4VCType.GAIAX.isEnabled, equals(true));
      expect(OIDC4VCType.GREENCYPHER.isEnabled, equals(true));
      expect(OIDC4VCType.EBSIV3.isEnabled, equals(true));
      expect(OIDC4VCType.JWTVC.isEnabled, equals(false));
      expect(OIDC4VCType.HAIP.isEnabled, equals(true));
    });
  });
}
