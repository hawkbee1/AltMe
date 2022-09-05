import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class TermsOfUseAndLicences extends StatelessWidget {
  const TermsOfUseAndLicences({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.termsOfUseAndLicenses,
          style: Theme.of(context).textTheme.drawerMenu,
        ),
        const SizedBox(height: 5),
        BackgroundCard(
          color: Theme.of(context).colorScheme.drawerSurface,
          child: Column(
            children: [
              DrawerItem(
                icon: IconStrings.terms,
                title: l10n.termsOfUse,
                onTap: () =>
                    Navigator.of(context).push<void>(TermsPage.route()),
              ),
              const DrawerItemDivider(),
              DrawerItem(
                icon: IconStrings.terms,
                title: l10n.licenses,
                onTap: () =>
                    Navigator.of(context).push<void>(LicensesPage.route()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}