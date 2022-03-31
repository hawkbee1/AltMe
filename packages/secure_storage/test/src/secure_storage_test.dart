// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_storage/secure_storage.dart';

class MockSecureStorageProvider extends Mock implements SecureStorageProvider{}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SecureStorageProvider secureStorageProvider;

  setUp(() async {
    secureStorageProvider = MockSecureStorageProvider();
    await secureStorageProvider.deleteAll();
  });

  group('SecureStorage', () {

    test('can be instantiated', () {
      expect(secureStorageProvider, isNotNull);
    });

    test('set method', () async {
      await secureStorageProvider.set('key1', 'value');
      final result = await secureStorageProvider.get('key1');
      expect(result, equals('value'));
    });

    test('delete method', () async {
      await secureStorageProvider.set('key','value');
      await secureStorageProvider.delete('key');
      final result = await secureStorageProvider.get('key');
      expect(result, isNull);
    });

    test('deleteAll method', () async {
      await secureStorageProvider.set('key1', 'value1');
      await secureStorageProvider.set('key2', 'value2');
      await secureStorageProvider.deleteAll();
      final result = await secureStorageProvider.getAllValues();
      expect(result, '{}');
    });

    test('containsKey', () async {
      const key = 'testKey';
      expect(await secureStorageProvider.get(key), isNull);
      await secureStorageProvider.set(key, 'test');
      expect(await secureStorageProvider.get(key), isNotNull);
    });
  });
}
