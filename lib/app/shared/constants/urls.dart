class Urls {
  static const String appContactWebsiteUrl = 'https://altme.io';
  static const String checkIssuerTalaoUrl =
      'https://talao.co/trusted-issuers-registry/v1/issuers';

  static const String checkIssuerPolygonTestnetUrl =
      'https://issuer-demo.polygonid.me/';
  static const String checkIssuerPolygonUrl = 'checkIssuerPolygonUrl';
  static const String checkIssuerEbsiUrl =
      'https://api.conformance.intebsi.xyz/trusted-issuers-registry/v2/issuers';
  static const Set<String> issuerUrls = {
    checkIssuerPolygonTestnetUrl,
    checkIssuerPolygonUrl,
    checkIssuerEbsiUrl,
  };

  static const String issuerBaseUrl = 'https://issuer.talao.co';

  /// phone pass
  static const String phonePassUrl = 'https://issuer.talao.co/phonepass';

  /// email pass
  static const String emailPassUrl = 'https://issuer.talao.co/emailpass';

  /// tezotopia voucher
  static const String tezotopiaVoucherUrl =
      'https://issuer.tezotopia.altme.io/issuer/voucher_mobile';

  /// tezotopia membership
  static const String tezotopiaMembershipCardUrl =
      'https://issuer.talao.co/tezotopia/membershipcard/';

  /// id360 url
  static const String id360Url = 'https://talao.co/id360/oidc4vc';

  /// polygon
  static const String defaultPolygonIdCardUrl =
      'https://issuer.talao.co/credential-manifest/polygonid/default';

  /// KYC Age
  static const String kycAgeCredentialUrl =
      'https://issuer.talao.co/credential-manifest/polygonid/kycagecredential';

  /// KYC Country
  static const String kycCountryOfResidenceUrl =
      'https://issuer.talao.co/credential-manifest/polygonid/kyccountryofresidencecredential';

  /// twitter proof
  static const String proofOfTwitterStatsUrl =
      'https://issuer.talao.co/credential-manifest/polygonid/ProofOfTwitterStats';

  /// civic pass
  static const String civicPassCredentialUrl =
      'https://issuer.talao.co/credential-manifest/polygonid/civicpasscredential';

  /// chainborn membership
  static const String chainbornMembershipCardUrl =
      'https://issuer.talao.co/chainborn/membershipcard/';

  /// twitter card
  static const String twitterCardUrl = 'https://issuer.talao.co/twitter/';

  // static const String talaoIpfsGafteway = 'https://talao.mypinata.cloud/ipfs/';
  static const String ipfsGateway = 'https://ipfs.io/ipfs/';

  /// main tezos rpc
  static const mainnetRPC = [
    'https://mainnet.ecadinfra.com',
    'https://mainnet.api.tez.ie',
    'https://rpc.tzbeta.net',
    'https://mainnet.tezos.marigold.dev',
    'https://rpc.tzstats.com',
  ];

  static const ghostnetRPC = 'https://rpc.tzkt.io/ghostnet';

  static const coinGeckoBase = 'https://pro-api.coingecko.com/api/v3/';

  static const cryptoCompareBaseUrl = 'https://min-api.cryptocompare.com';
  static String ethPrice(String symbol) =>
      '$cryptoCompareBaseUrl/data/price?fsym=$symbol&tsyms=USD';

  // TZKT
  static const tzktMainnetUrl = 'https://api.tzkt.io';
  static const tzktGhostnetUrl = 'https://api.ghostnet.tzkt.io';

  //Moralis
  static const moralisBaseUrl = 'https://deep-index.moralis.io/api/v2';

  //Infura
  static const infuraBaseUrl = 'https://mainnet.infura.io/v3/';

  static const objktUrl = 'https://objkt.com/';
  static const raribleUrl = 'https://rarible.com/';

  static const over13AIValidationUrl = 'https://issuer.talao.co/ai/over13';
  static const over15AIValidationUrl = 'https://issuer.talao.co/ai/over15';
  static const over18AIValidationUrl = 'https://issuer.talao.co/ai/over18';
  static const over21AIValidationUrl = 'https://issuer.talao.co/ai/over21';
  static const over50AIValidationUrl = 'https://issuer.talao.co/ai/over50';
  static const over65AIValidationUrl = 'https://issuer.talao.co/ai/over65';
  static const ageRangeAIValidationUrl = 'https://issuer.talao.co/ai/agerange';

  //Matrix home server
  static const matrixHomeServer = 'https://matrix.talao.co';
  static const getNonce = 'https://talao.co/matrix/nonce';
  static const registerToMatrix = 'https://talao.co/matrix/register';

  //deeplink
  static const appDeepLink = 'https://app.altme.io/app/download';

  //ID360
  static const getCodeForId360 = 'https://talao.co/id360/get_code';
  static const authenticateForId360 = 'https://talao.co/id360/authenticate';

  //Discover
  static const discoverCoinsWebView = 'https://discover-coins-part.webflow.io/';
  static const discoverNftsWebView =
      'https://discover-coins-part.webflow.io/prod-nota-available/nft-noir';

  // wallet provider
  static const walletProvider = 'https://wallet-provider.talao.co';
  static const walletTestProvider = 'https://preprod.wallet-provider.talao.co';
}
