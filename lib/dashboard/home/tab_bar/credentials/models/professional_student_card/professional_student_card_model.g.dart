// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professional_student_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfessionalStudentCardModel _$ProfessionalStudentCardModelFromJson(
        Map<String, dynamic> json) =>
    ProfessionalStudentCardModel(
      recipient: json['recipient'] == null
          ? null
          : ProfessionalStudentCardRecipient.fromJson(
              json['recipient'] as Map<String, dynamic>),
      expires: json['expires'] as String? ?? '',
      id: json['id'] as String?,
      type: json['type'],
      issuedBy: CredentialSubjectModel.fromJsonAuthor(json['issuedBy']),
      offeredBy: CredentialSubjectModel.fromJsonAuthor(json['offeredBy']),
    );

Map<String, dynamic> _$ProfessionalStudentCardModelToJson(
    ProfessionalStudentCardModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'type': instance.type,
    'issuedBy': instance.issuedBy?.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('offeredBy', instance.offeredBy?.toJson());
  val['recipient'] = instance.recipient?.toJson();
  val['expires'] = instance.expires;
  return val;
}
