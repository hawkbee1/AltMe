import 'package:altme/app/app.dart';
import 'package:altme/dashboard/profile/models/profile_setting.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oidc4vc/oidc4vc.dart';

part 'profile.g.dart';

@JsonSerializable()
class ProfileModel extends Equatable {
  const ProfileModel({
    required this.polygonIdNetwork,
    required this.walletType,
    required this.walletProtectionType,
    required this.isDeveloperMode,
    required this.profileType,
    required this.profileSetting,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  factory ProfileModel.empty() => ProfileModel(
        polygonIdNetwork: PolygonIdNetwork.PolygonMainnet.toString(),
        walletType: WalletType.personal.toString(),
        walletProtectionType: WalletProtectionType.pinCode.toString(),
        isDeveloperMode: false,
        profileType: ProfileType.custom.toString(),
        profileSetting: ProfileSetting.initial(),
      );

  factory ProfileModel.ebsiV3(ProfileModel oldModel) => ProfileModel(
        polygonIdNetwork: oldModel.polygonIdNetwork,
        walletType: oldModel.walletType,
        walletProtectionType: oldModel.walletProtectionType,
        isDeveloperMode: oldModel.isDeveloperMode,
        profileType: ProfileType.ebsiV3.toString(),
        profileSetting: ProfileSetting(
          blockchainOptions: BlockchainOptions.initial(),
          generalOptions: GeneralOptions.empty(),
          helpCenterOptions: HelpCenterOptions.initial(),
          selfSovereignIdentityOptions: const SelfSovereignIdentityOptions(
            displayManageDecentralizedId: true,
            displaySsiAdvancedSettings: false,
            displayVerifiableDataRegistry: true,
            oidv4vcProfile: 'ebsi',
            customOidc4vcProfile: CustomOidc4VcProfile(
              clientAuthentication: ClientAuthentication.none,
              credentialManifestSupport: false,
              cryptoHolderBinding: true,
              defaultDid: DidKeyType.ebsiv3,
              oidc4vciDraft: OIDC4VCIDraftType.draft11,
              oidc4vpDraft: OIDC4VPDraftType.draft10,
              scope: false,
              securityLevel: SecurityLevel.low,
              siopv2Draft: SIOPV2DraftType.draft12,
              subjectSyntaxeType: SubjectSyntax.did,
              userPinDigits: UserPinDigits.four,
            ),
          ),
          settingsMenu: SettingsMenu.initial(),
          version: oldModel.profileSetting.version,
          walletSecurityOptions: WalletSecurityOptions.initial(),
        ),
      );

  factory ProfileModel.dutch(ProfileModel oldModel) => ProfileModel(
        polygonIdNetwork: oldModel.polygonIdNetwork,
        walletType: oldModel.walletType,
        walletProtectionType: oldModel.walletProtectionType,
        isDeveloperMode: oldModel.isDeveloperMode,
        profileType: ProfileType.dutch.toString(),
        profileSetting: ProfileSetting(
          blockchainOptions: BlockchainOptions.initial(),
          generalOptions: GeneralOptions.empty(),
          helpCenterOptions: HelpCenterOptions.initial(),
          selfSovereignIdentityOptions: const SelfSovereignIdentityOptions(
            displayManageDecentralizedId: true,
            displaySsiAdvancedSettings: false,
            displayVerifiableDataRegistry: true,
            oidv4vcProfile: 'diip',
            customOidc4vcProfile: CustomOidc4VcProfile(
              clientAuthentication: ClientAuthentication.none,
              credentialManifestSupport: false,
              cryptoHolderBinding: true,
              defaultDid: DidKeyType.jwkP256,
              oidc4vciDraft: OIDC4VCIDraftType.draft11,
              oidc4vpDraft: OIDC4VPDraftType.draft10,
              scope: false,
              securityLevel: SecurityLevel.low,
              siopv2Draft: SIOPV2DraftType.draft12,
              subjectSyntaxeType: SubjectSyntax.did,
              userPinDigits: UserPinDigits.four,
            ),
          ),
          settingsMenu: SettingsMenu.initial(),
          version: oldModel.profileSetting.version,
          walletSecurityOptions: WalletSecurityOptions.initial(),
        ),
      );

  final String polygonIdNetwork;
  final String walletType;
  final String walletProtectionType;
  final bool isDeveloperMode;
  final ProfileSetting profileSetting;
  final String profileType;

  @override
  List<Object> get props => [
        polygonIdNetwork,
        walletType,
        walletProtectionType,
        isDeveloperMode,
        profileType,
        profileSetting,
      ];

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  ProfileModel copyWith({
    String? polygonIdNetwork,
    TezosNetwork? tezosNetwork,
    String? walletType,
    String? walletProtectionType,
    bool? isDeveloperMode,
    String? profileType,
    ProfileSetting? profileSetting,
  }) {
    return ProfileModel(
      polygonIdNetwork: polygonIdNetwork ?? this.polygonIdNetwork,
      walletType: walletType ?? this.walletType,
      walletProtectionType: walletProtectionType ?? this.walletProtectionType,
      isDeveloperMode: isDeveloperMode ?? this.isDeveloperMode,
      profileType: profileType ?? this.profileType,
      profileSetting: profileSetting ?? this.profileSetting,
    );
  }
}
