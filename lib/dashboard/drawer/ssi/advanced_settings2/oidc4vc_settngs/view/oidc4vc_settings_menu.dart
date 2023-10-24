import 'dart:convert';

import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/material.dart';

class Oidc4vcSettingMenu extends StatelessWidget {
  const Oidc4vcSettingMenu({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/Oidc4vcSettingMenu'),
      builder: (_) => const Oidc4vcSettingMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Oidc4vcSettingMenuView();
  }
}

class Oidc4vcSettingMenuView extends StatelessWidget {
  const Oidc4vcSettingMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      title: l10n.oidc4vc_settings,
      useSafeArea: true,
      scrollView: true,
      titleAlignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceSmall),
      titleLeading: const BackLeadingButton(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SecurityLevelWidget(),
          const SixOrForUserPinWidget(),
          const DidKeyTypeWidget(),
          const SubjectSyntaxTypeWidget(),
          const CryptographicHolderBindingWidget(),
          DrawerItem(
            title: l10n.clientMetadata,
            onTap: () {
              final value = const JsonEncoder.withIndent('  ')
                  .convert(ConstantsJson.clientMetadata);
              Navigator.of(context).push<void>(
                JsonViewerPage.route(
                  title: l10n.clientMetadata,
                  data: value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}