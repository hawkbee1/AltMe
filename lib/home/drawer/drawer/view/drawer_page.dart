import 'package:altme/app/app.dart';
import 'package:altme/home/home.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DrawerView();
  }
}

class DrawerView extends StatelessWidget {
  const DrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final profileModel = context.read<ProfileCubit>().state.model;

    final firstName = profileModel.firstName;
    final lastName = profileModel.lastName;
    final isEnterprise = profileModel.isEnterprise;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.drawerBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const DrawerCloseButton(),
              const SizedBox(height: 20),
              const AltMeLogo(size: Sizes.logoLarge),
              if (firstName.isNotEmpty || lastName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: MyText(
                    '$firstName $lastName',
                    style: Theme.of(context).textTheme.infoTitle,
                  ),
                ),
              DrawerItem(
                icon: IconStrings.reset,
                title: l10n.resetWalletButton,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => ConfirmDialog(
                          title: l10n.resetWalletConfirmationText,
                          yes: l10n.showDialogYes,
                          no: l10n.showDialogNo,
                          dialogColor: Theme.of(context).colorScheme.error,
                          icon: IconStrings.trash,
                        ),
                      ) ??
                      false;
                  if (confirm) {
                    await context.read<WalletCubit>().resetWallet();
                  }
                },
              ),
              DrawerItem(
                icon: IconStrings.restore,
                title: l10n.restoreCredential,
                trailing: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: l10n.recoveryWarningDialogTitle,
                          subtitle:
                              l10n.recoveryCredentialWarningDialogSubtitle,
                          yes: l10n.showDialogYes,
                          no: l10n.showDialogNo,
                        ),
                      ) ??
                      false;

                  if (confirm) {
                    await Navigator.of(context)
                        .push<void>(RecoveryCredentialPage.route());
                  }
                },
              ),
              DrawerItem(
                icon: IconStrings.terms,
                title: l10n.privacyTitle,
                trailing: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () =>
                    Navigator.of(context).push<void>(PrivacyPage.route()),
              ),
              DrawerItem(
                icon: IconStrings.terms,
                title: l10n.onBoardingTosTitle,
                trailing: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () =>
                    Navigator.of(context).push<void>(TermsPage.route()),
              ),
              if (isEnterprise)
                const SizedBox.shrink()
              else
                DrawerItem(
                  icon: IconStrings.key,
                  title: l10n.recoveryKeyTitle,
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: l10n.recoveryWarningDialogTitle,
                            subtitle: l10n.recoveryWarningDialogSubtitle,
                            yes: l10n.showDialogYes,
                            no: l10n.showDialogNo,
                          ),
                        ) ??
                        false;

                    if (confirm) {
                      await Navigator.of(context)
                          .push<void>(RecoveryKeyPage.route());
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}