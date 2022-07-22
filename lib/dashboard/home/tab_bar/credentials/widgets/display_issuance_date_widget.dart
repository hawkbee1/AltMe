import 'package:altme/app/app.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class DisplayIssuanceDateWidget extends StatelessWidget {
  const DisplayIssuanceDateWidget({
    this.issuanceDate,
    this.textColor,
    Key? key,
  }) : super(key: key);
  final String? issuanceDate;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = issuanceDate;

    if (date != null) {
      return Row(
        children: [
          Expanded(
            flex: 6,
            child: MyText(
              '${l10n.issuanceDate}: ',
              style: textColor == null
                  ? Theme.of(context).textTheme.credentialFieldTitle
                  : Theme.of(context)
                      .textTheme
                      .credentialFieldTitle
                      .copyWith(color: textColor),
            ),
          ),
          Expanded(
            flex: 4,
            child: MyText(
              UiDate.displayDate(l10n, date),
              style: textColor == null
                  ? Theme.of(context)
                      .textTheme
                      .credentialFieldTitle
                      .copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context)
                      .textTheme
                      .credentialFieldTitle
                      .copyWith(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}