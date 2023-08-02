import 'dart:convert';

import 'package:credential_manifest/credential_manifest.dart';
import 'package:dio/dio.dart';
import 'package:json_path/json_path.dart';

Future<CredentialManifest> getCredentialManifest(
  Dio client,
  String baseUrl,
  String credentialTypeOrId,
  bool schemaForType,
) async {
  final dynamic wellKnown = await client.get<String>(
    '$baseUrl/.well-known/openid-configuration',
  );
  final JsonPath credentialManifestPath = JsonPath(
    r'$..credential_manifests[?(@.id)]',
  );

  /// select first credential manifest
  final credentialManifestMap = credentialManifestPath
      .read(jsonDecode(wellKnown.data as String))
      .first
      .value as Map<String, dynamic>;

  /// create credentialManisfest object
  final credentialManifest = CredentialManifest.fromJson(
    credentialManifestMap,
  );

  final String key = schemaForType ? 'schema' : 'id';

  /// select wanted output desciptor
  final JsonPath outputDescriptorPath = JsonPath(
    // ignore: prefer_interpolation_to_compose_strings
    r'$..output_descriptors[?(@.' + key + '=="' + credentialTypeOrId + '")]',
  );

  /// There are some possible issues with this way of filtering :-/
  final outputDescriptorList =
      outputDescriptorPath.read(jsonDecode(wellKnown.data as String));
  if (outputDescriptorList.isNotEmpty) {
    final Map<String, dynamic> outputDescriptorMap =
        outputDescriptorList.first.value as Map<String, dynamic>;
    final OutputDescriptor outputDescriptor =
        OutputDescriptor.fromJson(outputDescriptorMap);
    final CredentialManifest sanitizedCredentialManifest =
        credentialManifest.copyWith(outputDescriptors: [outputDescriptor]);
    return sanitizedCredentialManifest;
  } else {
    return credentialManifest;
  }
}
