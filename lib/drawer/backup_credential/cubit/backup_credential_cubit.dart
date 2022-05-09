import 'dart:convert';
import 'dart:typed_data';

import 'package:altme/app/app.dart';
import 'package:altme/wallet/cubit/wallet_cubit.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:cryptocurrency_keys/cryptocurrency_keys.dart';
import 'package:equatable/equatable.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_storage/secure_storage.dart';

part 'backup_credential_cubit.g.dart';

part 'backup_credential_state.dart';

class BackupCredentialCubit extends Cubit<BackupCredentialState> {
  BackupCredentialCubit({
    required this.secureStorageProvider,
    required this.cryptoKeys,
    required this.walletCubit,
    required this.fileSaver,
  }) : super(BackupCredentialState());

  final SecureStorageProvider secureStorageProvider;
  final CryptocurrencyKeys cryptoKeys;
  final WalletCubit walletCubit;
  final FileSaver fileSaver;

  Future<bool> _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      //todo: show dialog to choose this option
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      return false;
    }
    return false;
  }

  Future<void> encryptAndDownloadFile() async {
    emit(state.loading());
    final isPermissionStatusGranted = await _getStoragePermission();

    try {
      if (isPermissionStatusGranted) {
        throw ResponseMessage(
          ResponseString
              .RESPONSE_STRING_BACKUP_CREDENTIAL_PERMISSION_DENIED_MESSAGE,
        );
      }
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final fileName = 'altme-credential-$date';
      final message = {
        'date': date,
        'credentials': walletCubit.state.credentials,
      };

      final mnemonicFormatted = state.mnemonic.join(' ');
      final encrypted =
          await cryptoKeys.encrypt(jsonEncode(message), mnemonicFormatted);
      final fileBytes = Uint8List.fromList(utf8.encode(jsonEncode(encrypted)));
      final filePath =
          await fileSaver.saveAs(fileName, fileBytes, 'txt', MimeType.TEXT);
      emit(
        state.success(
          filePath: filePath,
          messageHandler: ResponseMessage(
            ResponseString.RESPONSE_STRING_BACKUP_CREDENTIAL_SUCCESS_MESSAGE,
          ),
        ),
      );
    } catch (e) {
      if (e is MessageHandler) {
        state.error(messageHandler: e);
      } else {
        state.error(
          messageHandler: ResponseMessage(
            ResponseString.RESPONSE_STRING_BACKUP_CREDENTIAL_ERROR,
          ),
        );
      }
    }
  }
}
