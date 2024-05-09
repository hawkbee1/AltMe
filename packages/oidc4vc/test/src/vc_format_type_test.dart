import 'package:flutter_test/flutter_test.dart';
import 'package:oidc4vc/oidc4vc.dart';

void main() {
  group('VCFormatTypeX', () {
    test('formattedString', () {
      expect(VCFormatType.ldpVc.vcValue, 'ldp_vc');
      expect(VCFormatType.jwtVc.vcValue, 'jwt_vc');
      expect(VCFormatType.jwtVcJson.vcValue, 'jwt_vc_json');
      expect(VCFormatType.jwtVcJsonLd.vcValue, 'jwt_vc_json-ld');
      expect(VCFormatType.vcSdJWT.vcValue, 'vc+sd-jwt');
    });

    test('value', () {
      expect(VCFormatType.ldpVc.vpValue, 'ldp_vp');
      expect(VCFormatType.jwtVc.vpValue, 'jwt_vp');
      expect(VCFormatType.jwtVcJson.vpValue, 'jwt_vp_json');
      expect(VCFormatType.jwtVcJsonLd.vpValue, 'jwt_vp_json-ld');
      expect(VCFormatType.vcSdJWT.vpValue, 'vc+sd-jwt');
    });

    test('urlValue', () {
      expect(VCFormatType.ldpVc.urlValue, 'ldp_vc');
      expect(VCFormatType.jwtVc.urlValue, 'jwt_vc');
      expect(VCFormatType.jwtVcJson.urlValue, 'jwt_vc_json');
      expect(VCFormatType.jwtVcJsonLd.urlValue, 'jwt_vc_json-ld');
      expect(VCFormatType.vcSdJWT.urlValue, 'vcsd-jwt');
    });

    test('supportCryptoCredential', () {
      expect(VCFormatType.ldpVc.supportCryptoCredential, true);
      expect(VCFormatType.jwtVc.supportCryptoCredential, false);
      expect(VCFormatType.jwtVcJson.supportCryptoCredential, true);
      expect(VCFormatType.jwtVcJsonLd.supportCryptoCredential, false);
      expect(VCFormatType.vcSdJWT.supportCryptoCredential, false);
    });
  });
}
