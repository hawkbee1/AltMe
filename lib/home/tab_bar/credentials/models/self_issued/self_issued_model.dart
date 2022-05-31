import 'package:altme/app/shared/enum/type/credential_subject_type/credential_subject_type.dart';
import 'package:altme/home/home.dart';
import 'package:json_annotation/json_annotation.dart';

part 'self_issued_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SelfIssuedModel extends CredentialSubjectModel {
  SelfIssuedModel({
    required String id,
    this.address,
    this.familyName,
    this.givenName,
    String? type = 'SelfIssued',
    this.telephone,
    this.email,
    this.workFor,
    this.companyWebsite,
    this.jobTitle,
  }) : super(
          id: id,
          type: type,
          issuedBy: const Author('', ''),
          credentialSubjectType: CredentialSubjectType.selfIssued,
        );

  factory SelfIssuedModel.fromJson(Map<String, dynamic> json) =>
      _$SelfIssuedModelFromJson(json);

  final String? address;
  final String? familyName;
  final String? givenName;
  final String? telephone;
  final String? email;
  final String? workFor;
  final String? companyWebsite;
  final String? jobTitle;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (givenName != null && givenName!.isNotEmpty) 'givenName': givenName,
        if (familyName != null && familyName!.isNotEmpty)
          'familyName': familyName,
        if (telephone != null && telephone!.isNotEmpty) 'telephone': telephone,
        if (address != null && address!.isNotEmpty) 'address': address,
        'type': type,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (workFor != null && workFor!.isNotEmpty) 'workFor': workFor,
        if (companyWebsite != null && companyWebsite!.isNotEmpty)
          'companyWebsite': companyWebsite,
        if (jobTitle != null && jobTitle!.isNotEmpty) 'jobTitle': jobTitle,
      };
}