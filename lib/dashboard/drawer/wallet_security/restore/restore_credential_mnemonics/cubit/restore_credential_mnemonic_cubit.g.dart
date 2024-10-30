// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_credential_mnemonic_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestoreCredentialMnemonicState _$RestoreCredentialMnemonicStateFromJson(
        Map<String, dynamic> json) =>
    RestoreCredentialMnemonicState(
      status: $enumDecodeNullable(_$AppStatusEnumMap, json['status']) ??
          AppStatus.init,
      message: json['message'] == null
          ? null
          : StateMessage.fromJson(json['message'] as Map<String, dynamic>),
      isTextFieldEdited: json['isTextFieldEdited'] as bool? ?? false,
      isMnemonicValid: json['isMnemonicValid'] as bool? ?? false,
    );

Map<String, dynamic> _$RestoreCredentialMnemonicStateToJson(
        RestoreCredentialMnemonicState instance) =>
    <String, dynamic>{
      'status': _$AppStatusEnumMap[instance.status]!,
      'message': instance.message,
      'isTextFieldEdited': instance.isTextFieldEdited,
      'isMnemonicValid': instance.isMnemonicValid,
    };

const _$AppStatusEnumMap = {
  AppStatus.init: 'init',
  AppStatus.fetching: 'fetching',
  AppStatus.loading: 'loading',
  AppStatus.populate: 'populate',
  AppStatus.error: 'error',
  AppStatus.errorWhileFetching: 'errorWhileFetching',
  AppStatus.success: 'success',
  AppStatus.idle: 'idle',
  AppStatus.goBack: 'goBack',
  AppStatus.revoked: 'revoked',
  AppStatus.addEnterpriseAccount: 'addEnterpriseAccount',
  AppStatus.updateEnterpriseAccount: 'updateEnterpriseAccount',
  AppStatus.replaceEnterpriseAccount: 'replaceEnterpriseAccount',
  AppStatus.restoreWallet: 'restoreWallet',
};
