import 'package:altme/app/shared/enum/enum.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class Parameters {
  static const int multipleCredentialsProcessDelay = 1;

  // 'false' for talao
  // 'true' for altme
  static const bool walletHandlesCrypto = true;

  static const AdvanceSettingsState defaultAdvanceSettingsState =
      AdvanceSettingsState(
    isGamingEnabled: true,
    isIdentityEnabled: true,
    isProfessionalEnabled: true,
    isBlockchainAccountsEnabled: true,
    isEducationEnabled: true,
    isSocialMediaEnabled: true,
    isCommunityEnabled: true,
    isOtherEnabled: true,
    isPassEnabled: true,
    isFinanceEnabled: true,
    isHumanityProofEnabled: true,
    isWalletIntegrityEnabled: true,
  );

  static const oidc4vcUniversalLink =
      'https://app.altme.io/app/download/callback';

  static const authorizeEndPoint =
      'https://app.altme.io/app/download/authorize';

  static const web3RpcMainnetUrl = 'https://mainnet.infura.io/v3/';

  static const POLYGON_MAIN_NETWORK = 'main';
  static const POLYGON_INFURA_URL = 'https://polygon-mainnet.infura.io/v3/';
  static const INFURA_RDP_URL = 'wss://polygon-mainnet.infura.io/v3/';
  static const ID_STATE_CONTRACT_ADDR =
      '0x624ce98D2d27b20b8f8d521723Df8fC4db71D79D';
  static const PUSH_URL = 'https://push-staging.polygonid.com/api/v1';

  static const POLYGON_TEST_NETWORK = 'mumbai';
  static const INFURA_MUMBAI_URL = 'https://polygon-mumbai.infura.io/v3/';
  static const INFURA_MUMBAI_RDP_URL = 'wss://polygon-mumbai.infura.io/v3/';
  static const MUMBAI_ID_STATE_CONTRACT_ADDR =
      '0x134B1BE34911E39A8397ec6289782989729807a4';
  static const MUMBAI_PUSH_URL = 'https://push-staging.polygonid.com/api/v1';

  static const NAMESPACE = 'eip155';
  static const PERSONAL_SIGN = 'personal_sign';
  static const ETH_SIGN = 'eth_sign';
  static const ETH_SIGN_TRANSACTION = 'eth_signTransaction';
  static const ETH_SIGN_TYPE_DATA = 'eth_signTypedData';
  static const ETH_SEND_TRANSACTION = 'eth_sendTransaction';
  static const ETH_SIGN_TYPE_DATA_V4 = 'eth_signTypedData_v4';

  static const walletConnectMethods = [
    PERSONAL_SIGN,
    ETH_SIGN,
    ETH_SIGN,
    ETH_SIGN_TRANSACTION,
    ETH_SIGN_TYPE_DATA,
    ETH_SEND_TRANSACTION,
    ETH_SIGN_TYPE_DATA_V4,
  ];

  static const chainChanged = 'chainChanged';
  static const accountsChanged = 'accountsChanged';

  static const requiredEvents = [
    chainChanged,
    accountsChanged,
  ];

  static const optionalEvents = ['message', 'disconnect', 'connect'];

  static const allEvents = [...requiredEvents, ...optionalEvents];

  static const String clientId = 'urn:altme:0001';
  static const int maxEntries = 3;

  // 'Talao'for talao
  // 'Altme' for altme
  static const String appName = 'Altme';

  // 'false' for talao
  // 'true' for altme
  static const bool importAtOnboarding = true;

  // false for talao
  // 'true' for altme
  static const bool supportDefiCompliance = true;

  // false for talao
  // 'true' for altme
  static const bool supportCryptoAccountOwnershipInDiscoverForEnterpriseMode =
      true;

  // false for talao
  // 'true' for altme
  static const bool showChainbornCard = true;

  // false for talao
  // true for altme
  static const bool showTezotopiaCard = true;

  //'https://app.talao.co/app/download/authorize' for Talao
  // 'https://app.altme.io/app/download/authorize' for altme
  static const String redirectUri =
      'https://app.altme.io/app/download/authorize';

  //'https://app.talao.co/app/download/callback' for Talao
  // 'https://app.altme.io/app/download/callback' for altme
  static const String authorizationEndPoint =
      'https://app.altme.io/app/download/callback';

  // 'talao_wallet'for talao
  // 'altme_wallet' for altme
  static const String walletName = 'altme_wallet';

  // 'https://app.talao.co/wallet_issuer'for talao
  // 'https://app.altme.io/wallet_issuer' for altme
  static const String walletIssuer = 'https://app.altme.io/wallet_issuer';

  static const DidKeyType didKeyTypeForEbsiV3 = DidKeyType.ebsiv3;
  static const DidKeyType didKeyTypeForEbsiV4 = DidKeyType.ebsiv4;
  static const DidKeyType didKeyTypeForDefault = DidKeyType.edDSA;
  static const DidKeyType didKeyTypeForDutch = DidKeyType.jwkP256;
  static const DidKeyType didKeyTypeForOwfBaselineProfile = DidKeyType.jwkP256;

  // seed color for the app Theme
  // Altme
  static const Color seedColor = Color(0xff6600FF);
  // Talao
  // static const Color seedColor = Color(0xff1EAADC);

  // ThemeMode.light for talao
  // 'ThemeMode.dark' for altme
  static const ThemeMode defaultTheme = ThemeMode.dark;

// Used to prevent display
// This key tells the app to not display the field and it allows use of maps
// with display of key value. See displayKeyValueFromMap

  static const String doNotDisplayMe = 'doNotDisplayMeMggK5GvU7';
}
