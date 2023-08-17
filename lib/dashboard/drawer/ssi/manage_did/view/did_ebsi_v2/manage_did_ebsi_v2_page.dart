import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/secure_storage.dart';

class ManageDidEbsiV2Page extends StatefulWidget {
  const ManageDidEbsiV2Page({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ManageDidEbsiV2Page(),
      settings: const RouteSettings(name: '/ManageDidEbsiV2Page'),
    );
  }

  @override
  State<ManageDidEbsiV2Page> createState() => _ManageDidEbsiPageState();
}

class _ManageDidEbsiPageState extends State<ManageDidEbsiV2Page> {
  Future<String> getDid() async {
    const oidc4vcType = OIDC4VCType.EBSIV2;

    final oidc4vc = oidc4vcType.getOIDC4VC;
    final mnemonic = await getSecureStorage.get(SecureStorageKeys.ssiMnemonic);

    final privateKey = await oidc4vc.privateKeyFromMnemonic(
      mnemonic: mnemonic!,
      indexValue: oidc4vcType.indexValue,
    );

    final (did, _) = await getDidAndKid(
      oidc4vcType: oidc4vcType,
      privateKey: privateKey,
    );

    return did;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      title: l10n.manageEbsiV2DecentralizedId,
      titleAlignment: Alignment.topCenter,
      scrollView: false,
      titleLeading: const BackLeadingButton(),
      body: BackgroundCard(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(Sizes.spaceSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            FutureBuilder<String>(
              future: getDid(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    final did = snapshot.data!;
                    return Did(did: did);
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  case ConnectionState.active:
                    return const SizedBox();
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizes.spaceNormal),
              child: Divider(),
            ),
            DidPrivateKey(route: DidEbsiV2PrivateKeyPage.route()),
          ],
        ),
      ),
    );
  }
}
