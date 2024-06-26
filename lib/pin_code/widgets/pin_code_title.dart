import 'package:flutter/material.dart';

class PinCodeTitle extends StatelessWidget {
  const PinCodeTitle({
    super.key,
    required this.title,
    required this.subTitle,
    required this.allowAction,
  });

  final String title;
  final String? subTitle;
  final bool allowAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: allowAction
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.error),
        ),
        if (subTitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subTitle!,
            style: allowAction
                ? Theme.of(context).textTheme.bodyLarge
                : Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
