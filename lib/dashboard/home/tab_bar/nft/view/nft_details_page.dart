import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class NftDetailsPage extends StatelessWidget {
  const NftDetailsPage({
    Key? key,
    required this.nftModel,
  }) : super(key: key);

  final NftModel nftModel;

  static Route route({required NftModel nftModel}) {
    return MaterialPageRoute<void>(
      builder: (_) => NftDetailsPage(
        nftModel: nftModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NftDetailsView(
      nftModel: nftModel,
    );
  }
}

class NftDetailsView extends StatefulWidget {
  const NftDetailsView({
    Key? key,
    required this.nftModel,
  }) : super(key: key);

  final NftModel nftModel;

  @override
  State<NftDetailsView> createState() => _NftDetailsViewState();
}

class _NftDetailsViewState extends State<NftDetailsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      title: l10n.nftDetails,
      titleLeading: const BackLeadingButton(),
      scrollView: false,
      body: BackgroundCard(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(Sizes.spaceNormal),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                child: CachedImageFromNetwork(
                  widget.nftModel.displayUrl,
                  fit: BoxFit.fill,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(Sizes.largeRadius),
                  ),
                ),
              ),
              const SizedBox(
                height: Sizes.spaceSmall,
              ),
              MyText(
                '${widget.nftModel.name} ${widget.nftModel.id}',
                style: Theme.of(context).textTheme.headline6,
                maxLines: 1,
                minFontSize: 16,
              ),
              const SizedBox(
                height: Sizes.spaceNormal,
              ),
              if (widget.nftModel.description?.contains('<p>') ?? false)
                Html(data: widget.nftModel.description ?? '')
              else
                Text(
                  widget.nftModel.description ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
            ],
          ),
        ),
      ),
      navigation: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceSmall),
          child: MyGradientButton(
            text: l10n.send,
            onPressed: null,
          ),
        ),
      ),
    );
  }
}