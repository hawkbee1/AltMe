import 'package:altme/app/shared/widget/base/credential_field.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:flutter/material.dart';

class LabeledDisplayMappingWidget extends StatelessWidget {
  const LabeledDisplayMappingWidget({
    required this.displayMapping,
    required this.credentialModel,
    this.titleColor,
    this.valueColor,
    Key? key,
  }) : super(key: key);
  final DisplayMapping displayMapping;
  final CredentialModel credentialModel;
  final Color? titleColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final object = displayMapping;
    if (object is LabeledDisplayMappingText) {
      return CredentialField(
        value: object.text,
        title: object.label,
        titleColor: titleColor,
        valueColor: valueColor,
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
              titleColor: titleColor,
              valueColor: valueColor,
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
          titleColor: titleColor,
          valueColor: valueColor,
        );
      }
    }
    return const SizedBox.shrink();
  }
}