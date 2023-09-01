import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DIDEdDSAPrivateKeyPage extends StatelessWidget {
  const DIDEdDSAPrivateKeyPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const DIDEdDSAPrivateKeyPage(),
      settings: const RouteSettings(name: '/DIDEdDSAPrivateKeyPage'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DIDPrivateKeyCubit>.value(
      value: context.read<DIDPrivateKeyCubit>(),
      child: const DIDPrivateKeyView(),
    );
  }
}

class DIDPrivateKeyView extends StatefulWidget {
  const DIDPrivateKeyView({super.key});

  @override
  State<DIDPrivateKeyView> createState() => _DIDPrivateKeyViewState();
}

class _DIDPrivateKeyViewState extends State<DIDPrivateKeyView>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DIDPrivateKeyCubit>().initialize());

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    final Tween<double> rotationTween = Tween(begin: 20, end: 0);

    animation = rotationTween.animate(animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
        }
      });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      scrollView: false,
      title: l10n.decentralizedIDKey,
      titleAlignment: Alignment.topCenter,
      titleLeading: const BackLeadingButton(),
      secureScreen: true,
      body: BackgroundCard(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              l10n.didPrivateKey,
              style: Theme.of(context).textTheme.title,
            ),
            const SizedBox(
              height: Sizes.spaceNormal,
            ),
            BlocBuilder<DIDPrivateKeyCubit, String>(
              builder: (context, state) {
                return Column(
                  children: [
                    Text(
                      state,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Sizes.spaceXLarge),
                    CopyButton(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: state),
                        );
                        AlertMessage.showStateMessage(
                          context: context,
                          stateMessage: StateMessage.success(
                            stringMessage: l10n.copiedToClipboard,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    return Text(
                      timeFormatter(timeInSecond: animation.value.toInt()),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}