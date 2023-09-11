// ignore_for_file: avoid_dynamic_calls, public_member_api_docs

import 'dart:convert';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip393;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:jose/jose.dart';
import 'package:json_path/json_path.dart';
import 'package:oidc4vc/src/iodc4vc_model.dart';
import 'package:oidc4vc/src/issuer_token_parameters.dart';
import 'package:oidc4vc/src/token_parameters.dart';
import 'package:oidc4vc/src/verification_type.dart';
import 'package:oidc4vc/src/verifier_token_parameters.dart';
import 'package:pkce/pkce.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:uuid/uuid.dart';

/// {@template ebsi}
/// EBSI wallet compliance
/// {@endtemplate}
class OIDC4VC {
  /// {@macro ebsi}
  OIDC4VC({required this.client, required this.oidc4vcModel});

  ///
  final Dio client;
  final OIDC4VCModel oidc4vcModel;

  /// create JWK from mnemonic
  Future<String> privateKeyFromMnemonic({
    required String mnemonic,
    required int indexValue,
  }) async {
    final seed = bip393.mnemonicToSeed(mnemonic);

    final rootKey = bip32.BIP32.fromSeed(seed); //Instance of 'BIP32'
    final child = rootKey.derivePath(
      "m/44'/5467'/0'/$indexValue'",
    ); //Instance of 'BIP32'
    final Iterable<int> iterable = child.privateKey!;
    final seedBytes = Uint8List.fromList(List.from(iterable));

    final key = jwkFromSeed(
      seedBytes: seedBytes,
    );

    return jsonEncode(key);
  }

  /// create JWK from seed
  Map<String, String> jwkFromSeed({required Uint8List seedBytes}) {
    // generate JWK for secp256k from bip39 mnemonic
    // see https://iancoleman.io/bip39/
    final epk = HEX.encode(seedBytes);
    final pk = PrivateKey.fromHex(epk); //Instance of 'PrivateKey'
    final pub = pk.publicKey.toHex().substring(2);
    final ad = HEX.decode(epk);
    final d = base64Url.encode(ad).substring(0, 43);
    // remove "=" padding 43/44
    final mx = pub.substring(0, 64);
    // first 32 bytes
    final ax = HEX.decode(mx);
    final x = base64Url.encode(ax).substring(0, 43);
    // remove "=" padding 43/44
    final my = pub.substring(64);
    // last 32 bytes
    final ay = HEX.decode(my);
    final y = base64Url.encode(ay).substring(0, 43);
    // ATTENTION !!!!!
    /// we were using P-256K for dart library conformance which is
    /// the same as secp256k1, but we are using secp256k1 now
    final jwk = {
      'crv': 'secp256k1',
      'd': d,
      'kty': 'EC',
      'x': x,
      'y': y,
    };
    return jwk;
  }

  /// https://www.rfc-editor.org/rfc/rfc7638
  /// Received JWT is already filtered on required members
  /// Received JWT keys are already sorted in lexicographic order

  /// getAuthorizationUriForIssuer
  Future<Uri> getAuthorizationUriForIssuer({
    required List<dynamic> selectedCredentials,
    required String clientId,
    required String webLink,
    required String schema,
    required String issuer,
    required String issuerState,
    required String nonce,
    String? options,
  }) async {
    try {
      final openidConfigurationResponse = await getOpenIdConfig(issuer);

      final authorizationEndpoint =
          await readAuthorizationEndPoint(openidConfigurationResponse);

      final authorizationRequestParemeters = getAuthorizationRequestParemeters(
        selectedCredentials: selectedCredentials,
        authorizationEndpoint:
            'https://app.altme.io/app/download/authorization',
        openidConfigurationResponse: openidConfigurationResponse,
        clientId: clientId,
        issuer: issuer,
        schema: schema,
        webLink: webLink,
        issuerState: issuerState,
        nonce: nonce,
        options: options,
      );

      final url = Uri.parse(authorizationEndpoint);
      final authorizationUri =
          Uri.https(url.authority, url.path, authorizationRequestParemeters);
      return authorizationUri;
    } catch (e) {
      throw Exception(e);
    }
  }

  @visibleForTesting
  Map<String, dynamic> getAuthorizationRequestParemeters({
    required List<dynamic> selectedCredentials,
    required String authorizationEndpoint,
    required String clientId,
    required String issuer,
    required String issuerState,
    required String nonce,
    required Map<String, dynamic> openidConfigurationResponse,
    required String webLink,
    required String schema,
    String? options,
  }) {
    //https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-successful-authorization-re

    final authorizationDetails = <dynamic>[];

    for (final credential in selectedCredentials) {
      late Map<String, dynamic> data;
      if (credential is String) {
        //
        final credentialsSupported =
            openidConfigurationResponse['credentials_supported']
                as List<dynamic>;

        dynamic credentailData;

        for (final dynamic credSupported in credentialsSupported) {
          if ((credSupported as Map<String, dynamic>)['id'].toString() ==
              credential) {
            credentailData = credSupported;
            break;
          }
        }

        if (credentailData == null) {
          throw Exception();
        }

        data = {
          'type': 'openid_credential',
          'locations': [issuer],
          'format': credentailData['format'],
          'types': credentailData['types'],
        };
      } else if (credential is Map<String, dynamic>) {
        data = {
          'type': 'openid_credential',
          'locations': [issuer],
          'format': credential['format'],
          'types': credential['types'],
        };
      } else {
        throw Exception();
      }

      authorizationDetails.add(data);
    }

    final pkcePair = PkcePair.generate();
    final codeChallenge = pkcePair.codeChallenge;
    final codeVerifier = pkcePair.codeVerifier;

    final myRequest = <String, dynamic>{
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri':
          '$webLink?uri=$schema&code_verifier=$codeVerifier&options=$options',
      'scope': 'openid',
      'issuer_state': issuerState,
      'state': const Uuid().v4(),
      'nonce': nonce,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'authorization_details': jsonEncode(authorizationDetails),
      'client_metadata': jsonEncode({
        'authorization_endpoint': authorizationEndpoint,
        'scopes_supported': ['openid'],
        'response_types_supported': ['vp_token', 'id_token'],
        'subject_types_supported': ['public'],
        'id_token_signing_alg_values_supported': ['ES256'],
        'request_object_signing_alg_values_supported': ['ES256'],
        'vp_formats_supported': {
          'jwt_vp': {
            'alg_values_supported': ['ES256'],
          },
          'jwt_vc': {
            'alg_values_supported': ['ES256'],
          },
        },
        'subject_syntax_types_supported': [
          'urn:ietf:params:oauth:jwk-thumbprint',
          'did🔑jwk_jcs-pub',
        ],
        'id_token_types_supported': ['subject_signed_id_token'],
      }),
    };
    return myRequest;
  }

  String? nonce;
  String? accessToken;
  List<dynamic>? authorizationDetails;

  /// Retreive credential_type from url
  Future<(List<dynamic>, String?, String)> getCredential({
    required String issuer,
    required dynamic credential,
    required String did,
    required String kid,
    required int indexValue,
    String? preAuthorizedCode,
    String? mnemonic,
    String? privateKey,
    String? userPin,
    String? code,
    String? codeVerifier,
  }) async {
    final tokenData = buildTokenData(
      preAuthorizedCode: preAuthorizedCode,
      userPin: userPin,
      code: code,
      codeVerifier: codeVerifier,
    );

    final openidConfigurationResponse = await getOpenIdConfig(issuer);

    final tokenEndPoint = await readTokenEndPoint(openidConfigurationResponse);

    if (nonce == null || accessToken == null) {
      final response = await getToken(tokenEndPoint, tokenData);
      nonce = response['c_nonce'] as String;
      accessToken = response['access_token'] as String;
      authorizationDetails =
          response['authorization_details'] as List<dynamic>?;
    }

    final private = await getPrivateKey(
      mnemonic: mnemonic,
      privateKey: privateKey,
      indexValue: indexValue,
    );

    final issuerTokenParameters = IssuerTokenParameters(
      private,
      did,
      kid,
      issuer,
    );

    if (nonce == null) throw Exception();

    String? deferredCredentialEndpoint;

    if (openidConfigurationResponse['deferred_credential_endpoint'] != null) {
      deferredCredentialEndpoint =
          openidConfigurationResponse['deferred_credential_endpoint']
              .toString();
    }

    final (credentialType, types, format) = await getCredentialData(
      openidConfigurationResponse: openidConfigurationResponse,
      credential: credential,
    );

    final credentialResponseData = <dynamic>[];

    if (authorizationDetails != null) {
      final dynamic authDetailForCredential = authorizationDetails!
          .where(
            (dynamic element) =>
                (element['types'] as List).contains(credentialType),
          )
          .firstOrNull;

      if (authDetailForCredential == null) throw Exception();

      final identifiers =
          (authDetailForCredential['identifiers'] as List<dynamic>)
              .map((dynamic element) => element.toString())
              .toList();

      for (final identifier in identifiers) {
        final credentialResponseDataValue = await getSingleCredential(
          issuerTokenParameters: issuerTokenParameters,
          openidConfigurationResponse: openidConfigurationResponse,
          credentialType: credentialType,
          types: types,
          format: format,
          identifier: identifier,
        );

        credentialResponseData.add(credentialResponseDataValue);
      }
//
    } else {
      final credentialResponseDataValue = await getSingleCredential(
        issuerTokenParameters: issuerTokenParameters,
        openidConfigurationResponse: openidConfigurationResponse,
        credentialType: credentialType,
        types: types,
        format: format,
      );

      credentialResponseData.add(credentialResponseDataValue);
    }

    return (credentialResponseData, deferredCredentialEndpoint, format);
  }

  Future<dynamic> getSingleCredential({
    required IssuerTokenParameters issuerTokenParameters,
    required Map<String, dynamic> openidConfigurationResponse,
    required String credentialType,
    required List<String> types,
    required String format,
    String? identifier,
  }) async {
    final credentialData = await buildCredentialData(
      nonce: nonce!,
      issuerTokenParameters: issuerTokenParameters,
      openidConfigurationResponse: openidConfigurationResponse,
      credentialType: credentialType,
      types: types,
      format: format,
      identifier: identifier,
    );

    /// sign proof

    final credentialEndpoint =
        readCredentialEndpoint(openidConfigurationResponse);

    if (accessToken == null) throw Exception();

    final credentialHeaders = buildCredentialHeaders(accessToken!);

    final dynamic credentialResponse = await client.post<dynamic>(
      credentialEndpoint,
      options: Options(headers: credentialHeaders),
      data: credentialData,
    );

    nonce = credentialResponse.data['c_nonce'].toString();

    return credentialResponse.data;
  }

  /// get Deferred credential from url
  Future<dynamic> getDeferredCredential({
    required String acceptanceToken,
    required String deferredCredentialEndpoint,
  }) async {
    final credentialHeaders = buildCredentialHeaders(acceptanceToken);

    final dynamic credentialResponse = await client.post<dynamic>(
      deferredCredentialEndpoint,
      options: Options(headers: credentialHeaders),
    );

    return credentialResponse.data;
  }

  void resetNonceAndAccessTokenAndAuthorizationDetails() {
    nonce = null;
    accessToken = null;
    authorizationDetails = null;
  }

  Map<String, dynamic> buildTokenData({
    String? preAuthorizedCode,
    String? userPin,
    String? code,
    String? codeVerifier,
  }) {
    late Map<String, dynamic> tokenData;

    if (preAuthorizedCode != null) {
      tokenData = <String, dynamic>{
        'pre-authorized_code': preAuthorizedCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:pre-authorized_code',
      };
    } else if (code != null && codeVerifier != null) {
      tokenData = <String, dynamic>{
        'code': code,
        'grant_type': 'authorization_code',
        'code_verifier': codeVerifier,
      };
    } else {
      throw Exception();
    }

    if (userPin != null) {
      tokenData['user_pin'] = userPin;
    }

    return tokenData;
  }

  Future<Response<Map<String, dynamic>>> getDidDocument(String didKey) async {
    try {
      final didDocument = await client.get<Map<String, dynamic>>(
        'https://unires:test@unires.talao.co/1.0/identifiers/$didKey',
      );
      return didDocument;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> readTokenEndPoint(
    Map<String, dynamic> openidConfigurationResponse,
  ) async {
    late String tokenEndPoint;

    final authorizationServer =
        openidConfigurationResponse['authorization_server'];
    if (authorizationServer != null) {
      final url = '$authorizationServer/.well-known/openid-configuration';
      final response = await client.get<dynamic>(url);

      tokenEndPoint = response.data['token_endpoint'] as String;
    } else {
      tokenEndPoint = openidConfigurationResponse['token_endpoint'] as String;
    }
    return tokenEndPoint;
  }

  Future<String> readAuthorizationEndPoint(
    Map<String, dynamic> openidConfigurationResponse,
  ) async {
    late String authorizationEndpoint;

    final authorizationServer =
        openidConfigurationResponse['authorization_server'];
    if (authorizationServer != null) {
      final url = '$authorizationServer/.well-known/openid-configuration';
      final response = await client.get<dynamic>(url);

      authorizationEndpoint = response.data['authorization_endpoint'] as String;
    } else {
      authorizationEndpoint =
          openidConfigurationResponse['authorization_endpoint'] as String;
    }
    return authorizationEndpoint;
  }

  String readIssuerDid(
    Response<Map<String, dynamic>> openidConfigurationResponse,
  ) {
    final jsonPath = JsonPath(r'$..issuer');

    final data = jsonPath.read(openidConfigurationResponse.data).first.value
        as Map<String, dynamic>;

    return data['id'] as String;
  }

  Map<String, dynamic> readPublicKeyJwk(
    String holderKid,
    Response<Map<String, dynamic>> didDocumentResponse,
  ) {
    final jsonPath = JsonPath(r'$..verificationMethod');
    final data = (jsonPath.read(didDocumentResponse.data).first.value as List)
        .where(
          (dynamic e) => e['id'].toString() == holderKid,
        )
        .toList();

    final value = data.first['publicKeyJwk'];

    return jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPrivateKey({
    required int indexValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    late Map<String, dynamic> private;

    if (mnemonic != null) {
      private = jsonDecode(
        await privateKeyFromMnemonic(
          mnemonic: mnemonic,
          indexValue: indexValue,
        ),
      ) as Map<String, dynamic>;
    } else {
      private = jsonDecode(privateKey!) as Map<String, dynamic>;
    }
    return private;
  }

  Future<Map<String, dynamic>> buildCredentialData({
    required String nonce,
    required IssuerTokenParameters issuerTokenParameters,
    required Map<String, dynamic> openidConfigurationResponse,
    required String credentialType,
    required List<String> types,
    required String format,
    String? identifier,
  }) async {
    final vcJwt = await getIssuerJwt(issuerTokenParameters, nonce);

    final credentialData = <String, dynamic>{
      'type': credentialType,
      'types': types,
      'format': format,
      'proof': {
        'proof_type': 'jwt',
        'jwt': vcJwt,
      },
    };

    if (identifier != null) {
      credentialData['identifier'] = identifier;
    }

    return credentialData;
  }

  Future<(String, List<String>, String)> getCredentialData({
    required Map<String, dynamic> openidConfigurationResponse,
    required dynamic credential,
  }) async {
    String? credentialType;
    List<String>? types;
    String? format;

    if (credential is String) {
      credentialType = credential;

      if (credentialType.startsWith('https://api.preprod.ebsi.eu')) {
        format = 'jwt_vc';
        types = [];
      } else {
        final jsonPath = JsonPath(r'$..credentials_supported');

        final credentialSupported =
            (jsonPath.read(openidConfigurationResponse).first.value as List)
                .where(
                  (dynamic e) => e['id'].toString() == credential,
                )
                .first as Map<String, dynamic>;
        types = (credentialSupported['types'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        format = credentialSupported['format'].toString();
      }
    } else if (credential is Map<String, dynamic>) {
      types = (credential['types'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      credentialType = types.last;
      format = credential['format'].toString();
    } else {
      throw Exception();
    }

    return (credentialType, types, format);
  }

  Future<VerificationType> verifyEncodedData({
    required String issuerDid,
    required String issuerKid,
    required String jwt,
  }) async {
    try {
      final didDocument = await getDidDocument(issuerDid);
      final publicKeyJwk = readPublicKeyJwk(issuerKid, didDocument);

      final kty = publicKeyJwk['kty'].toString();

      if (publicKeyJwk['crv'] == 'secp256k1') {
        publicKeyJwk['crv'] = 'P-256K';
      }

      late final bool isVerified;
      if (kty == 'OKP') {
        var xString = publicKeyJwk['x'].toString();
        final paddingLength = 4 - (xString.length % 4);
        xString += '=' * paddingLength;

        final publicKeyBytes = base64Url.decode(xString);

        final publicKey = cryptography.SimplePublicKey(
          publicKeyBytes,
          type: cryptography.KeyPairType.ed25519,
        );

        isVerified = await verifyJwt(jwt, publicKey);
      } else {
        final jws = JsonWebSignature.fromCompactSerialization(jwt);

        // create a JsonWebKey for verifying the signature
        final keyStore = JsonWebKeyStore()
          ..addKey(
            JsonWebKey.fromJson(publicKeyJwk),
          );

        isVerified = await jws.verify(keyStore);
      }

      if (isVerified) {
        return VerificationType.verified;
      } else {
        return VerificationType.notVerified;
      }
    } catch (e) {
      return VerificationType.unKnown;
    }
  }

  Future<bool> verifyJwt(
    String vcJwt,
    cryptography.SimplePublicKey publicKey,
  ) async {
    final parts = vcJwt.split('.');

    final header = parts[0];
    final payload = parts[1];

    final message = utf8.encode('$header.$payload');

    // Get the signature
    var signatureString = parts[2];
    final paddingLength = 4 - (signatureString.length % 4);
    signatureString += '=' * paddingLength;
    final signatureBytes = base64Url.decode(signatureString);

    final signature =
        cryptography.Signature(signatureBytes, publicKey: publicKey);

    //verify signature
    final result =
        await cryptography.Ed25519().verify(message, signature: signature);

    return result;
  }

  String readCredentialEndpoint(
    Map<String, dynamic> openidConfigurationResponse,
  ) {
    final jsonPathCredential = JsonPath(r'$..credential_endpoint');

    final credentialEndpoint = jsonPathCredential
        .readValues(openidConfigurationResponse)
        .first as String;
    return credentialEndpoint;
  }

  Map<String, dynamic> buildCredentialHeaders(String accessToken) {
    final credentialHeaders = <String, dynamic>{
      // 'Conformance': conformance,
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    return credentialHeaders;
  }

  @visibleForTesting
  Future<String> getIssuerJwt(
    IssuerTokenParameters tokenParameters,
    String nonce,
  ) async {
    final payload = {
      'iss': tokenParameters.did,
      'nonce': nonce,
      'iat': DateTime.now().microsecondsSinceEpoch,
      'aud': tokenParameters.issuer,
    };

    final jwt = generateToken(payload, tokenParameters);
    return jwt;
  }

  @visibleForTesting
  Future<dynamic> getToken(
    String tokenEndPoint,
    Map<String, dynamic> tokenData,
  ) async {
    try {
      /// getting token
      final tokenHeaders = <String, dynamic>{
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final dynamic tokenResponse = await client.post<Map<String, dynamic>>(
        tokenEndPoint,
        options: Options(headers: tokenHeaders),
        data: tokenData,
      );
      return tokenResponse.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendPresentation({
    required String clientId,
    required String redirectUrl,
    required String did,
    required String kid,
    required List<String> credentialsToBePresented,
    required String nonce,
    required bool isEBSIV2,
    required int indexValue,
    required String? stateValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    try {
      final private = await getPrivateKey(
        mnemonic: mnemonic,
        privateKey: privateKey,
        indexValue: indexValue,
      );

      final tokenParameters = VerifierTokenParameters(
        private,
        did,
        kid,
        clientId,
        credentialsToBePresented,
        nonce,
      );

      // structures
      final verifierIdToken = await getIdToken(
        tokenParameters: tokenParameters,
        isEBSIV2: isEBSIV2,
      );

      /// build vp token

      final vpToken = await getVpToken(tokenParameters);

      final responseHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final responseData = <String, dynamic>{
        'id_token': verifierIdToken,
        'vp_token': vpToken,
      };

      if (stateValue != null) {
        responseData['state'] = stateValue;
      }

      await client.post<dynamic>(
        redirectUrl,
        options: Options(headers: responseHeaders),
        data: responseData,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> extractVpToken({
    required String clientId,
    required String nonce,
    required List<String> credentialsToBePresented,
    required String did,
    required String kid,
    required int indexValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    try {
      final private = await getPrivateKey(
        mnemonic: mnemonic,
        privateKey: privateKey,
        indexValue: indexValue,
      );

      final tokenParameters = VerifierTokenParameters(
        private,
        did,
        kid,
        clientId,
        credentialsToBePresented,
        nonce,
      );

      final vpToken = await getVpToken(tokenParameters);

      return vpToken;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> extractIdToken({
    required String clientId,
    required List<String> credentialsToBePresented,
    required String did,
    required String kid,
    required String nonce,
    required bool isEBSIV2,
    required int indexValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    try {
      final private = await getPrivateKey(
        mnemonic: mnemonic,
        privateKey: privateKey,
        indexValue: indexValue,
      );

      final tokenParameters = VerifierTokenParameters(
        private,
        did,
        kid,
        clientId,
        credentialsToBePresented,
        nonce,
      );

      final verifierIdToken = await getIdToken(
        tokenParameters: tokenParameters,
        isEBSIV2: isEBSIV2,
      );

      return verifierIdToken;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> proveOwnershipOfDid({
    required String clientId,
    required String did,
    required String kid,
    required String redirectUri,
    required String nonce,
    required bool isEBSIV2,
    required int indexValue,
    required String? stateValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    try {
      final private = await getPrivateKey(
        mnemonic: mnemonic,
        privateKey: privateKey,
        indexValue: indexValue,
      );

      final tokenParameters = VerifierTokenParameters(
        private,
        did,
        kid,
        clientId,
        [],
        nonce,
      );

      // structures
      final verifierIdToken = await getIdToken(
        tokenParameters: tokenParameters,
        isEBSIV2: isEBSIV2,
      );

      final responseHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final responseData = <String, dynamic>{
        'id_token': verifierIdToken,
      };

      if (stateValue != null) {
        responseData['state'] = stateValue;
      }

      await client.post<dynamic>(
        redirectUri,
        options: Options(headers: responseHeaders),
        data: responseData,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @visibleForTesting
  Future<String> getVpToken(
    VerifierTokenParameters tokenParameters,
  ) async {
    final iat = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final vpTokenPayload = {
      'iat': iat,
      'jti': 'http://example.org/presentations/talao/01',
      'nbf': iat - 10,
      'aud': tokenParameters.audience,
      'exp': iat + 1000,
      'sub': tokenParameters.did,
      'iss': tokenParameters.did,
      'vp': {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'id': 'http://example.org/presentations/talao/01',
        'type': ['VerifiablePresentation'],
        'holder': tokenParameters.did,
        'verifiableCredential': tokenParameters.jsonIdOrJwtList,
      },
      'nonce': tokenParameters.nonce,
    };

    final verifierVpJwt = generateToken(vpTokenPayload, tokenParameters);

    return verifierVpJwt;
  }

  String generateToken(
    Map<String, Object> vpTokenPayload,
    TokenParameters tokenParameters,
  ) {
    final vpVerifierClaims = JsonWebTokenClaims.fromJson(vpTokenPayload);
    // create a builder, decoding the JWT in a JWS, so using a
    // JsonWebSignatureBuilder
    final privateKey = Map<String, dynamic>.from(tokenParameters.privateKey);

    if (tokenParameters.privateKey['crv'] == 'secp256k1') {
      privateKey['crv'] = 'P-256K';
    }

    final key = JsonWebKey.fromJson(privateKey);

    final vpBuilder = JsonWebSignatureBuilder()
      // set the content
      ..jsonContent = vpVerifierClaims.toJson()
      ..setProtectedHeader('typ', 'openid4vci-proof+jwt')
      ..setProtectedHeader('alg', tokenParameters.alg);

    if (oidc4vcModel.publicJWKNeeded) {
      // ignore: avoid_single_cascade_in_expression_statements
      vpBuilder..setProtectedHeader('jwk', tokenParameters.publicJWK);
    }

    vpBuilder
      ..setProtectedHeader('kid', tokenParameters.kid)

      // add a key to sign, can only add one for JWT
      ..addRecipient(key, algorithm: tokenParameters.alg);

    // build the jws
    final vpJws = vpBuilder.build();

    // output the compact serialization
    final verifierVpJwt = vpJws.toCompactSerialization();
    return verifierVpJwt;
  }

  @visibleForTesting
  Future<String> getIdToken({
    required VerifierTokenParameters tokenParameters,
    required bool isEBSIV2,
  }) async {
    final uuid1 = const Uuid().v4();
    final uuid2 = const Uuid().v4();

    /// build id token
    final payload = {
      'iat': DateTime.now().microsecondsSinceEpoch,
      'aud': tokenParameters.audience, // devrait être verifier
      'exp': DateTime.now().microsecondsSinceEpoch + 1000,
      'sub': tokenParameters.did,
      'iss': tokenParameters.did, //'https://self-issued.me/v2',
      'nonce': tokenParameters.nonce,
    };

    if (isEBSIV2) {
      payload['_vp_token'] = {
        'presentation_submission': {
          'definition_id': 'Altme defintion for EBSI project',
          'id': uuid1,
          'descriptor_map': [
            {
              'id': uuid2,
              'format': 'jwt_vp',
              'path': r'$',
            }
          ],
        },
      };
    }

    final verifierIdJwt = generateToken(payload, tokenParameters);
    return verifierIdJwt;
  }

  Future<String> getDidFromMnemonic({
    required String did,
    required String kid,
    required int indexValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    final private = await getPrivateKey(
      mnemonic: mnemonic,
      privateKey: privateKey,
      indexValue: indexValue,
    );

    final tokenParameters = TokenParameters(
      private,
      did,
      kid,
    );
    return tokenParameters.did;
  }

  Future<String?> getKid({
    required String did,
    required String kid,
    required int indexValue,
    String? mnemonic,
    String? privateKey,
  }) async {
    final private = await getPrivateKey(
      mnemonic: mnemonic,
      privateKey: privateKey,
      indexValue: indexValue,
    );

    final tokenParameters = TokenParameters(
      private,
      did,
      kid,
    );
    return tokenParameters.kid;
  }

  Future<Map<String, dynamic>> getOpenIdConfig(String baseUrl) async {
    final url = '$baseUrl/.well-known/openid-configuration';

    try {
      final response = await client.get<dynamic>(url);
      final data = response.data is String
          ? jsonDecode(response.data.toString()) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      if (e.toString().startsWith('Exception: Second_Attempt_Fail')) {
        throw Exception();
      } else {
        final data = await getOpenIdConfigSecondAttempt(baseUrl);
        return data;
      }
    }
  }

  Future<Map<String, dynamic>> getOpenIdConfigSecondAttempt(
    String baseUrl,
  ) async {
    final url = '$baseUrl/.well-known/openid-credential-issuer';

    try {
      final response = await client.get<dynamic>(url);
      final data = response.data is String
          ? jsonDecode(response.data.toString()) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      throw Exception();
    }
  }
}
