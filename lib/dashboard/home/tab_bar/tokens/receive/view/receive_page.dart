import 'package:altme/app/app.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({
    Key? key,
    required this.accountAddress,
    required this.tokenSymbol,
  }) : super(key: key);

  static Route route({
    required String accountAddress,
    required String tokenSymbol,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/receivePage'),
      builder: (_) => ReceivePage(
        accountAddress: accountAddress,
        tokenSymbol: tokenSymbol,
      ),
    );
  }

  final String accountAddress;
  final String tokenSymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      scrollView: false,
      titleLeading: const BackLeadingButton(),
      body: BackgroundCard(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(Sizes.spaceSmall),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.spaceNormal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  '${l10n.receive} $tokenSymbol',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: Sizes.spaceXLarge,
                ),
                BackgroundCard(
                  padding: const EdgeInsets.all(Sizes.spaceNormal),
                  color: Theme.of(context).hoverColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Sizes.spaceSmall),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              Sizes.normalRadius,
                            ),
                          ),
                        ),
                        child: QrImage(
                          data: accountAddress,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: Sizes.spaceNormal,
                      ),
                      Text(
                        accountAddress,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: Sizes.spaceSmall,
                ),
                // TODO(Taleb): pass token symbol to l10n to return translation
                //depends on variable ( How to pass variable to l10n object?)
                Text(
                  l10n.sendOnlyXtzToThisAddressDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption2,
                ),
                const SizedBox(
                  height: Sizes.spaceXLarge,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CopyButton(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: accountAddress,
                          ),
                        );
                        AlertMessage.showStringMessage(
                          context: context,
                          message: l10n.copiedToClipboard,
                          messageType: MessageType.success,
                        );
                      },
                    ),
                    const SizedBox(
                      width: Sizes.space2XLarge,
                    ),
                    ShareButton(
                      onTap: () {
                        final box = context.findRenderObject() as RenderBox?;
                        final subject = l10n.shareWith;

                        Share.share(
                          accountAddress,
                          subject: subject,
                          sharePositionOrigin:
                              box!.localToGlobal(Offset.zero) & box.size,
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
