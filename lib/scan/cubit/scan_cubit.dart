import 'dart:convert';

import 'package:altme/app/app.dart';
import 'package:altme/credentials/cubit/credentials_cubit.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/dashboard/home/tab_bar/credentials/models/activity/activity.dart';
import 'package:altme/did/did.dart';

import 'package:bloc/bloc.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:did_kit/did_kit.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oidc4vc/oidc4vc.dart';

import 'package:secure_storage/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

part 'scan_cubit.g.dart';
part 'scan_state.dart';

/// VC = Verifibale Credential : signed and issued by issuer
/// VP = Verifiable Presentation = VC + wallet signature
/// VP is what you trasnfer to Verifier in the Presentation Request prootocol

/// the issuer signs and sends a VC to the wallet
///the wallet stores the VC
/// If needed the wallet builds a VP with the VC and sends it to a Verifier

/// In LinkedIn case the VP is embedded in the QR code, not sent to the verifier

class ScanCubit extends Cubit<ScanState> {
  ScanCubit({
    required this.client,
    required this.credentialsCubit,
    required this.didKitProvider,
    required this.secureStorageProvider,
    required this.profileCubit,
    required this.didCubit,
    required this.oidc4vc,
  }) : super(const ScanState());

  final DioClient client;
  final CredentialsCubit credentialsCubit;
  final DIDKitProvider didKitProvider;
  final SecureStorageProvider secureStorageProvider;
  final ProfileCubit profileCubit;
  final DIDCubit didCubit;
  final OIDC4VC oidc4vc;

  Future<void> credentialOfferOrPresent({
    required Uri uri,
    required CredentialModel credentialModel,
    required String keyId,
    required List<CredentialModel>? credentialsToBePresented,
    required Issuer issuer,
    QRCodeScanCubit? qrCodeScanCubit,
  }) async {
    emit(state.loading());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final log = getLogger('ScanCubit - credentialOffer');

    try {
      if (isSIOPV2OROIDC4VPUrl(uri)) {
        // final bool isEBSIV3 =
        //     await isEBSIV3ForVerifier(client: client, uri: uri) ?? false;

        final privateKey = await fetchPrivateKey(
          oidc4vc: oidc4vc,
          secureStorage: secureStorageProvider,
        );

        final (did, kid) = await fetchDidAndKid(
          privateKey: privateKey,
          didKitProvider: didKitProvider,
          secureStorage: secureStorageProvider,
        );

        final responseType = uri.queryParameters['response_type'] ?? '';
        final stateValue = uri.queryParameters['state'];

        if (isIDTokenOnly(responseType)) {
          /// verifier side (siopv2) with request uri as value
          throw Exception();
        } else if (isVPTokenOnly(responseType)) {
          /// verifier side (oidc4vp) with request uri as value

          await presentCredentialToOIDC4VPAndSIOPV2Request(
            uri: uri,
            issuer: issuer,
            credentialsToBePresented: credentialsToBePresented!,
            presentationDefinition:
                credentialModel.credentialManifest!.presentationDefinition!,
            oidc4vc: oidc4vc,
            did: did,
            kid: kid,
            privateKey: privateKey,
            stateValue: stateValue,
            idTokenNeeded: false,
            qrCodeScanCubit: qrCodeScanCubit!,
          );
          return;
        } else if (isIDTokenAndVPToken(responseType)) {
          /// verifier side (oidc4vp and siopv2) with request uri as value

          await presentCredentialToOIDC4VPAndSIOPV2Request(
            uri: uri,
            issuer: issuer,
            credentialsToBePresented: credentialsToBePresented!,
            presentationDefinition:
                credentialModel.credentialManifest!.presentationDefinition!,
            oidc4vc: oidc4vc,
            did: did,
            kid: kid,
            privateKey: privateKey,
            stateValue: stateValue,
            idTokenNeeded: true,
            qrCodeScanCubit: qrCodeScanCubit!,
          );

          return;
        } else {
          throw Exception();
        }
      } else {
        final did = (await secureStorageProvider.get(SecureStorageKeys.did))!;

        /// If credential manifest exist we follow instructions to present
        /// credential
        /// If credential manifest doesn't exist we add DIDAuth to the post
        /// If id was in preview we send it in the post
        ///  https://github.com/TalaoDAO/wallet-interaction/blob/main/README.md#credential-offer-protocol
        ///
        final key = (await secureStorageProvider.get(keyId))!;
        final verificationMethod = await secureStorageProvider
            .get(SecureStorageKeys.verificationMethod);

        List<String> presentations = <String>[];
        if (credentialsToBePresented == null) {
          final options = <String, dynamic>{
            'verificationMethod': verificationMethod,
            'proofPurpose': 'authentication',
            'challenge': credentialModel.challenge ?? '',
            'domain': credentialModel.domain ?? '',
          };

          final presentation = await didKitProvider.didAuth(
            did,
            jsonEncode(options),
            key,
          );

          presentations = List.of(presentations)..add(presentation);
        } else {
          for (final item in credentialsToBePresented) {
            final presentationId = 'urn:uuid:${const Uuid().v4()}';

            final presentation = await didKitProvider.issuePresentation(
              jsonEncode({
                '@context': ['https://www.w3.org/2018/credentials/v1'],
                'type': ['VerifiablePresentation'],
                'id': presentationId,
                'holder': did,
                'verifiableCredential': item.data,
              }),
              jsonEncode({
                'verificationMethod': verificationMethod,
                'proofPurpose': 'assertionMethod',
                'challenge': credentialModel.challenge,
                'domain': credentialModel.domain,
              }),
              key,
            );
            presentations = List.of(presentations)..add(presentation);
          }
        }

        log.i('presentations - $presentations');

        FormData data;
        if (credentialModel.receivedId == null) {
          data = FormData.fromMap(<String, dynamic>{
            'subject_id': did,
            'presentation': presentations.length > 1
                ? jsonEncode(presentations)
                : presentations,
          });
        } else {
          data = FormData.fromMap(<String, dynamic>{
            'id': credentialModel.receivedId,
            'subject_id': did,
            'presentation': presentations.length > 1
                ? jsonEncode(presentations)
                : presentations,
          });
        }

        final dynamic credential = await client.post(
          uri.toString(),
          data: data,
        );

        final dynamic jsonCredential =
            credential is String ? jsonDecode(credential) : credential;

        if (credentialModel.jwt == null) {
          /// not verifying credential for did:ebsi and did:web issuer
          log.i('verifying Credential');

          final vcStr = jsonEncode(jsonCredential);
          final optStr = jsonEncode({'proofPurpose': 'assertionMethod'});

          await Future<void>.delayed(const Duration(milliseconds: 500));
          final verification =
              await didKitProvider.verifyCredential(vcStr, optStr);

          log.i('[wallet/credential-offer/verify/vc] $vcStr');
          log.i('[wallet/credential-offer/verify/options] $optStr');
          log.i('[wallet/credential-offer/verify/result] $verification');

          final jsonVerification =
              jsonDecode(verification) as Map<String, dynamic>;

          if ((jsonVerification['warnings'] as List).isNotEmpty) {
            log.w(
              'credential verification return warnings',
              error: jsonVerification['warnings'],
            );

            emit(
              state.warning(
                messageHandler: ResponseMessage(
                  message: ResponseString
                      .RESPONSE_STRING_CREDENTIAL_VERIFICATION_RETURN_WARNING,
                ),
              ),
            );
          }

          if ((jsonVerification['errors'] as List).isNotEmpty) {
            log.w(
              'failed to verify credential',
              error: jsonVerification['errors'],
            );
            if (jsonVerification['errors'][0] != 'No applicable proof') {
              throw ResponseMessage(
                message:
                    ResponseString.RESPONSE_STRING_FAILED_TO_VERIFY_CREDENTIAL,
              );
            }
          }
        }

        final List<Activity> activities =
            List<Activity>.of(credentialModel.activities)
              ..add(Activity(acquisitionAt: DateTime.now()));

        CredentialManifest? credentialManifest;

        await credentialsCubit.insertCredential(
          credential: CredentialModel.copyWithData(
            oldCredentialModel: credentialModel,
            newData: jsonCredential as Map<String, dynamic>,
            activities: activities,
            credentialManifest: credentialManifest,
          ),
        );

        if (credentialsToBePresented != null) {
          await presentationActivity(
            credentialModels: credentialsToBePresented,
            issuer: issuer,
          );
        }
        emit(state.copyWith(status: ScanStatus.success));
      }
    } catch (e) {
      log.e('something went wrong - $e');
      if (e is NetworkException &&
          e.message == NetworkError.NETWORK_ERROR_PRECONDITION_FAILED) {
        emitError(
          ResponseMessage(
            message: ResponseString.RESPONSE_STRING_userNotFitErrorMessage,
            data: e.data?.toString(),
          ),
        );
      } else {
        emitError(e);
      }
    }
  }

  Future<void> verifiablePresentationRequest({
    required String url,
    required String keyId,
    required List<CredentialModel> credentialsToBePresented,
    required String challenge,
    required String domain,
    required Issuer issuer,
  }) async {
    final log = getLogger('ScanCubit - verifiablePresentationRequest');

    emit(state.loading());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    try {
      final key = (await secureStorageProvider.get(keyId))!;
      final did = await secureStorageProvider.get(SecureStorageKeys.did);
      final verificationMethod =
          await secureStorageProvider.get(SecureStorageKeys.verificationMethod);

      final presentationId = 'urn:uuid:${const Uuid().v4()}';
      final presentation = await didKitProvider.issuePresentation(
        jsonEncode({
          '@context': ['https://www.w3.org/2018/credentials/v1'],
          'type': ['VerifiablePresentation'],
          'id': presentationId,
          'holder': did,
          'verifiableCredential': credentialsToBePresented.length == 1
              ? credentialsToBePresented.first.data
              : credentialsToBePresented.map((c) => c.data).toList(),
        }),
        jsonEncode({
          'verificationMethod': verificationMethod,
          'proofPurpose': 'authentication',
          'challenge': challenge,
          'domain': domain,
        }),
        key,
      );

      log.i('presentation $presentation');

      final FormData formData = FormData.fromMap(<String, dynamic>{
        'presentation': presentation,
      });

      final result = await client.post(url, data: formData);

      await presentationActivity(
        credentialModels: credentialsToBePresented,
        issuer: issuer,
      );

      String? responseMessage;
      if (result is String?) {
        responseMessage = result;
      }
      emit(
        state.copyWith(
          status: ScanStatus.success,
          message: StateMessage.success(
            stringMessage: responseMessage,
            messageHandler: responseMessage != null
                ? null
                : ResponseMessage(
                    message: ResponseString
                        .RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_CREDENTIAL,
                  ),
          ),
        ),
      );
    } catch (e) {
      emitError(e);
    }
  }

  void emitError(dynamic e) {
    final messageHandler = getMessageHandler(e);

    emit(
      state.error(
        message: StateMessage.error(
          messageHandler: messageHandler,
          showDialog: true,
        ),
      ),
    );
  }

  Future<void> getDIDAuthCHAPI({
    required Uri uri,
    required String keyId,
    required dynamic Function(String) done,
    required String challenge,
    required String domain,
  }) async {
    final log = getLogger('ScanCubit - getDIDAuthCHAPI');

    emit(state.loading());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    try {
      final key = (await secureStorageProvider.get(keyId))!;
      final did = await secureStorageProvider.get(SecureStorageKeys.did);
      final verificationMethod =
          await secureStorageProvider.get(SecureStorageKeys.verificationMethod);

      if (did != null) {
        final presentation = await didKitProvider.didAuth(
          did,
          jsonEncode({
            'verificationMethod': verificationMethod,
            'proofPurpose': 'authentication',
            'challenge': challenge,
            'domain': domain,
          }),
          key,
        );
        final dynamic credential = await client.post(
          uri.toString(),
          data: FormData.fromMap(<String, dynamic>{
            'presentation': presentation,
          }),
        );
        if (credential == 'ok') {
          done(presentation);

          emit(
            state.copyWith(
              status: ScanStatus.success,
              message: StateMessage.success(
                messageHandler: ResponseMessage(
                  message: ResponseString
                      .RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_CREDENTIAL,
                ),
              ),
            ),
          );
        } else {
          throw ResponseMessage(
            message: ResponseString
                .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
          );
        }
      } else {
        throw Exception('DID is not set. It is required to present DIDAuth');
      }
    } catch (e, s) {
      log.e('something went wrong', error: e, stackTrace: s);
      emitError(e);
    }
  }

  Future<dynamic> presentCredentialToOIDC4VPAndSIOPV2Request({
    required List<CredentialModel> credentialsToBePresented,
    required PresentationDefinition presentationDefinition,
    required Issuer issuer,
    required OIDC4VC oidc4vc,
    required String privateKey,
    required String did,
    required String kid,
    required Uri uri,
    required String? stateValue,
    required bool idTokenNeeded,
    required QRCodeScanCubit qrCodeScanCubit,
  }) async {
    final log =
        getLogger('ScanCubit - presentCredentialToOIDC4VPAndSIOPV2Request');
    emit(state.loading());
    await Future<void>.delayed(const Duration(milliseconds: 500));

    try {
      final String responseOrRedirectUri =
          uri.queryParameters['redirect_uri'] ??
              uri.queryParameters['response_uri']!;

      String? idToken;

      if (idTokenNeeded) {
        idToken = await createIdToken(
          credentialsToBePresented: credentialsToBePresented,
          did: did,
          kid: kid,
          oidc4vc: oidc4vc,
          privateKey: privateKey,
          uri: uri,
        );
      }

      final String vpToken = await createVpToken(
        credentialsToBePresented: credentialsToBePresented,
        did: did,
        kid: kid,
        oidc4vc: oidc4vc,
        presentationDefinition: presentationDefinition,
        privateKey: privateKey,
        uri: uri,
      );

      final presentationSubmissionString = getPresentationSubmission(
        credentialsToBePresented: credentialsToBePresented,
        presentationDefinition: presentationDefinition,
      );

      final responseData = <String, dynamic>{
        'vp_token': vpToken,
        'presentation_submission': presentationSubmissionString,
      };

      if (idTokenNeeded && idToken != null) {
        responseData['id_token'] = idToken;
      }

      if (stateValue != null) {
        responseData['state'] = stateValue;
      }

      final response = await client.dio.post<dynamic>(
        responseOrRedirectUri,
        data: responseData,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 400;
          },
        ),
      );

      if (response.statusCode == 200) {
        await presentationActivity(
          credentialModels: credentialsToBePresented,
          issuer: issuer,
        );
        emit(
          state.copyWith(
            status: ScanStatus.success,
            message: StateMessage.success(
              messageHandler: ResponseMessage(
                message: ResponseString
                    .RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_CREDENTIAL,
              ),
            ),
          ),
        );
        final data = response.data;
        if (data is Map) {
          String url = '';
          if (data.containsKey('redirect_uri')) {
            url = data['redirect_uri'].toString();
          }
          if (url.isNotEmpty && data.containsKey('response_code')) {
            url = '$url?response_code=${data['response_code']}';
          }
          if (url.isNotEmpty) {
            await LaunchUrl.launch(
              url,
              launchMode: LaunchMode.inAppWebView,
            );
          }
        }
      } else if (response.statusCode == 302) {
        await presentationActivity(
          credentialModels: credentialsToBePresented,
          issuer: issuer,
        );

        String? url;

        if (response.headers.map.containsKey('location') &&
            response.headers.map['location'] != null &&
            response.headers.map['location'] is List<dynamic> &&
            (response.headers.map['location']!).isNotEmpty) {
          url = response.headers.map['location']![0];
        }

        if (url != null) {
          final uri = Uri.parse(url);
          if (uri.toString().startsWith(Parameters.oidc4vcUniversalLink)) {
            emit(state.copyWith(status: ScanStatus.goBack));
            await qrCodeScanCubit.authorizedFlowStart(uri);
            return;
          }
        } else {
          throw ResponseMessage(
            message: ResponseString.RESPONSE_STRING_thisRequestIsNotSupported,
          );
        }
      } else {
        throw ResponseMessage(
          message: ResponseString
              .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
        );
      }
    } catch (e, s) {
      log.e('something went wrong - $e', error: e, stackTrace: s);
      emitError(e);
    }
  }

  String getPresentationSubmission({
    required List<CredentialModel> credentialsToBePresented,
    required PresentationDefinition presentationDefinition,
  }) {
    final uuid1 = const Uuid().v4();

    final Map<String, dynamic> presentationSubmission = {
      'id': uuid1,
      'definition_id': presentationDefinition.id,
    };

    final inputDescriptors = <Map<String, dynamic>>[];

    final ldpVc = presentationDefinition.format?.ldpVc != null;
    final jwtVc = presentationDefinition.format?.jwtVc != null;

    String? vcFormat;

    if (ldpVc) {
      vcFormat = 'ldp_vc';
    } else if (jwtVc) {
      vcFormat = 'jwt_vc';
    } else {
      throw Exception();
    }

    final ldpVp = presentationDefinition.format?.ldpVp != null;
    final jwtVp = presentationDefinition.format?.jwtVp != null;

    String? vpFormat;

    if (ldpVp) {
      vpFormat = 'ldp_vp';
    } else if (jwtVp) {
      vpFormat = 'jwt_vp';
    } else {
      throw Exception();
    }

    if (credentialsToBePresented.length == 1) {
      late InputDescriptor descriptor;

      for (final InputDescriptor inputDescriptor
          in presentationDefinition.inputDescriptors) {
        for (final Field field in inputDescriptor.constraints!.fields!) {
          final credentialName =
              field.filter!.pattern ?? field.filter!.contains!.containsConst;
          if (credentialsToBePresented[0]
              .credentialPreview
              .type
              .contains(credentialName)) {
            descriptor = inputDescriptor;
          }
        }
      }

      inputDescriptors.add({
        'id': descriptor.id,
        'format': vpFormat,
        'path': r'$',
        'path_nested': {
          'id': descriptor.id,
          'format': vcFormat,
          'path': r'$.verifiableCredential',
        },
      });
    } else {
      for (int i = 0; i < credentialsToBePresented.length; i++) {
        late InputDescriptor descriptor;

        for (final InputDescriptor inputDescriptor
            in presentationDefinition.inputDescriptors) {
          for (final Field field in inputDescriptor.constraints!.fields!) {
            final credentialName =
                field.filter!.pattern ?? field.filter!.contains!.containsConst;
            if (credentialsToBePresented[i]
                .credentialPreview
                .type
                .contains(credentialName)) {
              descriptor = inputDescriptor;
            }
          }
        }

        inputDescriptors.add({
          'id': descriptor.id,
          'format': vpFormat,
          'path': r'$',
          'path_nested': {
            'id': descriptor.id,
            'format': vcFormat,
            // ignore: prefer_interpolation_to_compose_strings
            'path': r'$.verifiableCredential[' + i.toString() + ']',
          },
        });
      }
    }

    presentationSubmission['descriptor_map'] = inputDescriptors;

    final presentationSubmissionString = jsonEncode(presentationSubmission);

    return presentationSubmissionString;
  }

  Future<void> askPermissionDIDAuthCHAPI({
    required String keyId,
    String? challenge,
    String? domain,
    required Uri uri,
    required dynamic Function(String) done,
  }) async {
    emit(
      state.scanPermission(
        keyId: keyId,
        done: done,
        uri: uri,
        challenge: challenge,
        domain: domain,
      ),
    );
  }

  Future<String> createVpToken({
    required List<CredentialModel> credentialsToBePresented,
    required PresentationDefinition presentationDefinition,
    required OIDC4VC oidc4vc,
    required String privateKey,
    required String did,
    required String kid,
    required Uri uri,
  }) async {
    final nonce = uri.queryParameters['nonce'] ?? '';
    final clientId = uri.queryParameters['client_id'] ?? '';

    /// ldp_vc
    final presentLdpVc = presentationDefinition.format?.ldpVc != null;

    /// jwt_vc
    final presentJwtVc = presentationDefinition.format?.jwtVc != null;

    if (presentLdpVc) {
      final ssiKey = await secureStorageProvider.get(SecureStorageKeys.ssiKey);
      final did = await secureStorageProvider.get(SecureStorageKeys.did);
      final options = jsonEncode({
        'verificationMethod': await secureStorageProvider
            .get(SecureStorageKeys.verificationMethod),
        'proofPurpose': 'authentication',
        'challenge': nonce,
        'domain': clientId,
      });
      final presentationId = 'urn:uuid:${const Uuid().v4()}';
      final vpToken = await didKitProvider.issuePresentation(
        jsonEncode({
          '@context': ['https://www.w3.org/2018/credentials/v1'],
          'type': ['VerifiablePresentation'],
          'holder': did,
          'id': presentationId,
          'verifiableCredential': credentialsToBePresented.length == 1
              ? credentialsToBePresented.first.data
              : credentialsToBePresented.map((c) => c.data).toList(),
        }),
        options,
        ssiKey!,
      );
      return vpToken;
    } else if (presentJwtVc) {
      final credentialList =
          credentialsToBePresented.map((e) => jsonEncode(e.toJson())).toList();

      final vpToken = await oidc4vc.extractVpToken(
        clientId: clientId,
        credentialsToBePresented: credentialList,
        did: did,
        kid: kid,
        privateKey: privateKey,
        nonce: nonce,
      );

      return vpToken;
    } else {
      throw Exception();
    }
  }

  Future<String> createIdToken({
    required List<CredentialModel> credentialsToBePresented,
    required OIDC4VC oidc4vc,
    required String privateKey,
    required String did,
    required String kid,
    required Uri uri,
  }) async {
    final credentialList =
        credentialsToBePresented.map((e) => jsonEncode(e.toJson())).toList();

    final nonce = uri.queryParameters['nonce'] ?? '';
    final clientId = uri.queryParameters['client_id'] ?? '';

    final idToken = await oidc4vc.extractIdToken(
      clientId: clientId,
      credentialsToBePresented: credentialList,
      did: did,
      kid: kid,
      privateKey: privateKey,
      nonce: nonce,
      useJWKThumbPrint: profileCubit.state.model.enableJWKThumbprint,
    );

    return idToken;
  }

  Future<void> presentationActivity({
    required List<CredentialModel> credentialModels,
    required Issuer issuer,
  }) async {
    final log = getLogger('ScanCubit');
    log.i('adding presentation Activity');
    for (final credentialModel in credentialModels) {
      final Activity activity = Activity(
        presentation: Presentation(
          issuer: issuer,
          presentedAt: DateTime.now(),
        ),
      );
      credentialModel.activities.add(activity);

      log.i('presentation activity added to the credential');
      await credentialsCubit.updateCredential(
        credential: credentialModel,
        showMessage: false,
      );
    }
  }
}
