import 'package:altme/app/app.dart';
import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8,
    this.verticalSpacing = 15,
    this.elevation = 2,
    this.fontSize = 18,
  });

  const MyElevatedButton.icon({
    super.key,
    required this.text,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8,
    this.verticalSpacing = 15,
    this.elevation = 2,
    this.fontSize = 18,
  });

  final String text;
  final GestureTapCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double verticalSpacing;
  final double elevation;
  final double fontSize;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: icon == null
          ? ElevatedButton(
              style: elevatedStyleFrom(
                borderRadius: borderRadius,
                context: context,
                elevation: elevation,
                verticalSpacing: verticalSpacing,
                backgroundColor: backgroundColor,
                onPressed: onPressed,
              ),
              onPressed: onPressed,
              child: MyText(
                text.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            )
          : ElevatedButton.icon(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  textColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
                  BlendMode.srcIn,
                ),
                child: icon,
              ),
              style: elevatedStyleFrom(
                borderRadius: borderRadius,
                context: context,
                elevation: elevation,
                verticalSpacing: verticalSpacing,
                backgroundColor: backgroundColor,
                onPressed: onPressed,
              ),
              onPressed: onPressed,
              label: MyText(
                text.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
    );
  }
}

ButtonStyle elevatedStyleFrom({
  Color? backgroundColor,
  required double borderRadius,
  required double verticalSpacing,
  required double elevation,
  required BuildContext context,
  GestureTapCallback? onPressed,
}) {
  return ButtonStyle(
    elevation: WidgetStateProperty.all(elevation),
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(vertical: verticalSpacing),
    ),
    backgroundColor: WidgetStateProperty.all(
      onPressed == null
          ? Theme.of(context).colorScheme.outline
          : backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
    ),
    side: WidgetStatePropertyAll(
      BorderSide(
        color: onPressed == null
            ? Theme.of(context).colorScheme.outline
            : Theme.of(context).colorScheme.primaryContainer,
        width: 2,
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}

// @TODO: remove if buttons OK
class ElevatedButtonText extends StatelessWidget {
  const ElevatedButtonText({
    super.key,
    required this.text,
    this.textColor,
    this.fontSize = 18,
  });

  final String text;
  final Color? textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: textColor ?? Theme.of(context).colorScheme.onPrimary,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
