part of 'credentials_cubit.dart';

///helper function to generate Tezos/Ethereum AssociatedAddressCredential
Future<CredentialModel?> generateAssociatedWalletCredential({
  required CryptoAccountData cryptoAccountData,
  required DIDKitProvider didKitProvider,
  required BlockchainType blockchainType,
  required KeyGenerator keyGenerator,
  required String did,
  required CustomOidc4VcProfile customOidc4vcProfile,
  required OIDC4VC oidc4vc,
  required Map<String, dynamic> privateKey,
  String? oldId,
}) async {
  final log =
      getLogger('CredentialsCubit - generateAssociatedWalletCredential');
  log.i(blockchainType);
  try {
    late String didMethod;

    switch (blockchainType) {
      case BlockchainType.tezos:
        didMethod = AltMeStrings.cryptoTezosDIDMethod;

      case BlockchainType.ethereum:
      case BlockchainType.fantom:
      case BlockchainType.polygon:
      case BlockchainType.binance:
        didMethod = AltMeStrings.cryptoEVMDIDMethod;
    }

    final String jwkKey = await keyGenerator.jwkFromSecretKey(
      secretKey: cryptoAccountData.secretKey,
      accountType: blockchainType.accountType,
    );

    final issuer = didKitProvider.keyToDID(didMethod, jwkKey);
    log.i('didMethod - $didMethod');
    log.i('jwkKey - $jwkKey');
    log.i('didKitProvider.keyToDID - $issuer');

    //Issue: https://github.com/spruceid/didkit/issues/329
    // final verificationMethod =
    //     await didKitProvider.keyToVerificationMethod(didMethod, jwkKey);
    //log.i('didKitProvider.keyToVerificationMethod - $verificationMethod');

    late String verificationMethod;

    switch (blockchainType) {
      case BlockchainType.tezos:
        verificationMethod = '$issuer#blockchainAccountId';

      case BlockchainType.ethereum:
      case BlockchainType.fantom:
      case BlockchainType.polygon:
      case BlockchainType.binance:
        verificationMethod = '$issuer#Recovery2020';
    }
    log.i('hardcoded verificationMethod - $verificationMethod');

    final options = {
      'proofPurpose': 'assertionMethod',
      'verificationMethod': verificationMethod,
    };

    final verifyOptions = {'proofPurpose': 'assertionMethod'};
    final id = 'urn:uuid:${const Uuid().v4()}';
    final formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    final issuanceDate = '${formatter.format(DateTime.now())}Z';

    late dynamic associatedAddressCredential;

    switch (blockchainType) {
      case BlockchainType.tezos:
        associatedAddressCredential = TezosAssociatedAddressCredential(
          id: id,
          issuer: issuer,
          issuanceDate: issuanceDate,
          credentialSubjectModel: TezosAssociatedAddressModel(
            id: did,
            accountName: cryptoAccountData.name,
            associatedAddress: cryptoAccountData.walletAddress,
            type: 'TezosAssociatedAddress',
            issuedBy: const Author('My wallet'),
          ),
        );

      case BlockchainType.ethereum:
        associatedAddressCredential = EthereumAssociatedAddressCredential(
          id: id,
          issuer: issuer,
          issuanceDate: issuanceDate,
          credentialSubjectModel: EthereumAssociatedAddressModel(
            id: did,
            accountName: cryptoAccountData.name,
            associatedAddress: cryptoAccountData.walletAddress,
            type: 'EthereumAssociatedAddress',
            issuedBy: const Author('My wallet'),
          ),
        );

      case BlockchainType.fantom:
        associatedAddressCredential = FantomAssociatedAddressCredential(
          id: id,
          issuer: issuer,
          issuanceDate: issuanceDate,
          credentialSubjectModel: FantomAssociatedAddressModel(
            id: did,
            accountName: cryptoAccountData.name,
            associatedAddress: cryptoAccountData.walletAddress,
            type: 'FantomAssociatedAddress',
            issuedBy: const Author('My wallet'),
          ),
        );

      case BlockchainType.polygon:
        associatedAddressCredential = PolygonAssociatedAddressCredential(
          id: id,
          issuer: issuer,
          issuanceDate: issuanceDate,
          credentialSubjectModel: PolygonAssociatedAddressModel(
            id: did,
            accountName: cryptoAccountData.name,
            associatedAddress: cryptoAccountData.walletAddress,
            type: 'PolygonAssociatedAddress',
            issuedBy: const Author('My wallet'),
          ),
        );

      case BlockchainType.binance:
        associatedAddressCredential = BinanceAssociatedAddressCredential(
          id: id,
          issuer: issuer,
          issuanceDate: issuanceDate,
          credentialSubjectModel: BinanceAssociatedAddressModel(
            id: did,
            accountName: cryptoAccountData.name,
            associatedAddress: cryptoAccountData.walletAddress,
            type: 'BinanceAssociatedAddress',
            issuedBy: const Author('My wallet'),
          ),
        );
    }

    log.i(jsonEncode(associatedAddressCredential.toJson()));
    final String vc = await didKitProvider.issueCredential(
      jsonEncode(associatedAddressCredential.toJson()),
      jsonEncode(options),
      jwkKey,
    );

    log.i('didKitProvider.issueCredential - $vc');

    final result =
        await didKitProvider.verifyCredential(vc, jsonEncode(verifyOptions));
    log.i('didKitProvider.verifyCredential - $result');
    final jsonVerification = jsonDecode(result) as Map<String, dynamic>;

    if ((jsonVerification['warnings'] as List<dynamic>).isNotEmpty) {
      log.w(
        'credential verification return warnings',
        error: jsonVerification['warnings'],
      );
    }

    final credentialManifest = blockchainType.credentialManifest;

    if ((jsonVerification['errors'] as List<dynamic>).isNotEmpty) {
      log.e('failed to verify credential, ${jsonVerification['errors']}');
      if (jsonVerification['errors'][0] != 'No applicable proof') {
        throw ResponseMessage(
          message: ResponseString
              .RESPONSE_STRING_FAILED_TO_VERIFY_SELF_ISSUED_CREDENTIAL,
        );
      } else {
        return _createCredential(
          vc: vc,
          oldId: oldId,
          credentialManifest: credentialManifest,
          customOidc4vcProfile: customOidc4vcProfile,
          oidc4vc: oidc4vc,
          privateKey: privateKey,
          kid: verificationMethod,
          issuer: issuer,
        );
      }
    } else {
      return _createCredential(
        vc: vc,
        oldId: oldId,
        credentialManifest: credentialManifest,
        customOidc4vcProfile: customOidc4vcProfile,
        oidc4vc: oidc4vc,
        privateKey: privateKey,
        kid: verificationMethod,
        issuer: issuer,
      );
    }
  } catch (e, s) {
    log.e(
      'something went wrong e: $e, stackTrace: $s',
      error: e,
      stackTrace: s,
    );
    return null;
  }
}

Future<CredentialModel> _createCredential({
  required String vc,
  required CredentialManifest credentialManifest,
  required CustomOidc4VcProfile customOidc4vcProfile,
  required OIDC4VC oidc4vc,
  required Map<String, dynamic> privateKey,
  required String issuer,
  required String kid,
  String? oldId,
}) async {
  final jsonLd = jsonDecode(vc) as Map<String, dynamic>;

  String? jwt;
  DateTime dateTime = DateTime.now();

  if (customOidc4vcProfile.vcFormatType != VCFormatType.ldpVc) {
    /// id -> jti (optional)
    /// issuer -> iss (compulsary)
    /// issuanceDate -> iat (optional)
    /// expirationDate -> exp (optional)

    try {
      dateTime = DateTime.parse(jsonLd['issuanceDate'].toString());
    } catch (e) {
      dateTime = DateTime.now();
    }

    final iat = (dateTime.millisecondsSinceEpoch / 1000).round();

    final jsonContent = <String, dynamic>{
      'iat': iat,
      'exp': iat + 1000,
      'iss': jsonLd['issuer'],
      'jti': jsonLd['id'] ?? 'urn:uuid:${const Uuid().v4()}',
      'sub': issuer,
      'vc': jsonLd,
    };

    final tokenParameters = TokenParameters(
      privateKey: privateKey,
      did: issuer,
      kid: kid,
      mediaType: MediaType.basic,
      clientType: customOidc4vcProfile.clientType,
      proofHeaderType: customOidc4vcProfile.proofHeader,
      clientId: customOidc4vcProfile.clientId ?? '',
    );

    /// sign and get token
    jwt = oidc4vc.generateToken(
      payload: jsonContent,
      tokenParameters: tokenParameters,
    );
  }

  final id = oldId ?? 'urn:uuid:${const Uuid().v4()}';
  return CredentialModel(
    id: id,
    image: 'image',
    data: jsonLd,
    shareLink: '',
    jwt: jwt,
    format: customOidc4vcProfile.vcFormatType.value,
    credentialPreview: Credential.fromJson(jsonLd),
    credentialManifest: credentialManifest,
    activities: [Activity(acquisitionAt: dateTime)],
  );
}
