import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/selective_disclosure/selective_disclosure.dart';
import 'package:altme/theme/theme.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _BaseItem extends StatefulWidget {
  const _BaseItem({
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  __BaseItemState createState() => __BaseItemState();
}

class __BaseItemState extends State<_BaseItem> {
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: !widget.enabled ? 0.33 : 1,
        child: GestureDetector(
          onTap: widget.onTap,
          child: IntrinsicHeight(child: widget.child),
        ),
      );
}

class CredentialsListPageItem extends StatelessWidget {
  const CredentialsListPageItem({
    super.key,
    required this.credentialModel,
    required this.onTap,
    this.selected,
    this.badgeCount = 0,
  });

  final CredentialModel credentialModel;
  final VoidCallback onTap;
  final bool? selected;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return badgeCount > 0
        ? badges.Badge(
            stackFit: StackFit.expand,
            badgeContent: Text(
              badgeCount.toString(),
              style: Theme.of(context).textTheme.badgeStyle,
              textAlign: TextAlign.center,
            ),
            position: badges.BadgePosition.topEnd(end: 10, top: 30),
            child: CredentialsDisplayItem(
              credentialModel: credentialModel,
              onTap: onTap,
              selected: selected,
            ),
          )
        : CredentialsDisplayItem(
            credentialModel: credentialModel,
            onTap: onTap,
            selected: selected,
          );
  }
}

class CredentialsDisplayItem extends StatelessWidget {
  const CredentialsDisplayItem({
    super.key,
    required this.credentialModel,
    required this.onTap,
    this.selected,
  });

  final CredentialModel credentialModel;
  final VoidCallback onTap;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return _BaseItem(
      enabled: true,
      onTap: onTap,
      child: selected == null
          ? DisplayCard(
              credentialModel: credentialModel,
              selected: selected,
            )
          : DisplaySelectionElement(
              credentialModel: credentialModel,
              selected: selected,
            ),
    );
  }
}

class DisplaySelectionElement extends StatelessWidget {
  const DisplaySelectionElement({
    super.key,
    required this.credentialModel,
    this.selected,
  });

  final CredentialModel credentialModel;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return CredentialSelectionPadding(
      child: Column(
        children: <Widget>[
          DisplayCard(
            credentialModel: credentialModel,
            selected: selected,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                selected! ? Icons.check_box : Icons.check_box_outline_blank,
                size: 25,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayCard extends StatelessWidget {
  const DisplayCard({
    super.key,
    required this.credentialModel,
    this.selected,
  });

  final CredentialModel credentialModel;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final profileSetting =
        context.read<ProfileCubit>().state.model.profileSetting;

    final credentialImage = SelectiveDisclosure(credentialModel).getPicture;

    return selected != null && credentialImage != null
        ? AspectRatio(
            aspectRatio: Sizes.credentialAspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                Sizes.credentialBorderRadius,
              ),
              child: CachedImageFromNetwork(
                credentialImage,
                fit: BoxFit.contain,
                width: double.infinity,
                bgColor: Colors.transparent,
                height: double.infinity,
                errorMessage: '',
                showLoading: false,
              ),
            ),
          )
        : CredentialDisplay(
            credentialModel: credentialModel,
            credDisplayType: CredDisplayType.List,
            profileSetting: profileSetting,
          );
  }
}
