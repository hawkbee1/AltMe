import 'package:altme/app/shared/widget/base/credential_field.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:flutter/material.dart';

class LabeledDisplayMappingWidget extends StatelessWidget {
  const LabeledDisplayMappingWidget({
    required this.displayMapping,
    required this.credentialModel,
    this.textColor,
    Key? key,
  }) : super(key: key);
  final DisplayMapping displayMapping;
  final CredentialModel credentialModel;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final object = displayMapping;
    if (object is LabeledDisplayMappingText) {
      return CredentialField(
        value: object.text,
        title: object.label,
        textColor: textColor,
      );
    }
    if (object is LabeledDisplayMappingPath) {
      final widgets = <Widget>[];
      for (final e in object.path) {
        final textList = getTextsFromCredential(e, credentialModel.data);
        for (final element in textList) {
          widgets.add(
            CredentialField(
              value: element,
              title: object.label,
              textColor: textColor,
            ),
          );
        }
      }

      if (widgets.isNotEmpty) {
        return Column(
          children: widgets,
        );
      }
      if (object.fallback != null) {
        return CredentialField(
          value: object.fallback ?? '',
          title: object.label,
          textColor: textColor,
        );
      }
    }
    return const SizedBox.shrink();
  }
}