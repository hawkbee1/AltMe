import 'package:altme/app/app.dart';
import 'package:altme/issuer_websites_page/issuer_websites.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class GetCardsWidget extends StatelessWidget {
  const GetCardsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(
          IssuerWebsitesPage.route(null),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              l10n.getCards.toUpperCase(),
              style: Theme.of(context).textTheme.getCardsButton,
            ),
            const SizedBox(width: 8),
            Image.asset(
              IconStrings.walletAdd,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}