import 'package:altme/app/app.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';

part 'response_string_extension.dart';

enum ResponseString {
  RESPONSE_STRING_BALANCE_TOO_LOW,
  RESPONSE_STRING_CANNOT_PAY_STORAGE_FEE,
  RESPONSE_STRING_FEE_TOO_LOW,
  RESPONSE_STRING_FEE_TOO_LOW_FOR_MEMPOOL,
  RESPONSE_STRING_TX_ROLLUP_BALANCE_TOO_LOW,
  RESPONSE_STRING_TX_ROLLUP_INVALID_ZERO_TRANSFER,
  RESPONSE_STRING_TX_ROLLUP_UNKNOWN_ADDRESS,
  RESPONSE_STRING_INACTIVE_CHAIN,
  RESPONSE_STRING_FAILED_TO_LOAD_PROFILE,
  RESPONSE_STRING_FAILED_TO_SAVE_PROFILE,
  RESPONSE_STRING_FAILED_TO_DO_OPERATION,
  RESPONSE_STRING_FAILED_TO_CREATE_SELF_ISSUED_CREDENTIAL,
  RESPONSE_STRING_FAILED_TO_VERIFY_SELF_ISSUED_CREDENTIAL,
  RESPONSE_STRING_SELF_ISSUED_CREATED_SUCCESSFULLY,
  RESPONSE_STRING_BACKUP_CREDENTIAL_ERROR,
  STORAGE_PERMISSION_DENIED_MESSAGE,
  RESPONSE_STRING_BACKUP_CREDENTIAL_SUCCESS_MESSAGE,
  RESPONSE_STRING_RECOVERY_CREDENTIAL_JSON_FORMAT_ERROR_MESSAGE,
  RESPONSE_STRING_RECOVERY_CREDENTIAL_AUTH_ERROR_MESSAGE,
  RESPONSE_STRING_RECOVERY_CREDENTIAL_DEFAULT_ERROR_MESSAGE,
  RESPONSE_STRING_CREDENTIAL_ADDED_MESSAGE,
  RESPONSE_STRING_CREDENTIAL_DETAIL_EDIT_SUCCESS_MESSAGE,
  RESPONSE_STRING_CREDENTIAL_DETAIL_DELETE_SUCCESS_MESSAGE,
  RESPONSE_STRING_CREDENTIAL_VERIFICATION_RETURN_WARNING,
  RESPONSE_STRING_FAILED_TO_VERIFY_CREDENTIAL,
  RESPONSE_STRING_AN_UNKNOWN_ERROR_HAPPENED,
  RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
  RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_CREDENTIAL,
  RESPONSE_STRING_SUCCESSFULLY_PRESENTED_YOUR_DID,
  RESPONSE_STRING_THIS_QR_CODE_IS_NOT_SUPPORTED,
  RESPONSE_STRING_THIS_URL_DOSE_NOT_CONTAIN_A_VALID_MESSAGE,
  RESPONSE_STRING_AN_ERROR_OCCURRED_WHILE_CONNECTING_TO_THE_SERVER,
  RESPONSE_STRING_ERROR_GENERATING_KEY,
  RESPONSE_STRING_FAILED_TO_SAVE_MNEMONIC_PLEASE_TRY_AGAIN,
  RESPONSE_STRING_FAILED_TO_LOAD_DID,
  RESPONSE_STRING_SCAN_REFUSE_HOST,
  RESPONSE_STRING_PLEASE_IMPORT_YOUR_RSA_KEY,
  RESPONSE_STRING_PLEASE_ENTER_YOUR_DID_KEY,
  RESPONSE_STRING_RSA_NOT_MATCHED_WITH_DID_KEY,
  RESPONSE_STRING_DID_KEY_NOT_RESOLVED,
  RESPONSE_STRING_DID_KEY_AND_RSA_KEY_VERIFIED_SUCCESSFULLY,
  RESPONSE_STRING_UNABLE_TO_PROCESS_THE_DATA,
  RESPONSE_STRING_SCAN_UNSUPPORTED_MESSAGE,
  RESPONSE_STRING_UNIMPLEMENTED_QUERY_TYPE,
  RESPONSE_STRING_PERSONAL_OPEN_ID_RESTRICTION_MESSAGE,
  RESPONSE_STRING_CREDENTIAL_EMPTY_ERROR,
  RESPONSE_STRING_CRYPTO_ACCOUNT_ADDED,
  RESPONSE_STRING_CRYPTO_ACCOUNT_ALREADY_EXIST,
  RESPONSE_STRING_SUCCESSFULLY_CONNECTED_TO_BEACON,
  RESPONSE_STRING_FAILED_TO_CONNECT_WITH_BEACON,
  RESPONSE_STRING_SUCCESSFULLY_SIGNED_PAYLOAD,
  RESPONSE_STRING_FAILED_TO_SIGNED_PAYLOAD,
  RESPONSE_STRING_OPERATION_COMPLETED,
  RESPONSE_STRING_OPERATION_FAILED,
  RESPONSE_STRING_INSUFFICIENT_BALANCE,
  RESPONSE_STRING_SWITCH_NETWORK_MESSAGE,
  RESPONSE_STRING_DISCONNECTED_FROM_DAPP,
  RESPONSE_STRING_emailPassWhyGetThisCard,
  RESPONSE_STRING_emailPassExpirationDate,
  RESPONSE_STRING_emailPassHowToGetIt,
  RESPONSE_STRING_tezotopiaMembershipWhyGetThisCard,
  RESPONSE_STRING_tezotopiaMembershipExpirationDate,
  RESPONSE_STRING_tezotopiaMembershipHowToGetIt,
  RESPONSE_STRING_chainbornMembershipWhyGetThisCard,
  RESPONSE_STRING_chainbornMembershipExpirationDate,
  RESPONSE_STRING_chainbornMembershipHowToGetIt,
  RESPONSE_STRING_defiComplianceWhyGetThisCard,
  RESPONSE_STRING_defiComplianceExpirationDate,
  RESPONSE_STRING_defiComplianceHowToGetIt,
  RESPONSE_STRING_twitterWhyGetThisCard,
  RESPONSE_STRING_twitterExpirationDate,
  RESPONSE_STRING_twitterHowToGetIt,
  RESPONSE_STRING_twitterDummyDesc,
  RESPONSE_STRING_over18WhyGetThisCard,
  RESPONSE_STRING_over18ExpirationDate,
  RESPONSE_STRING_over18HowToGetIt,
  RESPONSE_STRING_over13WhyGetThisCard,
  RESPONSE_STRING_over13ExpirationDate,
  RESPONSE_STRING_over13HowToGetIt,
  RESPONSE_STRING_over15WhyGetThisCard,
  RESPONSE_STRING_over15ExpirationDate,
  RESPONSE_STRING_over15HowToGetIt,
  RESPONSE_STRING_passportFootprintWhyGetThisCard,
  RESPONSE_STRING_passportFootprintExpirationDate,
  RESPONSE_STRING_passportFootprintHowToGetIt,
  RESPONSE_STRING_verifiableIdCardWhyGetThisCard,
  RESPONSE_STRING_verifiableIdCardExpirationDate,
  RESPONSE_STRING_verifiableIdCardHowToGetIt,
  RESPONSE_STRING_verifiableIdCardDummyDesc,
  RESPONSE_STRING_linkedinCardWhyGetThisCard,
  RESPONSE_STRING_linkedinCardExpirationDate,
  RESPONSE_STRING_linkedinCardHowToGetIt,
  RESPONSE_STRING_phoneProofWhyGetThisCard,
  RESPONSE_STRING_phoneProofExpirationDate,
  RESPONSE_STRING_phoneProofHowToGetIt,
  RESPONSE_STRING_tezVoucherWhyGetThisCard,
  RESPONSE_STRING_tezVoucherExpirationDate,
  RESPONSE_STRING_tezVoucherHowToGetIt,
  RESPONSE_STRING_genderWhyGetThisCard,
  RESPONSE_STRING_genderExpirationDate,
  RESPONSE_STRING_genderHowToGetIt,
  RESPONSE_STRING_nationalityWhyGetThisCard,
  RESPONSE_STRING_nationalityExpirationDate,
  RESPONSE_STRING_nationalityHowToGetIt,
  RESPONSE_STRING_ageRangeWhyGetThisCard,
  RESPONSE_STRING_ageRangeExpirationDate,
  RESPONSE_STRING_ageRangeHowToGetIt,
  RESPONSE_STRING_payloadFormatErrorMessage,
  RESPONSE_STRING_thisFeatureIsNotSupportedMessage,
  RESPONSE_STRING_userNotFitErrorMessage,
  RESPONSE_STRING_transactionIsLikelyToFail,
  RESPONSE_STRING_linkedInBannerSuccessfullyExported,
  RESPONSE_STRING_credentialSuccessfullyExported,
  RESPONSE_STRING_livenessCardExpirationDate,
  RESPONSE_STRING_livenessCardWhyGetThisCard,
  RESPONSE_STRING_livenessCardHowToGetIt,
  RESPONSE_STRING_tezotopiaMembershipLongDescription,
  RESPONSE_STRING_chainbornMembershipLongDescription,
  RESPONSE_STRING_livenessCardLongDescription,
  RESPONSE_STRING_succesfullyAuthenticated,
  RESPONSE_STRING_authenticationFailed,
  RESPONSE_STRING_deviceIncompatibilityMessage,
  RESPONSE_STRING_backupPolygonIdCredentialEmptyError,
  RESPONSE_STRING_downloadingCircuitLoadingMessage,
  RESPONSE_STRING_errorGeneratingProof,
  RESPONSE_STRING_successfullyGeneratingProof,
  RESPONSE_STRING_pleaseAddXtoConnectToTheDapp,
  RESPONSE_STRING_pleaseSwitchPolygonNetwork,
  RESPONSE_STRING_pleaseSwitchToRightOIDC4VCProfile,
  RESPONSE_STRING_authenticationSuccess,
  RESPONSE_STRING_youcanSelectOnlyXCredential,
  RESPONSE_STRING_theCredentialIsNotReady,
  RESPONSE_STRING_theCredentialIsNoMoreReady,
  RESPONSE_STRING_theRequestIsRejected,
  RESPONSE_STRING_userPinIsIncorrect,
  RESPONSE_STRING_responseTypeNotSupported,
  RESPONSE_STRING_invalidRequest,
  RESPONSE_STRING_subjectSyntaxTypeNotSupported,
  RESPONSE_STRING_accessDenied,
  RESPONSE_STRING_thisRequestIsNotSupported,
  RESPONSE_STRING_unsupportedCredential,
  RESPONSE_STRING_aloginIsRequired,
  RESPONSE_STRING_userConsentIsRequired,
  RESPONSE_STRING_theWalletIsNotRegistered,
  RESPONSE_STRING_credentialIssuanceDenied,
  RESPONSE_STRING_thisCredentialFormatIsNotSupported,
  RESPONSE_STRING_thisFormatIsNotSupported,
  RESPONSE_STRING_theCredentialOfferIsInvalid,
  RESPONSE_STRING_theServiceIsNotAvailable,
  RESPONSE_STRING_theIssuanceOfThisCredentialIsPending,
}
