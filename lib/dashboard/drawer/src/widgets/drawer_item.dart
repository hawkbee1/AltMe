import 'package:altme/app/app.dart';

import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.title,
    this.subtitle,
    this.isDisabled = false,
    this.onTap,
    this.trailing,
  });

  final bool isDisabled;
  final Widget? trailing;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TransparentInkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Sizes.spaceNormal),
        margin: const EdgeInsets.all(Sizes.spaceXSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              Sizes.normalRadius,
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: isDisabled
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6)
                                : null,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        subtitle!,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: isDisabled
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6)
                                      : null,
                                ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.chevron_right,
                  size: Sizes.icon2x,
                  color: isDisabled
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
