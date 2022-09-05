import 'package:altme/app/app.dart';
import 'package:altme/dashboard/home/tab_bar/tokens/tokens.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class ConfirmDetailsCard extends StatelessWidget {
  const ConfirmDetailsCard({
    Key? key,
    required this.amount,
    required this.amountUsdValue,
    required this.symbol,
    required this.networkFee,
    this.onEditButtonPressed,
  }) : super(key: key);

  final double amount;
  final double amountUsdValue;
  final String symbol;
  final NetworkFeeModel networkFee;
  final VoidCallback? onEditButtonPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(Sizes.spaceSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(Sizes.normalRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                l10n.amount,
                style: Theme.of(context).textTheme.caption,
              ),
              const Spacer(),
              Text(
                '${amount.toStringAsFixed(6).formatNumber()} $symbol',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          _buildDivider(context),
          Row(
            children: [
              Text(
                l10n.networkFee,
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(
                width: Sizes.spaceXSmall,
              ),
              EditButton(
                onTap: onEditButtonPressed,
              ),
              const Spacer(),
              Text(
                '''${networkFee.fee.toStringAsFixed(6).formatNumber()} ${networkFee.tokenSymbol}''',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          _buildDivider(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.totalAmount,
                style: Theme.of(context).textTheme.caption,
              ),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${amount.toStringAsFixed(6).formatNumber()} $symbol',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    r'$' + amountUsdValue.toStringAsFixed(2).formatNumber(),
                    style: Theme.of(context).textTheme.caption2,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.spaceSmall,
      ),
      child: Divider(
        height: 0.1,
        color: Theme.of(context).colorScheme.borderColor,
      ),
    );
  }
}