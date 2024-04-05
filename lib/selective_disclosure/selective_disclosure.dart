import 'dart:convert';

import 'package:altme/dashboard/home/tab_bar/credentials/models/credential_model/credential_model.dart';
import 'package:altme/selective_disclosure/selective_disclosure.dart';
import 'package:json_path/json_path.dart';
import 'package:oidc4vc/oidc4vc.dart';
export 'model/model.dart';

class SelectiveDisclosure {
  SelectiveDisclosure(this.credentialModel);
  final CredentialModel credentialModel;

  Map<String, dynamic> get claims {
    final credentialSupported = credentialModel.credentialSupported;

    var claims = credentialSupported?['claims'];

    if (claims == null || claims is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }

    final order = credentialSupported?['order'];

    if (order != null && order is List<dynamic>) {
      final orderList = order.map((e) => e.toString()).toList();

      final orderedClaims = <String, dynamic>{};
      final remainingClaims = <String, dynamic>{};

      // Order elements based on the order list
      for (final key in orderList) {
        if (claims.containsKey(key)) {
          orderedClaims[key] = claims[key];
        }
      }

      // Add remaining elements to the end of the ordered map
      claims.forEach((key, value) {
        if (!orderedClaims.containsKey(key)) {
          remainingClaims[key] = value;
        }
      });

      orderedClaims.addAll(remainingClaims);

      claims = orderedClaims;
    }

    return claims;
  }

  Map<String, dynamic> get extractedValuesFromJwt {
    final extractedValues = <String, dynamic>{};
    for (final element in disclosureToContent.entries.toList()) {
      try {
        final lisString = jsonDecode(element.value.toString());
        if (lisString is List) {
          if (lisString.length == 3) {
            /// '["Qg_O64zqAxe412a108iroA", "phone_number", "+81-80-1234-5678"]'
            extractedValues[lisString[1].toString()] = lisString[2];
          } else if (lisString.length == 2) {
            /// '["Qg_O64zqAxe412a108iroA", "DE']

            extractedValues[lisString[0].toString()] = lisString[1];
          } else {
            throw Exception();
          }
        }
      } catch (e) {
        throw Exception();
      }
    }
    return extractedValues;
  }

  List<String> get disclosureFromJWT {
    final encryptedValues = credentialModel.jwt
        ?.split('~')
        .where((element) => element.isNotEmpty)
        .toList();

    if (encryptedValues != null) {
      encryptedValues.removeAt(0);

      return encryptedValues;
    }
    return [];
  }

  Map<String, dynamic> get disclosureToContent {
    final data = <String, dynamic>{};

    for (var element in disclosureFromJWT) {
      try {
        while (element.length % 4 != 0) {
          element += '=';
        }

        final decryptedData = utf8.decode(base64Decode(element));

        if (decryptedData.isNotEmpty) {
          data[element] = decryptedData;
        }
      } catch (e) {
        //
      }
    }

    return data;
  }

  List<String> get contents {
    final contents = <String>[];
    for (final element in disclosureToContent.entries.toList()) {
      contents.add(element.value.toString());
    }
    return contents;
  }

  String? get getPicture {
    if (credentialModel.format.toString() != VCFormatType.vcSdJWT.value) {
      return null;
    }

    final credentialSupported = credentialModel.credentialSupported;
    if (credentialSupported == null) return null;

    final claims = credentialSupported['claims'];
    if (claims is! Map<String, dynamic>) return null;

    final picture = claims['picture'];
    if (picture == null) return null;
    if (picture is! Map<String, dynamic>) return null;

    final valueType = picture['value_type'];
    if (valueType == null) return null;

    if (valueType == 'image/jpeg') {
      final List<ClaimsData> claimsData = getClaimsData(key: 'picture');

      if (claimsData.isEmpty) return null;
      return claimsData[0].data;
    } else {
      return null;
    }
  }

  List<ClaimsData> getClaimsData({
    required String key,
  }) {
    dynamic data;
    final value = <ClaimsData>[];
    final JsonPath dataPath = JsonPath(
      // ignore: prefer_interpolation_to_compose_strings
      r'$..' + key,
    );

    try {
      final uncryptedDataPath = dataPath.read(extractedValuesFromJwt).first;
      data = uncryptedDataPath.value;

      value.add(
        ClaimsData(
          isfromDisclosureOfJWT: true,
          data: data.toString(),
        ),
      );
    } catch (e) {
      try {
        final credentialModelPath = dataPath.read(credentialModel.data).first;
        data = credentialModelPath.value;

        value.add(
          ClaimsData(
            isfromDisclosureOfJWT: false,
            data: data.toString(),
          ),
        );
      } catch (e) {
        data = null;
      }
    }

    try {
      if (data != null && data is List<dynamic>) {
        value.clear();
        for (final ele in data) {
          if (ele is String) {
            value.add(
              ClaimsData(
                isfromDisclosureOfJWT: false,
                data: ele,
              ),
            );
          } else if (ele is Map) {
            final threeDotValue = ele['...'];

            if (threeDotValue != null) {
              for (final element in contents) {
                final oidc4vc = OIDC4VC();
                final sh256Hash = oidc4vc.sh256HashOfContent(element);

                if (sh256Hash == threeDotValue) {
                  if (element.startsWith('[') && element.endsWith(']')) {
                    final trimmedElement =
                        element.substring(1, element.length - 1).split(',');

                    value.add(
                      ClaimsData(
                        isfromDisclosureOfJWT: true,
                        data: trimmedElement.last.replaceAll('"', ''),
                        threeDotValue: threeDotValue.toString(),
                      ),
                    );
                  }
                }
              }
            }
          }
        }
        return value;
      }
    } catch (e) {
      return value;
    }

    return value;
  }
}
