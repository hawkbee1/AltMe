import 'package:altme/app/app.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class NetworkItem extends StatelessWidget {
  const NetworkItem({
    Key? key,
    required this.network,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final TezosNetwork network;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 0,
      leading: Checkbox(
        value: isSelected,
        fillColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.inversePrimary,
        ),
        checkColor: Theme.of(context).colorScheme.primary,
        onChanged: (_) => onPressed.call(),
        shape: const CircleBorder(),
      ),
      title: MyText(
        network.description,
        maxLines: 1,
        minFontSize: 12,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }
}