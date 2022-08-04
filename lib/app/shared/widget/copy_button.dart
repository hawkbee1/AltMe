import 'package:altme/app/app.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class CopyButton extends StatelessWidget {
  const CopyButton({Key? key, this.onTap}) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            IconStrings.copy,
            width: Sizes.icon2x,
          ),
          const SizedBox(
            height: Sizes.space2XSmall,
          ),
          Text(
            l10n.copy,
            style: Theme.of(context).textTheme.title,
          ),
        ],
      ),
    );
  }
}