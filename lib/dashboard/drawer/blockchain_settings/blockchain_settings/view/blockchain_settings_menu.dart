import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlockchainSettingsMenu extends StatelessWidget {
  const BlockchainSettingsMenu({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const BlockchainSettingsMenu(),
      settings: const RouteSettings(name: '/BlockchainSettingsMenu'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const BlockchainSettingsView();
  }
}

class BlockchainSettingsView extends StatelessWidget {
  const BlockchainSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      backgroundColor: Theme.of(context).colorScheme.drawerBackground,
      useSafeArea: true,
      scrollView: true,
      titleAlignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceSmall),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BackLeadingButton(
            padding: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const DrawerLogo(),
          DrawerItem(
            title: l10n.manageAccounts,
            onTap: () {
              Navigator.of(context).push<void>(ManageAccountsPage.route());
            },
          ),
          DrawerItem(
            title: l10n.manageConnectedApps,
            onTap: () {
              Navigator.of(context).push<void>(
                ConnectedDappsPage.route(
                  walletAddress: context
                      .read<WalletCubit>()
                      .state
                      .currentAccount!
                      .walletAddress,
                ),
              );
            },
          ),
          DrawerItem(
            title: l10n.blockchainNetwork,
            onTap: () async {
              await Navigator.of(context).push<void>(ManageNetworkPage.route());
            },
          ),
        ],
      ),
    );
  }
}
