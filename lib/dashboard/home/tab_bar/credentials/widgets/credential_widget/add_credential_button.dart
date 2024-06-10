import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCredentialButton extends StatelessWidget {
  const AddCredentialButton({
    super.key,
    required this.credentialCategory,
  });

  final CredentialCategory credentialCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TransparentInkWell(
      onTap: () {
        if (credentialCategory == CredentialCategory.blockchainAccountsCards) {
          Navigator.of(context).push<void>(ChooseAddAccountMethodPage.route());
        } else {
          context.read<DashboardCubit>().onPageChanged(1);
        }
      },
      child: BackgroundCard(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              IconStrings.addSquare,
              width: Sizes.icon2x,
              height: Sizes.icon3x,
            ),
            Text(
              l10n.addCards,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
