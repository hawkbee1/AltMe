import 'package:altme/dashboard/home/home.dart';
import 'package:altme/dashboard/home/tab_bar/credentials/models/credential_subject/credential_subject_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'etherlink_associated_address_credential.g.dart';

@JsonSerializable(explicitToJson: true)
class EtherlinkAssociatedAddressCredential {
  EtherlinkAssociatedAddressCredential({
    required this.id,
    required this.issuer,
    required this.issuanceDate,
    required this.credentialSubjectModel,
    this.context = _context,
    this.type = _type,
  });

  factory EtherlinkAssociatedAddressCredential.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$EtherlinkAssociatedAddressCredentialFromJson(json);

  @JsonKey(name: '@context', defaultValue: _context)
  final List<dynamic> context;
  final String id;
  @JsonKey(defaultValue: _type)
  final List<String> type;
  @JsonKey(name: 'credentialSubject')
  final CredentialSubjectModel credentialSubjectModel;
  final String issuer;
  final String issuanceDate;

  Map<String, dynamic> toJson() =>
      _$EtherlinkAssociatedAddressCredentialToJson(this);

  static const List<String> _type = [
    'VerifiableCredential',
    'EtherlinkAssociatedAddress',
  ];

  static const List<dynamic> _context = <dynamic>[
    'https://www.w3.org/2018/credentials/v1',
    {
      'EtherlinkAssociatedAddress': {
        '@id': 'https://github.com/TalaoDAO/context#etherlinkassociatedaddress',
        '@context': {
          '@version': 1.1,
          '@protected': true,
          'id': '@id',
          'type': '@type',
          'schema': 'https://schema.org/',
          'accountName': 'schema:identifier',
          'associatedAddress':
              'https://github.com/TalaoDAO/context#associatedaddress',
          'cryptoWalletSignature': 'schema:identifier',
          'cryptoWalletPayload': 'schema:identifier',
          'issuedBy': {
            '@id': 'schema:issuedBy',
            '@context': {
              '@version': 1.1,
              '@protected': true,
              'schema': 'https://schema.org/',
              'name': 'schema:legalName',
              'logo': {'@id': 'schema:logo', '@type': '@id'},
            },
          },
        },
      },
    }
  ];
}
