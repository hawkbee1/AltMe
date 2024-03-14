import 'dart:convert';
import 'dart:io';

import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/oidc4vc/oidc4vc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:convert/convert.dart';

import 'package:dartez/dartez.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:jose/jose.dart';
import 'package:json_path/json_path.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:key_generator/key_generator.dart';
import 'package:oidc4vc/oidc4vc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_storage/secure_storage.dart';

String generateDefaultAccountName(
  int accountIndex,
  List<String> accountNameList,
) {
  final defaultAccountName = 'My account ${accountIndex + 1}';
  final containSameName = accountNameList.contains(defaultAccountName);
  if (containSameName) {
    return generateDefaultAccountName(accountIndex + 1, accountNameList);
  } else {
    return defaultAccountName;
  }
}

bool get isAndroid => Platform.isAndroid;

bool get isIOS => Platform.isIOS;

String getIssuerDid({required Uri uriToCheck}) {
  String did = '';
  uriToCheck.queryParameters.forEach((key, value) {
    if (key == 'issuer') {
      did = value;
    }
  });
  return did;
}

bool isValidPrivateKey(String value) {
  bool isEthereumPrivateKey = false;
  if (RegExp(r'^(0x)?[0-9a-f]{64}$', caseSensitive: false).hasMatch(value)) {
    isEthereumPrivateKey = true;
  }

  return value.startsWith('edsk') ||
      value.startsWith('spsk') ||
      value.startsWith('p2sk') ||
      value.startsWith('0x') ||
      isEthereumPrivateKey;
}

KeyStoreModel getKeysFromSecretKey({required String secretKey}) {
  final List<String> sourceKeystore = Dartez.getKeysFromSecretKey(secretKey);

  return KeyStoreModel(
    secretKey: sourceKeystore[0],
    publicKey: sourceKeystore[1],
    publicKeyHash: sourceKeystore[2],
  );
}

String stringToHexPrefixedWith05({required String payload}) {
  final String formattedInput = <String>[
    'Tezos Signed Message:',
    'altme.io',
    DateTime.now().toString(),
    payload,
  ].join(' ');

  final String bytes = char2Bytes(formattedInput);

  const String prefix = '05';
  const String stringIsHex = '0100';
  final String bytesOfByteLength = char2Bytes(bytes.length.toString());

  final payloadBytes = '$prefix$stringIsHex$bytesOfByteLength$bytes';

  return payloadBytes;
}

String char2Bytes(String text) {
  final List<int> encode = utf8.encode(text);
  final String bytes = hex.encode(encode);
  return bytes;
}

Future<bool> isConnected() async {
  final log = getLogger('Check Internet Connection');

  if (!isAndroid) {
    if (!(await DeviceInfoPlugin().iosInfo).isPhysicalDevice) {
      return true;
    }
  }
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  log.e('No Internet Connection');
  return false;
}

String getCredentialName(String constraints) {
  final dynamic constraintsJson = jsonDecode(constraints);
  final fieldsPath = JsonPath(r'$..fields');
  final dynamic credentialField =
      (fieldsPath.read(constraintsJson).first.value as List)
          .where(
            (dynamic e) =>
                e['path'].toString() == r'[$.credentialSubject.type]',
          )
          .toList()
          .first;
  return credentialField['filter']['pattern'] as String;
}

String getIssuersName(String constraints) {
  final dynamic constraintsJson = jsonDecode(constraints);
  final fieldsPath = JsonPath(r'$..fields');
  final dynamic issuerField =
      (fieldsPath.read(constraintsJson).first.value as List)
          .where(
            (dynamic e) => e['path'].toString() == r'[$.issuer]',
          )
          .toList()
          .first;
  return issuerField['filter']['pattern'] as String;
}

BlockchainType getBlockchainType(AccountType accountType) {
  switch (accountType) {
    case AccountType.ssi:
      throw Exception();
    case AccountType.tezos:
      return BlockchainType.tezos;
    case AccountType.ethereum:
      return BlockchainType.ethereum;
    case AccountType.fantom:
      return BlockchainType.fantom;
    case AccountType.polygon:
      return BlockchainType.polygon;
    case AccountType.binance:
      return BlockchainType.binance;
  }
}

CredentialSubjectType? getCredTypeFromName(String credentialName) {
  for (final element in CredentialSubjectType.values) {
    if (credentialName == element.name) {
      return element;
    }
  }
  return null;
}

Future<bool> isCredentialPresentable(String credentialName) async {
  final CredentialSubjectType? credentialSubjectType =
      getCredTypeFromName(credentialName);

  if (credentialSubjectType == null) {
    return true;
  }

  final isPresentable = await isCredentialAvaialble(credentialSubjectType);

  return isPresentable;
}

Future<bool> isCredentialAvaialble(
  CredentialSubjectType credentialSubjectType,
) async {
  /// fetching all the credentials
  final CredentialsRepository repository =
      CredentialsRepository(getSecureStorage);

  final List<CredentialModel> allCredentials = await repository.findAll();

  for (final credential in allCredentials) {
    if (credentialSubjectType ==
        credential
            .credentialPreview.credentialSubjectModel.credentialSubjectType) {
      return true;
    }
  }

  return false;
}

String timeFormatter({required int timeInSecond}) {
  final int sec = timeInSecond % 60;
  final int min = (timeInSecond / 60).floor();
  final String minute = min.toString().length <= 1 ? '0$min' : '$min';
  final String second = sec.toString().length <= 1 ? '0$sec' : '$sec';
  return '$minute : $second';
}

Future<List<String>> getssiMnemonicsInList(
  SecureStorageProvider secureStorageProvider,
) async {
  final phrase = await secureStorageProvider.get(SecureStorageKeys.ssiMnemonic);
  return phrase!.split(' ');
}

Future<bool> getStoragePermission() async {
  if (isAndroid) {
    return true;
  }
  if (await Permission.storage.request().isGranted) {
    return true;
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  } else if (await Permission.storage.request().isDenied) {
    return false;
  }
  return false;
}

String getDateTimeWithoutSpace() {
  final dateTime = DateTime.fromMicrosecondsSinceEpoch(
    DateTime.now().microsecondsSinceEpoch,
  ).toString().replaceAll(' ', '-');
  return dateTime;
}

Future<String> web3RpcMainnetInfuraURL() async {
  await dotenv.load();
  final String infuraApiKey = dotenv.get('INFURA_API_KEY');
  const String prefixUrl = Parameters.web3RpcMainnetUrl;
  return '$prefixUrl$infuraApiKey';
}

int getIndexValue({
  required bool isEBSIV3,
  required DidKeyType didKeyType,
}) {
  switch (didKeyType) {
    case DidKeyType.secp256k1:
      if (isEBSIV3) {
        return 3;
      } else {
        return 1;
      }
    case DidKeyType.p256:
      return 4;
    case DidKeyType.ebsiv3:
      return 5;
    case DidKeyType.jwkP256:
      return 6;

    case DidKeyType.edDSA:
    case DidKeyType.jwtClientAttestation:
      return 0; // it is not needed, just assigned
  }
}

Future<String> getPrivateKey({
  required ProfileCubit profileCubit,
  required DidKeyType didKeyType,
}) async {
  final mnemonic = await profileCubit.secureStorageProvider
      .get(SecureStorageKeys.ssiMnemonic);

  switch (didKeyType) {
    case DidKeyType.edDSA:
      final ssiKey = await getSecureStorage.get(SecureStorageKeys.ssiKey);
      return ssiKey.toString();

    case DidKeyType.secp256k1:
      final index = getIndexValue(
        isEBSIV3: true,
        didKeyType: didKeyType,
      );
      final key = profileCubit.oidc4vc.privateKeyFromMnemonic(
        mnemonic: mnemonic!,
        indexValue: index,
      );
      return key;

    case DidKeyType.p256:
    case DidKeyType.ebsiv3:
    case DidKeyType.jwkP256:
      final indexValue = getIndexValue(
        isEBSIV3: false,
        didKeyType: didKeyType,
      );

      final key = profileCubit.oidc4vc.p256PrivateKeyFromMnemonics(
        mnemonic: mnemonic!,
        indexValue: indexValue,
      );

      return key;

    case DidKeyType.jwtClientAttestation:
      if (profileCubit.state.model.walletType != WalletType.enterprise) {
        throw ResponseMessage(
          data: {
            'error': 'invalid_request',
            'error_description': 'Please switch to enterprise account',
          },
        );
      }

      final walletAttestationData = await profileCubit.secureStorageProvider
          .get(SecureStorageKeys.walletAttestationData);

      if (walletAttestationData == null) {
        throw Exception();
      }

      final p256KeyForWallet =
          await getWalletP256Key(profileCubit.secureStorageProvider);

      return p256KeyForWallet;
  }
}

Future<String> getWalletP256Key(SecureStorageProvider secureStorage) async {
  const storageKey = SecureStorageKeys.p256PrivateKeyForWallet;

  /// return key if it is already created
  final String? p256PrivateKey = await secureStorage.get(storageKey);
  if (p256PrivateKey != null) return p256PrivateKey.replaceAll('=', '');

  /// create key if it is not created
  final newKey = generateRandomP256Key();

  await secureStorage.set(storageKey, newKey);

  return newKey;
}

String generateRandomP256Key() {
  /// create key if it is not created
  final jwk = JsonWebKey.generate('ES256');

  final json = jwk.toJson();

  // Sort the keys in ascending order and remove alg
  final sortedJwk = Map.fromEntries(
    json.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
  )..remove('keyOperations');

  final newKey = jsonEncode(sortedJwk).replaceAll('=', '');

  return newKey;
}

DidKeyType? getDidKeyFromString(String? didKeyTypeString) {
  if (didKeyTypeString == null) return null;
  for (final name in DidKeyType.values) {
    if (name.toString() == didKeyTypeString) {
      return name;
    }
  }
  return null;
}

Future<String> fetchPrivateKey({
  required ProfileCubit profileCubit,
  required DidKeyType didKeyType,
  bool? isEBSIV3,
}) async {
  if (isEBSIV3 != null && isEBSIV3) {
    final privateKey = await getPrivateKey(
      profileCubit: profileCubit,
      didKeyType: DidKeyType.ebsiv3,
    );

    return privateKey;
  }

  final privateKey = await getPrivateKey(
    profileCubit: profileCubit,
    didKeyType: didKeyType,
  );

  return privateKey;
}

Map<String, dynamic> decodePayload({
  required JWTDecode jwtDecode,
  required String token,
}) {
  final log = getLogger('QRCodeScanCubit - jwtDecode');
  late final Map<String, dynamic> data;

  try {
    final payload = jwtDecode.parseJwt(token);
    data = payload;
  } catch (e, s) {
    log.e('An error occurred while decoding.', error: e, stackTrace: s);
  }
  return data;
}

Map<String, dynamic> decodeHeader({
  required JWTDecode jwtDecode,
  required String token,
}) {
  final log = getLogger('QRCodeScanCubit - jwtDecode');
  late final Map<String, dynamic> data;

  try {
    final header = jwtDecode.parseJwtHeader(token);
    data = header;
  } catch (e, s) {
    log.e('An error occurred while decoding.', error: e, stackTrace: s);
  }
  return data;
}

String birthDateFormater(int birthData) {
  final String birthdate = birthData.toString();

  // Parse the input string
  final DateTime parsedBirthdate = DateTime.parse(
    '${birthdate.substring(0, 4)}-${birthdate.substring(4, 6)}-${birthdate.substring(6, 8)}', // ignore: lines_longer_than_80_chars
  );

  // Format the parsed date
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedBirthdate = formatter.format(parsedBirthdate);

  return formattedBirthdate;
}

String getSignatureType(String circuitId) {
  if (circuitId == 'credentialAtomicQuerySigV2' ||
      circuitId == 'credentialAtomicQuerySigV2OnChain') {
    return 'BJJ Signature';
  } else if (circuitId == 'credentialAtomicQueryMTPV2' ||
      circuitId == 'credentialAtomicQueryMTPV2OnChain') {
    return 'SMT Signature';
  }

  return '';
}

String splitUppercase(String input) {
  final regex = RegExp('(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])');
  return input.split(regex).join(' ');
}

List<String> generateUriList(String url) {
  final uri = Uri.parse(url);

  final finalList = <String>[];

  final uriList = uri.queryParametersAll['uri_list'];
  if (uriList != null) {
    for (final uriString in uriList) {
      final Uri uriItem = Uri.parse(Uri.decodeComponent(uriString));
      finalList.add(uriItem.toString());
    }
  }

  return uriList ?? [];
}

String getUtf8Message(String maybeHex) {
  if (maybeHex.startsWith('0x')) {
    final List<int> decoded = hex.decode(
      maybeHex.substring(2),
    );
    return utf8.decode(decoded);
  }

  return maybeHex;
}

Future<(String, String)> getDidAndKid({
  required String privateKey,
  required ProfileCubit profileCubit,
  required DidKeyType didKeyType,
}) async {
  late String did;
  late String kid;

  switch (didKeyType) {
    case DidKeyType.ebsiv3:

      //b'\xd1\xd6\x03' in python
      final List<int> prefixByteList = [0xd1, 0xd6, 0x03];
      final List<int> prefix = prefixByteList.map((byte) => byte).toList();

      final encodedData = utf8.encode(sortedPublcJwk(privateKey));
      final encodedAddress = Base58Encode([...prefix, ...encodedData]);

      did = 'did:key:z$encodedAddress';
      final String lastPart = did.split(':')[2];
      kid = '$did#$lastPart';
    case DidKeyType.jwkP256:
      final encodedData = utf8.encode(sortedPublcJwk(privateKey));

      final base64EncodedJWK = base64UrlEncode(encodedData).replaceAll('=', '');
      did = 'did:jwk:$base64EncodedJWK';

      kid = '$did#0';
    case DidKeyType.p256:
    case DidKeyType.secp256k1:
    case DidKeyType.edDSA:
      const didMethod = AltMeStrings.defaultDIDMethod;
      did = profileCubit.didKitProvider.keyToDID(didMethod, privateKey);
      kid = await profileCubit.didKitProvider
          .keyToVerificationMethod(didMethod, privateKey);
    case DidKeyType.jwtClientAttestation:
      if (profileCubit.state.model.walletType != WalletType.enterprise) {
        throw ResponseMessage(
          data: {
            'error': 'invalid_request',
            'error_description': 'Please switch to enterprise account',
          },
        );
      }

      final walletAttestationData = await profileCubit.secureStorageProvider
          .get(SecureStorageKeys.walletAttestationData);

      if (walletAttestationData == null) {
        throw Exception();
      }

      final walletAttestationDataPayload =
          profileCubit.jwtDecode.parseJwt(walletAttestationData);

      did = walletAttestationDataPayload['cnf']['jwk']['kid'].toString();
      kid = did;
  }

  return (did, kid);
}

Future<(String, String)> fetchDidAndKid({
  required String privateKey,
  bool? isEBSIV3,
  required ProfileCubit profileCubit,
  required DidKeyType didKeyType,
}) async {
  if (isEBSIV3 != null && isEBSIV3) {
    final (did, kid) = await getDidAndKid(
      didKeyType: DidKeyType.ebsiv3,
      privateKey: privateKey,
      profileCubit: profileCubit,
    );

    return (did, kid);
  }

  final (did, kid) = await getDidAndKid(
    didKeyType: didKeyType,
    privateKey: privateKey,
    profileCubit: profileCubit,
  );

  return (did, kid);
}

String sortedPublcJwk(String privateKey) {
  final private = jsonDecode(privateKey) as Map<String, dynamic>;
  final publicJWK = Map.of(private)..removeWhere((key, value) => key == 'd');

  /// we use crv P-256K in the rest of the package to ensure compatibility
  /// with jose dart package. In fact our crv is secp256k1 wich change the
  /// fingerprint

  final sortedJwk = Map.fromEntries(
    publicJWK.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
  )
    ..removeWhere((key, value) => key == 'use')
    ..removeWhere((key, value) => key == 'alg');

  /// this test is to be crv agnostic and respect https://www.rfc-editor.org/rfc/rfc7638
  if (sortedJwk['crv'] == 'P-256K') {
    sortedJwk['crv'] = 'secp256k1';
  }

  final jsonString = jsonEncode(sortedJwk).replaceAll(' ', '');
  return jsonString;
}

bool isPolygonIdUrl(String url) =>
    url.startsWith('{"id":') ||
    url.startsWith('{"body":{"') ||
    url.startsWith('{"from": "did:polygonid:') ||
    url.startsWith('{"to": "did:polygonid:') ||
    url.startsWith('{"thid":') ||
    url.startsWith('{"typ":') ||
    url.startsWith('{"type":');

bool isOIDC4VCIUrl(Uri uri) {
  return uri.toString().startsWith('openid') ||
      uri.toString().startsWith('haip');
}

bool isSIOPV2OROIDC4VPUrl(Uri uri) {
  final isOpenIdUrl = uri.toString().startsWith('openid://?') ||
      uri.toString().startsWith('openid-vc://?') ||
      uri.toString().startsWith('openid-hedera://?') ||
      uri.toString().startsWith('haip://?');

  final isSiopv2Url = uri.toString().startsWith('siopv2://?');
  final isAuthorizeEndPoint =
      uri.toString().startsWith(Parameters.authorizeEndPoint);

  return isOpenIdUrl || isAuthorizeEndPoint || isSiopv2Url;
}

/// OIDC4VCType?, OpenIdConfiguration?, OpenIdConfiguration?,
/// credentialOfferJson, issuer, pre-authorizedCode
Future<
    (
      OIDC4VCType?,
      OpenIdConfiguration?,
      OpenIdConfiguration?,
      dynamic,
      String?,
      String?,
    )> getIssuanceData({
  required String url,
  required DioClient client,
  required OIDC4VC oidc4vc,
  required OIDC4VCIDraftType oidc4vciDraftType,
}) async {
  final uri = Uri.parse(url);

  final keys = <String>[];
  uri.queryParameters.forEach((key, value) => keys.add(key));

  dynamic credentialOfferJson;
  String? issuer;
  String? preAuthorizedCode;

  if (keys.contains('credential_offer') ||
      keys.contains('credential_offer_uri')) {
    ///  issuance case 2
    credentialOfferJson = await getCredentialOfferJson(
      scannedResponse: uri.toString(),
      dioClient: client,
    );

    if (credentialOfferJson != null) {
      final dynamic preAuthorizedCodeGrant = credentialOfferJson['grants']
          ['urn:ietf:params:oauth:grant-type:pre-authorized_code'];

      if (preAuthorizedCodeGrant != null &&
          preAuthorizedCodeGrant is Map &&
          preAuthorizedCodeGrant.containsKey('pre-authorized_code')) {
        preAuthorizedCode =
            preAuthorizedCodeGrant['pre-authorized_code'] as String;
      }

      issuer = credentialOfferJson['credential_issuer'].toString();
    }
  }

  if (keys.contains('issuer')) {
    /// issuance case 1
    issuer = uri.queryParameters['issuer'].toString();

    /// preAuthorizedCode can be null
    preAuthorizedCode = uri.queryParameters['pre-authorized_code'];
  }

  if (issuer == null) {
    return (null, null, null, null, null, null);
  }

  final OpenIdConfiguration openIdConfiguration = await oidc4vc.getOpenIdConfig(
    baseUrl: issuer,
    isAuthorizationServer: false,
    oidc4vciDraftType: oidc4vciDraftType,
  );

  final authorizationServer = openIdConfiguration.authorizationServer;

  OpenIdConfiguration? authorizationServerConfiguration;

  if (authorizationServer != null) {
    authorizationServerConfiguration = await oidc4vc.getOpenIdConfig(
      baseUrl: authorizationServer,
      isAuthorizationServer: true,
      oidc4vciDraftType: oidc4vciDraftType,
    );
  }

  final credentialsSupported = openIdConfiguration.credentialsSupported;
  final credentialConfigurationsSupported =
      openIdConfiguration.credentialConfigurationsSupported;

  if (credentialsSupported == null &&
      credentialConfigurationsSupported == null) {
    throw ResponseMessage(
      data: {
        'error': 'invalid_request',
        'error_description': 'The credential supported is missing.',
      },
    );
  }

  CredentialsSupported? credSupported;

  if (credentialsSupported != null) {
    credSupported = credentialsSupported[0];
  }

  for (final oidc4vcType in OIDC4VCType.values) {
    if (oidc4vcType.isEnabled && url.startsWith(oidc4vcType.offerPrefix)) {
      if (oidc4vcType == OIDC4VCType.DEFAULT ||
          oidc4vcType == OIDC4VCType.EBSIV3) {
        if (credSupported?.trustFramework != null &&
            credSupported == credSupported?.trustFramework) {
          return (
            OIDC4VCType.DEFAULT,
            openIdConfiguration,
            authorizationServerConfiguration,
            credentialOfferJson,
            issuer,
            preAuthorizedCode,
          );
        }

        if (credSupported?.trustFramework?.name != null &&
            credSupported?.trustFramework?.name == 'ebsi') {
          return (
            OIDC4VCType.EBSIV3,
            openIdConfiguration,
            authorizationServerConfiguration,
            credentialOfferJson,
            issuer,
            preAuthorizedCode,
          );
        } else {
          return (
            OIDC4VCType.DEFAULT,
            openIdConfiguration,
            authorizationServerConfiguration,
            credentialOfferJson,
            issuer,
            preAuthorizedCode,
          );
        }
      }
      return (
        oidc4vcType,
        openIdConfiguration,
        authorizationServerConfiguration,
        credentialOfferJson,
        issuer,
        preAuthorizedCode,
      );
    }
  }

  return (
    null,
    openIdConfiguration,
    authorizationServerConfiguration,
    credentialOfferJson,
    issuer,
    preAuthorizedCode,
  );
}

Future<void> handleErrorForOID4VCI({
  required String url,
  required OpenIdConfiguration openIdConfiguration,
  required OpenIdConfiguration? authorizationServerConfiguration,
}) async {
  final authorizationServer = openIdConfiguration.authorizationServer;

  List<dynamic>? subjectSyntaxTypesSupported;
  String? tokenEndpoint;

  if (openIdConfiguration.subjectSyntaxTypesSupported != null) {
    subjectSyntaxTypesSupported =
        openIdConfiguration.subjectSyntaxTypesSupported;
  }

  if (openIdConfiguration.tokenEndpoint != null) {
    tokenEndpoint = openIdConfiguration.tokenEndpoint;
  }

  if (authorizationServer != null && authorizationServerConfiguration != null) {
    if (subjectSyntaxTypesSupported == null &&
        authorizationServerConfiguration.subjectSyntaxTypesSupported != null) {
      subjectSyntaxTypesSupported =
          authorizationServerConfiguration.subjectSyntaxTypesSupported;
    }

    if (tokenEndpoint == null &&
        authorizationServerConfiguration.tokenEndpoint != null) {
      tokenEndpoint = authorizationServerConfiguration.tokenEndpoint;
    }
  }

  if (authorizationServer != null && tokenEndpoint == null) {
    throw ResponseMessage(
      data: {
        'error': 'invalid_issuer_metadata',
        'error_description': 'The issuer configuration is invalid. '
            'The token_endpoint is missing.',
      },
    );
  }

  if (openIdConfiguration.credentialEndpoint == null) {
    throw ResponseMessage(
      data: {
        'error': 'invalid_issuer_metadata',
        'error_description': 'The issuer configuration is invalid. '
            'The credential_endpoint is missing.',
      },
    );
  }

  if (openIdConfiguration.credentialIssuer == null) {
    throw ResponseMessage(
      data: {
        'error': 'invalid_issuer_metadata',
        'error_description': 'The issuer configuration is invalid. '
            'The credential_issuer is missing.',
      },
    );
  }

  if (openIdConfiguration.credentialsSupported == null &&
      openIdConfiguration.credentialConfigurationsSupported == null) {
    throw ResponseMessage(
      data: {
        'error': 'invalid_issuer_metadata',
        'error_description': 'The issuer configuration is invalid. '
            'The credentials_supported is missing.',
      },
    );
  }

  if (subjectSyntaxTypesSupported != null &&
      !subjectSyntaxTypesSupported.contains('did:key')) {
    throw ResponseMessage(
      data: {
        'error': 'subject_syntax_type_not_supported',
        'error_description': 'The subject syntax type is not supported.',
      },
    );
  }
}

Future<Map<String, dynamic>?> getPresentationDefinition({
  required Uri uri,
  required DioClient client,
}) async {
  try {
    final keys = <String>[];
    uri.queryParameters.forEach((key, value) => keys.add(key));

    if (keys.contains('presentation_definition')) {
      final String presentationDefinitionValue =
          uri.queryParameters['presentation_definition'] ?? '';

      final json = jsonDecode(presentationDefinitionValue.replaceAll("'", '"'))
          as Map<String, dynamic>;

      return json;
    } else if (keys.contains('presentation_definition_uri')) {
      final presentationDefinitionUri =
          uri.queryParameters['presentation_definition_uri'].toString();
      final dynamic response = await client.get(presentationDefinitionUri);

      final Map<String, dynamic> data = response == String
          ? jsonDecode(response.toString()) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      return data;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<Map<String, dynamic>?> getClientMetada({
  required Uri uri,
  required DioClient client,
}) async {
  try {
    final keys = <String>[];
    uri.queryParameters.forEach((key, value) => keys.add(key));

    if (keys.contains('client_metadata')) {
      final String clientMetaDataValue =
          uri.queryParameters['client_metadata'] ?? '';

      final json = jsonDecode(clientMetaDataValue.replaceAll("'", '"'))
          as Map<String, dynamic>;

      return json;
    } else if (keys.contains('client_metadata_uri')) {
      final clientMetaDataUri =
          uri.queryParameters['client_metadata_uri'].toString();
      final dynamic response = await client.get(clientMetaDataUri);

      final Map<String, dynamic> data = response == String
          ? jsonDecode(response.toString()) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      return data;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<bool?> isEBSIV3ForVerifiers({
  required Uri uri,
  required OIDC4VC oidc4vc,
  required OIDC4VCIDraftType oidc4vciDraftType,
}) async {
  try {
    final String? clientId = uri.queryParameters['client_id'];

    if (clientId == null) return false;

    final isUrl = isURL(clientId);
    if (!isUrl) return false;

    final OpenIdConfiguration openIdConfiguration =
        await oidc4vc.getOpenIdConfig(
      baseUrl: clientId,
      isAuthorizationServer: false,
      oidc4vciDraftType: oidc4vciDraftType,
    );

    final subjectTrustFrameworksSupported =
        openIdConfiguration.subjectTrustFrameworksSupported;

    /// if subject_trust_frameworks_supported is not present => non-ebsi
    if (subjectTrustFrameworksSupported == null) {
      return false;
    }

    /// if subject_trust_frameworks_supported is empty => non-ebsi
    if (subjectTrustFrameworksSupported.isEmpty) {
      return false;
    }

    final profileType = subjectTrustFrameworksSupported[0].toString();

    if (profileType == 'ebsi') {
      /// if ebsi is available => ebsi
      return true;
    } else {
      /// if ebsi is not-available => non-ebsi
      return false;
    }
  } catch (e) {
    return null;
  }
}

String getCredentialData(dynamic credential) {
  late String cred;

  if (credential is String) {
    cred = credential;
  } else if (credential is Map<String, dynamic>) {
    final credentialSupported = (credential['types'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    cred = credentialSupported.last;
  } else {
    throw Exception();
  }

  return cred;
}

Future<String> getHost({
  required Uri uri,
  required DioClient client,
}) async {
  final keys = <String>[];
  uri.queryParameters.forEach((key, value) => keys.add(key));

  if (keys.contains('issuer')) {
    /// issuance case 1
    return Uri.parse(
      uri.queryParameters['issuer'].toString(),
    ).host;
  } else if (keys.contains('credential_offer') ||
      keys.contains('credential_offer_uri')) {
    ///  issuance case 2
    final dynamic credentialOfferJson = await getCredentialOfferJson(
      scannedResponse: uri.toString(),
      dioClient: client,
    );
    if (credentialOfferJson == null) throw Exception();

    return Uri.parse(
      credentialOfferJson['credential_issuer'].toString(),
    ).host;
  } else {
    /// verification case

    final String? requestUri = uri.queryParameters['request_uri'];

    /// check if request uri is provided or not
    if (requestUri != null) {
      final dynamic response = await client.get(requestUri);
      final Map<String, dynamic> decodedResponse = decodePayload(
        jwtDecode: JWTDecode(),
        token: response as String,
      );

      final redirectUri = decodedResponse['redirect_uri'];
      final responseUri = decodedResponse['response_uri'];

      if (redirectUri != null) {
        return Uri.parse(redirectUri.toString()).host;
      } else if (responseUri != null) {
        return Uri.parse(responseUri.toString()).host;
      }

      return '';
    } else {
      return '';
    }
  }
}

bool isURL(String input) {
  final bool uri = Uri.tryParse(input)?.hasAbsolutePath ?? false;
  return uri;
}

MessageHandler getMessageHandler(dynamic e) {
  if (e is MessageHandler) {
    return e;
  } else if (e is DioException) {
    final error = NetworkException.getDioException(error: e);

    return NetworkException(data: error.data);
  } else if (e is FormatException) {
    return ResponseMessage(
      data: {
        'error': 'unsupported_format',
        'error_description': '${e.message}\n\n${e.source}',
      },
    );
  } else if (e is TypeError) {
    return ResponseMessage(
      data: {
        'error': 'unsupported_format',
        'error_description': 'Some issue in the response from the server.',
      },
    );
  } else {
    final stringException = e.toString().replaceAll('Exception: ', '');
    if (stringException == 'CREDENTIAL_SUPPORT_DATA_ERROR') {
      return ResponseMessage(
        data: {
          'error': 'unsupported_credential_format',
          'error_description': 'The credential support format has some issues.',
        },
      );
    } else {
      return ResponseMessage(
        message:
            ResponseString.RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
      );
    }
  }
}

ResponseString getErrorResponseString(String errorString) {
  switch (errorString) {
    case 'invalid_request':
    case 'invalid_request_uri':
    case 'invalid_request_object':
      return ResponseString.RESPONSE_STRING_invalidRequest;

    case 'unauthorized_client':
    case 'access_denied':
    case 'invalid_or_missing_proof':
    case 'interaction_required':
      return ResponseString.RESPONSE_STRING_accessDenied;

    case 'unsupported_response_type':
    case 'invalid_scope':
    case 'request_not_supported':
    case 'request_uri_not_supported':
      return ResponseString.RESPONSE_STRING_thisRequestIsNotSupported;

    case 'unsupported_credential_type':
      return ResponseString.RESPONSE_STRING_unsupportedCredential;
    case 'login_required':
    case 'account_selection_required':
      return ResponseString.RESPONSE_STRING_aloginIsRequired;

    case 'consent_required':
      return ResponseString.RESPONSE_STRING_userConsentIsRequired;

    case 'registration_not_supported':
      return ResponseString.RESPONSE_STRING_theWalletIsNotRegistered;

    case 'invalid_grant':
    case 'invalid_client':
    case 'invalid_token':
      return ResponseString.RESPONSE_STRING_credentialIssuanceDenied;

    case 'unsupported_credential_format':
      return ResponseString.RESPONSE_STRING_thisCredentialFormatIsNotSupported;

    case 'unsupported_format':
      return ResponseString.RESPONSE_STRING_thisFormatIsNotSupported;

    case 'invalid_issuer_metadata':
      return ResponseString.RESPONSE_STRING_theCredentialOfferIsInvalid;

    case 'server_error':
      return ResponseString.RESPONSE_STRING_theServiceIsNotAvailable;

    case 'issuance_pending':
      return ResponseString
          .RESPONSE_STRING_theIssuanceOfThisCredentialIsPending;

    default:
      return ResponseString.RESPONSE_STRING_thisRequestIsNotSupported;
  }
}

bool isIDTokenOnly(String responseType) {
  return responseType.contains('id_token') &&
      !responseType.contains('vp_token');
}

bool isVPTokenOnly(String responseType) {
  return responseType.contains('vp_token') &&
      !responseType.contains('id_token');
}

bool isIDTokenAndVPToken(String responseType) {
  return responseType.contains('id_token') && responseType.contains('vp_token');
}

bool hasIDToken(String responseType) {
  return responseType.contains('id_token');
}

bool hasVPToken(String responseType) {
  return responseType.contains('vp_token');
}

bool hasIDTokenOrVPToken(String responseType) {
  return responseType.contains('id_token') || responseType.contains('vp_token');
}

String getFormattedStringOIDC4VCI({
  required String url,
  required String tokenEndpoint,
  required String credentialEndpoint,
  OpenIdConfiguration? openIdConfiguration,
  OpenIdConfiguration? authorizationServerConfiguration,
  dynamic credentialOfferJson,
}) {
  return '''
<b>SCHEME :</b> ${getSchemeFromUrl(url)}\n
<b>CREDENTIAL OFFER  :</b> 
${credentialOfferJson != null ? const JsonEncoder.withIndent('  ').convert(credentialOfferJson) : 'None'}\n
<b>ENDPOINTS :</b>
    authorization server endpoint : ${openIdConfiguration?.authorizationServer ?? 'None'}
    token endpoint : $tokenEndpoint}
    credential endpoint : $credentialEndpoint}
    deferred endpoint : ${openIdConfiguration?.deferredCredentialEndpoint ?? 'None'}
    batch endpoint : ${openIdConfiguration?.batchEndpoint ?? 'None'}\n
<b>CREDENTIAL SUPPORTED :</b> 
${openIdConfiguration?.credentialsSupported != null ? const JsonEncoder.withIndent('  ').convert(openIdConfiguration!.credentialsSupported) : 'None'}\n
<b>AUTHORIZATION SERVER CONFIGURATION :</b>
${authorizationServerConfiguration != null ? const JsonEncoder.withIndent('  ').convert(authorizationServerConfiguration) : 'None'}\n
<b>CRDENTIAL ISSUER CONFIGURATION :</b> 
${openIdConfiguration != null ? const JsonEncoder.withIndent('  ').convert(openIdConfiguration) : 'None'}
''';
}

String getFormattedTokenResponse({
  required Map<String, dynamic>? tokenData,
}) {
  return '''
<b>TOKEN RESPONSE :</b> 
${tokenData != null ? const JsonEncoder.withIndent('  ').convert(tokenData) : 'None'}\n
''';
}

String getFormattedCredentialResponse({
  required List<dynamic>? credentialData,
}) {
  return '''
<b>CREDENTIAL RESPONSE :</b>
${credentialData != null ? const JsonEncoder.withIndent('  ').convert(credentialData) : 'None'}\n
''';
}

Future<String> getFormattedStringOIDC4VPSIOPV2({
  required String url,
  required DioClient client,
  required Map<String, dynamic>? response,
}) async {
  final Map<String, dynamic>? presentationDefinition =
      await getPresentationDefinition(
    client: client,
    uri: Uri.parse(url),
  );

  final Map<String, dynamic>? clientMetaData = await getClientMetada(
    client: client,
    uri: Uri.parse(url),
  );

  final registration = Uri.parse(url).queryParameters['registration'];

  final registrationMap = registration != null
      ? jsonDecode(registration) as Map<String, dynamic>
      : null;

  final data = '''
<b>SCHEME :</b> ${getSchemeFromUrl(url)}\n
<b>AUTHORIZATION REQUEST :</b>
${response != null ? const JsonEncoder.withIndent('  ').convert(response) : 'None'}\n
<b>CLIENT METADATA  :</b>  
${clientMetaData != null ? const JsonEncoder.withIndent('  ').convert(clientMetaData) : 'None'}\n
<b>PRESENTATION DEFINITION  :</b> 
${presentationDefinition != null ? const JsonEncoder.withIndent('  ').convert(presentationDefinition) : 'None'}\n
<b>REGISTRATION  :</b> 
${registrationMap != null ? const JsonEncoder.withIndent('  ').convert(registrationMap) : 'None'}
''';

  return data;
}

String getSchemeFromUrl(String url) {
  final parts = url.split(':');
  return parts.length > 1 ? '${parts[0]}://' : '';
}

Future<dynamic> fetchRequestUriPayload({
  required String url,
  required DioClient client,
}) async {
  final log = getLogger('QRCodeScanCubit - fetchRequestUriPayload');
  late final dynamic data;

  try {
    final dynamic response = await client.get(url);
    data = response.toString();
  } catch (e, s) {
    log.e(
      'An error occurred while connecting to the server.',
      error: e,
      stackTrace: s,
    );
  }
  return data;
}

String getUpdatedUrlForSIOPV2OIC4VP({
  required Uri uri,
  required Map<String, dynamic> response,
}) {
  final responseType = response['response_type'];
  final redirectUri = response['redirect_uri'];
  final scope = response['scope'];
  final responseUri = response['response_uri'];
  final responseMode = response['response_mode'];
  final nonce = response['nonce'];
  final clientId = response['client_id'];
  final claims = response['claims'];
  final stateValue = response['state'];
  final presentationDefinition = response['presentation_definition'];
  final presentationDefinitionUri = response['presentation_definition_uri'];
  final registration = response['registration'];
  final clientMetadata = response['client_metadata'];
  final clientMetadataUri = response['client_metadata_uri'];

  final queryJson = <String, dynamic>{};

  if (!uri.queryParameters.containsKey('scope') && scope != null) {
    queryJson['scope'] = scope;
  }

  if (!uri.queryParameters.containsKey('client_id') && clientId != null) {
    queryJson['client_id'] = clientId;
  }

  if (!uri.queryParameters.containsKey('redirect_uri') && redirectUri != null) {
    queryJson['redirect_uri'] = redirectUri;
  }

  if (!uri.queryParameters.containsKey('response_uri') && responseUri != null) {
    queryJson['response_uri'] = responseUri;
  }

  if (!uri.queryParameters.containsKey('response_mode') &&
      responseMode != null) {
    queryJson['response_mode'] = responseMode;
  }

  if (!uri.queryParameters.containsKey('nonce') && nonce != null) {
    queryJson['nonce'] = nonce;
  }

  if (!uri.queryParameters.containsKey('state') && stateValue != null) {
    queryJson['state'] = stateValue;
  }

  if (!uri.queryParameters.containsKey('response_type') &&
      responseType != null) {
    queryJson['response_type'] = responseType;
  }

  if (!uri.queryParameters.containsKey('claims') && claims != null) {
    queryJson['claims'] = jsonEncode(claims).replaceAll('"', "'");
  }

  if (!uri.queryParameters.containsKey('presentation_definition') &&
      presentationDefinition != null) {
    queryJson['presentation_definition'] =
        jsonEncode(presentationDefinition).replaceAll('"', "'");
  }

  if (!uri.queryParameters.containsKey('presentation_definition_uri') &&
      presentationDefinitionUri != null) {
    queryJson['presentation_definition_uri'] = presentationDefinitionUri;
  }

  if (!uri.queryParameters.containsKey('registration') &&
      registration != null) {
    queryJson['registration'] =
        registration is Map ? jsonEncode(registration) : registration;
  }

  if (!uri.queryParameters.containsKey('client_metadata') &&
      clientMetadata != null) {
    queryJson['client_metadata'] =
        clientMetadata is Map ? jsonEncode(clientMetadata) : clientMetadata;
  }

  if (!uri.queryParameters.containsKey('client_metadata_uri') &&
      clientMetadataUri != null) {
    queryJson['client_metadata_uri'] = clientMetadataUri;
  }

  final String queryString = Uri(queryParameters: queryJson).query;

  final String newUrl = '$uri&$queryString';
  return newUrl;
}

bool supportCryptoCredential(ProfileModel profileModel) {
  final isEnterpriseProfile =
      profileModel.profileType == ProfileType.enterprise;

  if (isEnterpriseProfile &&
      !Parameters.supportCryptoAccountOwnershipInDiscoverForEnterpriseMode) {
    return false;
  }

  final profileSetting = profileModel.profileSetting;

  final customOidc4vcProfile =
      profileSetting.selfSovereignIdentityOptions.customOidc4vcProfile;

  /// suported VC format
  final supportCryptoCredentialByVCFormat =
      customOidc4vcProfile.vcFormatType.supportCryptoCredential;

  /// supported did key
  final supportCryptoCredentialByDidKey =
      customOidc4vcProfile.defaultDid.supportCryptoCredential;

  /// match format 1
  final matchFormat1 =
      supportCryptoCredentialByVCFormat && supportCryptoCredentialByDidKey;

  /// match format 2
  final matchFormat2 = customOidc4vcProfile.defaultDid == DidKeyType.edDSA &&
      customOidc4vcProfile.vcFormatType == VCFormatType.ldpVc &&
      !customOidc4vcProfile.cryptoHolderBinding;

  final supportAssociatedCredential = matchFormat1 || matchFormat2;

  return supportAssociatedCredential;
}

Future<(String?, String?, String?, String?)> getClientDetails({
  required ProfileCubit profileCubit,
  required bool isEBSIV3,
  required String issuer,
}) async {
  try {
    String? clientId;
    String? clientSecret;
    String? authorization;
    String? clientAssertion;

    final customOidc4vcProfile = profileCubit.state.model.profileSetting
        .selfSovereignIdentityOptions.customOidc4vcProfile;

    final didKeyType = customOidc4vcProfile.defaultDid;

    final privateKey = await fetchPrivateKey(
      profileCubit: profileCubit,
      isEBSIV3: isEBSIV3,
      didKeyType: didKeyType,
    );

    final (did, _) = await fetchDidAndKid(
      privateKey: privateKey,
      isEBSIV3: isEBSIV3,
      profileCubit: profileCubit,
      didKeyType: didKeyType,
    );

    final tokenParameters = TokenParameters(
      privateKey: jsonDecode(privateKey) as Map<String, dynamic>,
      did: '', // just added as it is required field
      mediaType: MediaType.basic, // just added as it is required field
      clientType:
          ClientType.jwkThumbprint, // just added as it is required field
      proofHeaderType: customOidc4vcProfile.proofHeader,
      clientId: '', // just added as it is required field
    );

    switch (customOidc4vcProfile.clientAuthentication) {
      ///  none
      case ClientAuthentication.none:
        break;

      case ClientAuthentication.clientSecretBasic:
        authorization = base64UrlEncode(utf8.encode('$clientId:$clientSecret'))
            .replaceAll('=', '');

        switch (customOidc4vcProfile.clientType) {
          case ClientType.jwkThumbprint:
            clientId = tokenParameters.thumbprint;
          case ClientType.did:
            clientId = did;
          case ClientType.confidential:
            clientId = customOidc4vcProfile.clientId;
        }

      ///  only clientId
      case ClientAuthentication.clientId:
        switch (customOidc4vcProfile.clientType) {
          case ClientType.jwkThumbprint:
            clientId = tokenParameters.thumbprint;
          case ClientType.did:
            clientId = did;
          case ClientType.confidential:
            clientId = customOidc4vcProfile.clientId;
        }

      case ClientAuthentication.clientSecretPost:
        clientSecret = customOidc4vcProfile.clientSecret;

      case ClientAuthentication.clientSecretJwt:
        if (profileCubit.state.model.walletType != WalletType.enterprise) {
          throw ResponseMessage(
            data: {
              'error': 'invalid_request',
              'error_description': 'Please switch to enterprise account',
            },
          );
        }

        final walletAttestationData = await profileCubit.secureStorageProvider
            .get(SecureStorageKeys.walletAttestationData);

        clientId = did;

        final iat = (DateTime.now().millisecondsSinceEpoch / 1000).round();
        final nbf = iat - 10;

        final payload = {
          'iss': clientId,
          'aud': issuer,
          'nbf': nbf,
          'exp': nbf + 60,
        };

        final jwtProofOfPossession = profileCubit.oidc4vc.generateToken(
          payload: payload,
          tokenParameters: tokenParameters,
          clientSecretJwt: true,
        );

        clientAssertion = '$walletAttestationData~$jwtProofOfPossession';
    }

    return (clientId, clientSecret, authorization, clientAssertion);
  } catch (e) {
    return (null, null, null, null);
  }
}

(Display?, dynamic) fetchDisplay({
  required OpenIdConfiguration openIdConfiguration,
  required String credentialType,
  required String languageCode,
}) {
  Display? display;
  dynamic credentialSupported;
  if (openIdConfiguration.credentialsSupported != null) {
    final credentialsSupported = openIdConfiguration.credentialsSupported!;
    final CredentialsSupported? credSupported =
        credentialsSupported.firstWhereOrNull(
      (CredentialsSupported credentialsSupported) =>
          credentialsSupported.id != null &&
          credentialsSupported.id == credentialType,
    );

    if (credSupported != null) {
      credentialSupported = credSupported.toJson();

      if (credSupported.display != null) {
        display = credSupported.display!.firstWhereOrNull(
          (Display display) => display.locale.toString().contains(languageCode),
        );

        display ??= credSupported.display!.firstWhereOrNull(
          (Display display) => display.locale.toString().contains('en'),
        );
      }
    }
  } else if (openIdConfiguration.credentialConfigurationsSupported != null) {
    final credentialsSupported =
        openIdConfiguration.credentialConfigurationsSupported;

    if ((credentialsSupported is Map<String, dynamic>) &&
        credentialsSupported.containsKey(credentialType)) {
      /// credentialSupported
      final credSupported = credentialsSupported[credentialType];

      credentialSupported = credSupported;

      if (credSupported is Map<String, dynamic>) {
        /// display
        if (credSupported.containsKey('display')) {
          final displayData = credSupported['display'];

          if (displayData is List<dynamic>) {
            final displays = displayData
                .map((ele) => Display.fromJson(ele as Map<String, dynamic>))
                .toList();

            display = displays.firstWhereOrNull(
              (Display display) =>
                  display.locale.toString().contains(languageCode),
            );

            display ??= displays.firstWhereOrNull(
              (Display display) => display.locale.toString().contains('en'),
            );
          }
        }
      }
    }
  }
  return (display, credentialSupported);
}
