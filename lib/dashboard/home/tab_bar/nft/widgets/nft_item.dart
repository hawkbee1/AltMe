import 'package:altme/app/app.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class NftItem extends StatelessWidget {
  const NftItem({
    Key? key,
    required this.assetUrl,
    required this.description,
    required this.assetValue,
    required this.id,
    this.onClick,
  }) : super(key: key);

  final String assetUrl;
  final String description;
  final String assetValue;
  final String id;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: BackgroundCard(
        color: Theme.of(context).colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedImageFromNetwork(
                  assetUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            MyText(
              '$description $id',
              maxLines: 1,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}