import 'dart:convert';

import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
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
    return BasePage(
      title: 'OIDC4VC Settings',
      useSafeArea: true,
      scrollView: true,
      titleAlignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceSmall),
      titleLeading: const BackLeadingButton(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SecurityLevelWidget(),
          const DidKeyTypeWidget(),
          const DraftTypeWidget(),
          const CryptographicHolderBindingWidget(),
          const ScopeParameterWidget(),
          const ClientAuthenticationWidget(),
          const ClientTypeWidget(),
          const ConfidentialClientWidget(),
          const VCFormatWidget(),
          const ProofTypeWidget(),
          const ProofHeaderWidget(),
          const PushAuthorizationRequesWidget(),
          const StatusListCachingWidget(),
          DrawerItem(
            title: 'Wallet metadata for issuers',
            onTap: () {
              final value = const JsonEncoder.withIndent('  ').convert(
                ConstantsJson.walletMetadataForIssuers,
              );
              Navigator.of(context).push<void>(
                JsonViewerPage.route(
                  title: 'Wallet metadata for issuers',
                  data: value,
                ),
              );
            },
          ),
          DrawerItem(
            title: 'Wallet metadata for verifiers',
            onTap: () {
              final value = const JsonEncoder.withIndent('  ').convert(
                ConstantsJson.walletMetadataForVerifiers,
              );
              Navigator.of(context).push<void>(
                JsonViewerPage.route(
                  title: 'Wallet metadata for verifiers',
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
