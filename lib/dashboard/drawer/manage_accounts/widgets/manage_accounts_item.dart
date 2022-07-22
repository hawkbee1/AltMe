import 'package:altme/app/app.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:altme/wallet/model/model.dart';
import 'package:flutter/material.dart';

class ManageAccountsItem extends StatelessWidget {
  const ManageAccountsItem({
    Key? key,
    required this.cryptoAccountData,
    required this.listIndex,
    required this.onPressed,
    required this.onEditButtonPressed,
  }) : super(key: key);

  final CryptoAccountData cryptoAccountData;
  final int listIndex;
  final VoidCallback onPressed;
  final VoidCallback onEditButtonPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final walletAddressLength = cryptoAccountData.walletAddress.length;
    final walletAddressExtracted = walletAddressLength > 0
        ? '''${cryptoAccountData.walletAddress.substring(0, walletAddressLength - 16)} ... ${cryptoAccountData.walletAddress.substring(cryptoAccountData.walletAddress.length - 5)}'''
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.spaceSmall),
      padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.cardHighlighted,
        borderRadius: const BorderRadius.all(
          Radius.circular(Sizes.normalRadius),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.borderColor,
          width: 0.7,
        ),
      ),
      child: ListTile(
        onTap: onPressed,
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 0,
        title: Row(
          children: [
            Flexible(
              child: MyText(
                cryptoAccountData.name.trim().isEmpty
                    ? '${l10n.cryptoAccount} ${listIndex + 1}'
                    : cryptoAccountData.name,
                maxLines: 1,
                minFontSize: 12,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.accountsListItemTitle,
              ),
            ),
            const SizedBox(width: Sizes.spaceXSmall),
            InkWell(
              onTap: onEditButtonPressed,
              child: Icon(
                Icons.edit,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: Sizes.spaceXSmall),
            if (cryptoAccountData.isImported)
              Chip(
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(Sizes.smallRadius)),
                ),
                padding: EdgeInsets.zero,
                label: Text(
                  l10n.imported.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              )
          ],
        ),
        subtitle: MyText(
          walletAddressExtracted,
          style: Theme.of(context).textTheme.walletAddress,
        ),
      ),
    );
  }
}
