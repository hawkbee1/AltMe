import 'dart:convert';

import 'package:altme/app/app.dart';
import 'package:altme/credentials/credentials.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/dashboard/home/tab_bar/credentials/models/activity/activity.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oidc4vc/oidc4vc.dart';
import 'package:uuid/uuid.dart';

Future<void> addOIDC4VCCredential({
  required dynamic encodedCredentialFromOIDC4VC,
  required CredentialsCubit credentialsCubit,
  required BlockchainType blockchainType,
  required String credentialType,
  required bool isLastCall,
  required String format,
  required OpenIdConfiguration? openIdConfiguration,
  required JWTDecode jwtDecode,
  required QRCodeScanCubit qrCodeScanCubit,
  String? credentialIdToBeDeleted,
  String? issuer,
}) async {
  late Map<String, dynamic> credentialFromOIDC4VC;

  if (format == VCFormatType.jwtVc.vcValue ||
      format == VCFormatType.jwtVcJson.vcValue ||
      format == VCFormatType.vcSdJWT.vcValue ||
      format == VCFormatType.jwtVcJsonLd.vcValue) {
    //jwt_vc
    final data = encodedCredentialFromOIDC4VC['credential'] as String;

    final jsonContent = jwtDecode.parseJwt(data);

    if (format == VCFormatType.vcSdJWT.vcValue) {
      final sdAlg = jsonContent['_sd_alg'] ?? 'sha-256';

      if (sdAlg != 'sha-256') {
        throw ResponseMessage(
          data: {
            'error': 'invalid_request',
            'error_description': 'Only sha-256 is supported.',
          },
        );
      }

      credentialFromOIDC4VC = jsonContent;
    } else {
      credentialFromOIDC4VC = jsonContent['vc'] as Map<String, dynamic>;
    }

    if (format == VCFormatType.vcSdJWT.vcValue) {
      /// type
      if (!credentialFromOIDC4VC.containsKey('type')) {
        credentialFromOIDC4VC['type'] = [credentialType];
      }

      ///credentialSubject
      if (!credentialFromOIDC4VC.containsKey('credentialSubject')) {
        credentialFromOIDC4VC['credentialSubject'] = {'type': credentialType};
      }
    }

    /// id -> jti
    if (!credentialFromOIDC4VC.containsKey('id')) {
      if (jsonContent.containsKey('jti')) {
        credentialFromOIDC4VC['id'] = jsonContent['jti'];
      } else {
        credentialFromOIDC4VC['id'] = 'urn:uuid:${const Uuid().v4()}';
      }
    }

    /// issuer -> iss
    if (!credentialFromOIDC4VC.containsKey('issuer')) {
      if (jsonContent.containsKey('iss')) {
        credentialFromOIDC4VC['issuer'] = jsonContent['iss'];
      } else {
        throw ResponseMessage(
          data: {
            'error': 'unsupported_format',
            'error_description': 'Issuer is missing',
          },
        );
      }
    }

    /// issuanceDate -> iat
    if (!credentialFromOIDC4VC.containsKey('issuanceDate')) {
      if (jsonContent.containsKey('iat')) {
        credentialFromOIDC4VC['issuanceDate'] = jsonContent['iat'].toString();
      } else if (jsonContent.containsKey('issuanceDate')) {
        credentialFromOIDC4VC['issuanceDate'] =
            jsonContent['issuanceDate'].toString();
      }
    }

    /// expirationDate -> exp
    if (!credentialFromOIDC4VC.containsKey('expirationDate')) {
      if (jsonContent.containsKey('exp')) {
        credentialFromOIDC4VC['expirationDate'] = jsonContent['exp'].toString();
      } else if (jsonContent.containsKey('expirationDate')) {
        credentialFromOIDC4VC['expirationDate'] =
            jsonContent['expirationDate'].toString();
      }
    }

    /// cred,tailSubject.id -> sub

    // if (newCredential['id'] == null) {
    //   newCredential['id'] = 'urn:uuid:${const Uuid().v4()}';
    // }

    // if (newCredential['credentialPreview']['id'] == null) {
    //   newCredential['credentialPreview']['id'] =
    //       'urn:uuid:${const Uuid().v4()}';
    // }

    credentialFromOIDC4VC['jwt'] = data;
  } else if (format == VCFormatType.ldpVc.vcValue) {
    //ldp_vc

    final data = encodedCredentialFromOIDC4VC['credential'];

    credentialFromOIDC4VC = data is Map<String, dynamic>
        ? data
        : jsonDecode(encodedCredentialFromOIDC4VC['credential'].toString())
            as Map<String, dynamic>;
  } else {
    throw ResponseMessage(
      data: {
        'error': 'invalid_format',
        'error_description': 'The format of vc is incorrect.',
      },
    );
  }

  final Map<String, dynamic> newCredential =
      Map<String, dynamic>.from(credentialFromOIDC4VC);

  newCredential['format'] = format;
  newCredential['credentialPreview'] = credentialFromOIDC4VC;

  // if(newCredential['credentialPreview']['credentialSubject']['type']==null) {
  //   /// added id as type to recognise the card
  //   /// for ebsiv2 only
  //   newCredential['credentialPreview']['credentialSubject']['type'] =
  //       credentialFromOIDC4VC['credentialSchema']['id'];
  // }

  if (openIdConfiguration != null) {
    final openidConfigurationJson =
        jsonDecode(jsonEncode(openIdConfiguration)) as Map<String, dynamic>;
    final CredentialManifest? credentialManifest = await getCredentialManifest(
      openidConfigurationJson: openidConfigurationJson,
      credentialType: credentialType,
    );

    if (credentialManifest?.outputDescriptors?.isNotEmpty ?? false) {
      newCredential['credential_manifest'] = CredentialManifest(
        credentialManifest!.id,
        credentialManifest.issuedBy,
        credentialManifest.outputDescriptors,
        credentialManifest.presentationDefinition,
      ).toJson();
    }
  }

  Display? display;

  if (openIdConfiguration != null) {
    final (Display? displayData, dynamic credentialSupported) = fetchDisplay(
      openIdConfiguration: openIdConfiguration,
      credentialType: credentialType,
      languageCode:
          credentialsCubit.profileCubit.langCubit.state.locale.languageCode,
    );
    display = displayData;
    newCredential['credentialSupported'] = credentialSupported;
  }

  final newCredentialModel = CredentialModel.fromJson(newCredential);

  final credentialModel = CredentialModel.copyWithData(
    oldCredentialModel: newCredentialModel,
    newData: credentialFromOIDC4VC,
    activities: [Activity(acquisitionAt: DateTime.now())],
    display: display,
  );

  if (credentialIdToBeDeleted != null) {
    ///delete pending dummy credential
    await credentialsCubit.deleteById(
      id: credentialIdToBeDeleted,
      showMessage: false,
      blockchainType: blockchainType,
    );
  }

  // insert the credential in the wallet
  await credentialsCubit.insertCredential(
    credential: credentialModel,
    showStatus: false,
    showMessage: isLastCall,
    blockchainType: blockchainType,
    qrCodeScanCubit: qrCodeScanCubit,
  );
}
