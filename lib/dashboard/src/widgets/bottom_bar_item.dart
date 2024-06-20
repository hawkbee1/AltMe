import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class BottomBarItem extends StatelessWidget {
  const BottomBarItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.isSelected,
    this.badgeCount = 0,
  });

  final String text;
  final String icon;
  final VoidCallback onTap;
  final bool isSelected;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            badges.Badge(
              showBadge: badgeCount > 0,
              badgeContent: Text(
                badgeCount.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: ImageIcon(
                  AssetImage(icon),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
            ),
            Text(
              text.toUpperCase(),
              softWrap: false,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
