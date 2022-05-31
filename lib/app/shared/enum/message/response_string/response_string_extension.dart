part of 'response_string.dart';

extension ResponseStringX on ResponseString {
  String localise(BuildContext context) {
    final GlobalMessage globalMessage = GlobalMessage(context.l10n);
    switch (this) {
      case ResponseString.RESPONSE_STRING_FAILED_TO_LOAD_PROFILE:
        return globalMessage.RESPONSE_STRING_FAILED_TO_LOAD_PROFILE;

      case ResponseString.RESPONSE_STRING_FAILED_TO_SAVE_PROFILE:
        return globalMessage.RESPONSE_STRING_FAILED_TO_SAVE_PROFILE;

      case ResponseString
          .RESPONSE_STRING_FAILED_TO_CREATE_SELF_ISSUED_CREDENTIAL:
        return globalMessage
            .RESPONSE_STRING_FAILED_TO_CREATE_SELF_ISSUED_CREDENTIAL;

      case ResponseString
          .RESPONSE_STRING_FAILED_TO_VERIFY_SELF_ISSUED_CREDENTIAL:
        return globalMessage
            .RESPONSE_STRING_FAILED_TO_VERIFY_SELF_ISSUED_CREDENTIAL;

      case ResponseString.RESPONSE_STRING_SELF_ISSUED_CREATED_SUCCESSFULLY:
        return globalMessage.RESPONSE_STRING_SELF_ISSUED_CREATED_SUCCESSFULLY;

      case ResponseString.RESPONSE_STRING_BACKUP_CREDENTIAL_ERROR:
        return globalMessage.RESPONSE_STRING_BACKUP_CREDENTIAL_ERROR;

      case ResponseString
          .RESPONSE_STRING_BACKUP_CREDENTIAL_PERMISSION_DENIED_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_BACKUP_CREDENTIAL_PERMISSION_DENIED_MESSAGE;

      case ResponseString.RESPONSE_STRING_BACKUP_CREDENTIAL_SUCCESS_MESSAGE:
        return globalMessage.RESPONSE_STRING_BACKUP_CREDENTIAL_SUCCESS_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_RECOVERY_CREDENTIAL_JSON_FORMAT_ERROR_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_RECOVERY_CREDENTIAL_JSON_FORMAT_ERROR_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_RECOVERY_CREDENTIAL_AUTH_ERROR_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_RECOVERY_CREDENTIAL_AUTH_ERROR_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_RECOVERY_CREDENTIAL_DEFAULT_ERROR_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_RECOVERY_CREDENTIAL_DEFAULT_ERROR_MESSAGE;

      case ResponseString.RESPONSE_STRING_CREDENTIAL_ADDED_MESSAGE:
        return globalMessage.RESPONSE_STRING_CREDENTIAL_ADDED_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_CREDENTIAL_DETAIL_EDIT_SUCCESS_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_CREDENTIAL_DETAIL_EDIT_SUCCESS_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_CREDENTIAL_DETAIL_DELETE_SUCCESS_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_CREDENTIAL_DETAIL_DELETE_SUCCESS_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_CREDENTIAL_VERIFICATION_RETURN_WARNING:
        return globalMessage
            .RESPONSE_STRING_CREDENTIAL_VERIFICATION_RETURN_WARNING;

      case ResponseString.RESPONSE_STRING_FAILED_TO_VERIFY_CREDENTIAL:
        return globalMessage.RESPONSE_STRING_FAILED_TO_VERIFY_CREDENTIAL;

      case ResponseString.RESPONSE_STRING_AN_UNKNOWN_ERROR_HAPPENED:
        return globalMessage.RESPONSE_STRING_AN_UNKNOWN_ERROR_HAPPENED;

      case ResponseString.RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER:
        return globalMessage
            .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER;

      case ResponseString
          .RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_CREDENTIAL:
        return globalMessage
            .RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_CREDENTIAL;

      case ResponseString.RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_DID:
        return globalMessage.RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_DID;

      case ResponseString
          .RESPONSE_STRING_THIS_QR_CODE_DOSE_NOT_CONTAIN_A_VALID_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_THIS_QR_CODE_DOSE_NOT_CONTAIN_A_VALID_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_THIS_URL_DOSE_NOT_CONTAIN_A_VALID_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_THIS_URL_DOSE_NOT_CONTAIN_A_VALID_MESSAGE;

      case ResponseString
          .RESPONSE_STRING_AN_ERROR_OCCURRED_WHILE_CONNECTING_TO_THE_SERVER:
        return globalMessage
            .RESPONSE_STRING_AN_ERROR_OCCURRED_WHILE_CONNECTING_TO_THE_SERVER;

      case ResponseString.RESPONSE_STRING_ERROR_GENERATING_KEY:
        return globalMessage.RESPONSE_STRING_ERROR_GENERATING_KEY;

      case ResponseString
          .RESPONSE_STRING_FAILED_TO_SAVE_MNEMONIC_PLEASE_TRY_AGAIN:
        return globalMessage
            .RESPONSE_STRING_FAILED_TO_SAVE_MNEMONIC_PLEASE_TRY_AGAIN;

      case ResponseString.RESPONSE_STRING_FAILED_TO_LOAD_DID:
        return globalMessage.RESPONSE_STRING_FAILED_TO_LOAD_DID;

      case ResponseString.RESPONSE_STRING_SCAN_REFUSE_HOST:
        return globalMessage.RESPONSE_STRING_SCAN_REFUSE_HOST;

      case ResponseString.RESPONSE_STRING_PLEASE_IMPORT_YOUR_RSA_KEY:
        return globalMessage.RESPONSE_STRING_PLEASE_IMPORT_YOUR_RSA_KEY;

      case ResponseString.RESPONSE_STRING_PLEASE_ENTER_YOUR_DID_KEY:
        return globalMessage.RESPONSE_STRING_PLEASE_ENTER_YOUR_DID_KEY;

      case ResponseString.RESPONSE_STRING_RSA_NOT_MATCHED_WITH_DID_KEY:
        return globalMessage.RESPONSE_STRING_RSA_NOT_MATCHED_WITH_DID_KEY;

      case ResponseString.RESPONSE_STRING_DID_KEY_NOT_RESOLVED:
        return globalMessage.RESPONSE_STRING_DID_KEY_NOT_RESOLVED;

      case ResponseString
          .RESPONSE_STRING_DID_KEY_AND_RSA_KEY_VERIFIED_SUCCESSFULLY:
        return globalMessage
            .RESPONSE_STRING_DID_KEY_AND_RSA_KEY_VERIFIED_SUCCESSFULLY;

      case ResponseString.RESPONSE_STRING_UNABLE_TO_PROCESS_THE_DATA:
        return globalMessage.RESPONSE_STRING_UNABLE_TO_PROCESS_THE_DATA;

      case ResponseString.RESPONSE_STRING_SCAN_UNSUPPORTED_MESSAGE:
        return globalMessage.RESPONSE_STRING_SCAN_UNSUPPORTED_MESSAGE;

      case ResponseString.RESPONSE_STRING_UNIMPLEMENTED_QUERY_TYPE:
        return globalMessage.RESPONSE_STRING_UNIMPLEMENTED_QUERY_TYPE;

      case ResponseString.RESPONSE_STRING_PERSONAL_OPEN_ID_RESTRICTION_MESSAGE:
        return globalMessage
            .RESPONSE_STRING_PERSONAL_OPEN_ID_RESTRICTION_MESSAGE;

      case ResponseString.RESPONSE_STRING_CREDENTIAL_EMPTY_ERROR:
        return globalMessage.RESPONSE_STRING_CREDENTIAL_EMPTY_ERROR;
    }
  }
}