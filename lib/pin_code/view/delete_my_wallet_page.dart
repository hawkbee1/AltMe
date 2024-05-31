import 'package:altme/app/shared/constants/image_strings.dart';
import 'package:altme/app/shared/constants/sizes.dart';
import 'package:altme/app/shared/widget/widget.dart';
import 'package:altme/credentials/cubit/credentials_cubit.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteMyWalletPage extends StatelessWidget {
  const DeleteMyWalletPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const DeleteMyWalletPage(),
      settings: const RouteSettings(name: '/deleteMyWalletPage'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const DeleteMyWalletView();
  }
}

class DeleteMyWalletView extends StatelessWidget {
  const DeleteMyWalletView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      title: l10n.walletBloced,
      titleAlignment: Alignment.topCenter,
      scrollView: false,
      body: Column(
        children: [
          const Spacer(
            flex: 8,
          ),
          Image.asset(
            ImageStrings.cardMissing,
            width: Sizes.icon80,
          ),
          const SizedBox(
            height: Sizes.spaceLarge,
          ),
          Text(
            l10n.deleteMyWalletForWrontPincodeTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(
            height: Sizes.spaceXSmall,
          ),
          Text(
            l10n.deleteMyWalletForWrontPincodeDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const Spacer(
            flex: 14,
          ),
          MyElevatedButton(
            text: l10n.deleteMyWallet,
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CredentialsCubit>().reset();
            },
          ),
        ],
      ),
    );
  }
}
