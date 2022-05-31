import 'package:altme/app/app.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    required this.title,
    this.subtitle,
    required this.yes,
    required this.no,
    this.icon = IconStrings.cardReceive,
    this.dialogColor,
    this.bgColor,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final String yes;
  final String no;
  final Color? dialogColor;
  final Color? bgColor;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final color = dialogColor ?? Theme.of(context).colorScheme.primary;
    final background = bgColor ?? Theme.of(context).colorScheme.background;
    return AlertDialog(
      backgroundColor: background,
      contentPadding: const EdgeInsets.only(
        top: 24,
        bottom: 16,
        left: 24,
        right: 24,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(
            AssetImage(icon),
            size: 50,
            color: color,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style:
                Theme.of(context).textTheme.dialogTitle.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .dialogSubtitle
                  .copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: MyOutlinedButton(
                  text: no,
                  verticalSpacing: 8,
                  fontSize: 13,
                  borderColor: color,
                  textColor: color,
                  backgroundColor: background,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MyElevatedButton(
                  text: yes,
                  verticalSpacing: 8,
                  backgroundColor: color,
                  textColor: background,
                  fontSize: 13,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}