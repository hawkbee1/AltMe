import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:json_annotation/json_annotation.dart';

part 'etherlink_associated_address_model.g.dart';

@JsonSerializable(explicitToJson: true)
class EtherlinkAssociatedAddressModel extends CredentialSubjectModel {
  EtherlinkAssociatedAddressModel({
    this.associatedAddress,
    this.accountName,
    required String super.id,
    required String super.type,
    required Author super.issuedBy,
  }) : super(
          credentialSubjectType:
              CredentialSubjectType.etherlinkAssociatedWallet,
          credentialCategory: CredentialCategory.blockchainAccountsCards,
        );

  factory EtherlinkAssociatedAddressModel.fromJson(Map<String, dynamic> json) =>
      _$EtherlinkAssociatedAddressModelFromJson(json);

  @JsonKey(defaultValue: '')
  final String? associatedAddress;

  @JsonKey(defaultValue: '')
  final String? accountName;

  @override
  Map<String, dynamic> toJson() =>
      _$EtherlinkAssociatedAddressModelToJson(this);
}
