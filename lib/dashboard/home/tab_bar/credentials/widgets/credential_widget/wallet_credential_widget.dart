import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decode/jwt_decode.dart';

class WalletCredentialWidget extends StatelessWidget {
  const WalletCredentialWidget({
    super.key,
    required this.credentialModel,
  });

  final CredentialModel credentialModel;

  @override
  Widget build(BuildContext context) {
    return CredentialBaseWidget(
      cardBackgroundImagePath: ImageStrings.walletCertificate,
      issuerName: '',
      issuanceDate: UiDate.formatDateForCredentialCard(
        credentialModel.credentialPreview.issuanceDate,
      ),
      value: '',
      expirationDate: credentialModel.expirationDate == null
          ? '--'
          : UiDate.formatDateForCredentialCard(credentialModel.expirationDate!),
    );
  }
}

class WalletCredentialetailsWidget extends StatelessWidget {
  const WalletCredentialetailsWidget({
    super.key,
    required this.credentialModel,
  });

  final CredentialModel credentialModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleColor = Theme.of(context).colorScheme.titleColor;
    final valueColor = Theme.of(context).colorScheme.valueColor;

    final isDeveloperMode =
        context.read<ProfileCubit>().state.model.isDeveloperMode;

    final walletCredential = credentialModel
        .credentialPreview.credentialSubjectModel as WalletCredentialModel;

    final walletAttestationData = credentialModel.jwt;

    dynamic uri;
    dynamic idx;

    if (isDeveloperMode && walletAttestationData != null) {
      final payload = JWTDecode().parseJwt(walletAttestationData);
      final status = payload['status'];
      if (status != null && status is Map<String, dynamic>) {
        final statusList = status['status_list'];
        if (statusList != null && statusList is Map<String, dynamic>) {
          uri = statusList['uri'];
          idx = statusList['idx'];
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDeveloperMode)
          CredentialField(
            padding: const EdgeInsets.only(top: 10),
            title: l10n.publicKeyOfWalletInstance,
            value: walletCredential.publicKey ?? '',
            titleColor: titleColor,
            valueColor: valueColor,
            showVertically: false,
          ),
        CredentialField(
          padding: const EdgeInsets.only(top: 10),
          title: l10n.walletInstanceKey,
          value: walletCredential.walletInstanceKey ?? '',
          titleColor: titleColor,
          valueColor: valueColor,
          showVertically: false,
        ),
        CredentialField(
          padding: const EdgeInsets.only(top: 10),
          title: l10n.issuanceDate,
          value: UiDate.formatDateForCredentialCard(
            credentialModel.credentialPreview.issuanceDate,
          ),
          titleColor: titleColor,
          valueColor: valueColor,
          showVertically: false,
        ),
        CredentialField(
          padding: const EdgeInsets.only(top: 10),
          title: l10n.expirationDate,
          value: UiDate.formatDateForCredentialCard(
            credentialModel.credentialPreview.expirationDate,
          ),
          titleColor: titleColor,
          valueColor: valueColor,
          showVertically: false,
        ),
        if (context.read<ProfileCubit>().state.model.isDeveloperMode) ...[
          if (uri != null) ...[
            CredentialField(
              padding: const EdgeInsets.only(top: 10),
              title: l10n.statusList,
              value: uri.toString(),
              titleColor: titleColor,
              valueColor: valueColor,
              showVertically: false,
            ),
          ],
          if (idx != null) ...[
            CredentialField(
              padding: const EdgeInsets.only(top: 10),
              title: l10n.statusListIndex,
              value: idx.toString(),
              titleColor: titleColor,
              valueColor: valueColor,
              showVertically: false,
            ),
          ],
        ],
      ],
    );
  }
}
