import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tezos_associated_address_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TezosAssociatedAddressModel extends CredentialSubjectModel {
  TezosAssociatedAddressModel({
    this.associatedAddress,
    this.accountName,
    String? id,
    String? type,
  }) : super(
          id: id,
          type: type,
          credentialSubjectType: CredentialSubjectType.tezosAssociatedWallet,
          credentialCategory: CredentialCategory.proofOfOwnershipCards,
        );

  factory TezosAssociatedAddressModel.fromJson(Map<String, dynamic> json) =>
      _$TezosAssociatedAddressModelFromJson(json);

  @JsonKey(defaultValue: '')
  final String? associatedAddress;

  @JsonKey(defaultValue: '')
  final String? accountName;

  @override
  Map<String, dynamic> toJson() => _$TezosAssociatedAddressModelToJson(this);
}