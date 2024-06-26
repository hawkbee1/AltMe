import 'package:altme/dashboard/dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Proof model', () {
    test('default constructor work correctly', () {
      final proof =
          Proof('type', 'proofPurpose', 'verificationMethod', 'created', 'jws');
      expect(proof.type, 'type');
      expect(proof.proofPurpose, 'proofPurpose');
      expect(proof.verificationMethod, 'verificationMethod');
      expect(proof.created, 'created');
      expect(proof.jws, 'jws');
    });

    test('fromJson constructor work correctly', () {
      final proof = Proof.fromJson(
        <String, dynamic>{
          'type': 'type',
          'proofPurpose': 'proofPurpose',
          'verificationMethod': 'verificationMethod',
          'created': 'created',
          'jws': 'jws',
        },
      );
      expect(proof.type, 'type');
      expect(proof.proofPurpose, 'proofPurpose');
      expect(proof.verificationMethod, 'verificationMethod');
      expect(proof.created, 'created');
      expect(proof.jws, 'jws');
    });

    test('toJson constructor work correctly', () {
      final proof = Proof(
        'type',
        'proofPurpose',
        'verificationMethod',
        'created',
        'jws',
      );

      final json = proof.toJson();

      expect(json['type'], 'type');
      expect(json['proofPurpose'], 'proofPurpose');
      expect(json['verificationMethod'], 'verificationMethod');
      expect(json['created'], 'created');
      expect(json['jws'], 'jws');
    });

    test('dummy constructor work properly', () {
      final proof = Proof.dummy();
      expect(proof.type, 'dummy');
      expect(proof.proofPurpose, 'dummy');
      expect(proof.verificationMethod, 'dummy');
      expect(proof.created, 'dummy');
      expect(proof.jws, 'dummy');
    });
  });
}
