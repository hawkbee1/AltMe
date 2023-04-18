import 'dart:convert';
import 'dart:typed_data';

import 'package:altme/app/app.dart';
import 'package:altme/credentials/credentials.dart';
import 'package:altme/polygon_id/polygon_id.dart';

import 'package:cryptocurrency_keys/cryptocurrency_keys.dart';
import 'package:equatable/equatable.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:secure_storage/secure_storage.dart';

part 'backup_credential_cubit.g.dart';
part 'backup_credential_state.dart';

class BackupCredentialCubit extends Cubit<BackupCredentialState> {
  BackupCredentialCubit({
    required this.secureStorageProvider,
    required this.cryptoKeys,
    required this.credentialsCubit,
    required this.fileSaver,
    required this.polygonIdCubit,
  }) : super(const BackupCredentialState());

  final SecureStorageProvider secureStorageProvider;
  final CryptocurrencyKeys cryptoKeys;
  final CredentialsCubit credentialsCubit;
  final FileSaver fileSaver;
  final PolygonIdCubit polygonIdCubit;

  Future<void> encryptAndDownloadFile() async {
    emit(state.loading());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final mnemonic =
        await secureStorageProvider.get(SecureStorageKeys.ssiMnemonic);
    final isPermissionStatusGranted = await getStoragePermission();

    try {
      if (!isPermissionStatusGranted) {
        throw ResponseMessage(
          ResponseString.STORAGE_PERMISSION_DENIED_MESSAGE,
        );
      }

      final dateTime = getDateTimeWithoutSpace();
      final fileName = 'altme-credential-$dateTime';

      final credentialModels = credentialsCubit.state.credentials;

      final date = UiDate.formatDate(DateTime.now());
      final message = {
        'date': date,
        'credentials': credentialModels,
      };
      final encrypted =
          await cryptoKeys.encrypt(jsonEncode(message), mnemonic!);
      final encryptedString = jsonEncode(encrypted);

      final fileBytes = Uint8List.fromList(utf8.encode(encryptedString));
      final filePath =
          await fileSaver.saveAs(fileName, fileBytes, 'txt', MimeType.TEXT);

      if (filePath.isEmpty) {
        emit(state.copyWith(status: AppStatus.idle));
      } else {
        emit(
          state.copyWith(
            status: AppStatus.success,
            filePath: filePath,
            messageHandler: ResponseMessage(
              ResponseString.RESPONSE_STRING_BACKUP_CREDENTIAL_SUCCESS_MESSAGE,
            ),
          ),
        );
      }
    } catch (e) {
      if (e is MessageHandler) {
        emit(state.error(messageHandler: e));
      } else {
        emit(
          state.error(
            messageHandler: ResponseMessage(
              ResponseString.RESPONSE_STRING_BACKUP_CREDENTIAL_ERROR,
            ),
          ),
        );
      }
    }
  }
}
