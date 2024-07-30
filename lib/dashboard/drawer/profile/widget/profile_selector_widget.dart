import 'package:altme/app/app.dart';
import 'package:altme/credentials/cubit/credentials_cubit.dart';
import 'package:altme/dashboard/profile/profile.dart';

import 'package:altme/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSelectorWidget extends StatelessWidget {
  const ProfileSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.read<ProfileCubit>().state.model;

    final walletContainsEnterpriseProfile =
        profile.walletType == WalletType.enterprise;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(Sizes.spaceSmall),
              margin: const EdgeInsets.all(Sizes.spaceXSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.all(
                  Radius.circular(Sizes.largeRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose your SSI profile or customize your own',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: ProfileType.values.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final profileType = ProfileType.values[index];

                      if (!walletContainsEnterpriseProfile &&
                          profileType == ProfileType.enterprise) {
                        return Container();
                      }

                      return Column(
                        children: [
                          ListTile(
                            onTap: () async {
                              await context
                                  .read<ProfileCubit>()
                                  .setProfile(profileType);
                              await context
                                  .read<CredentialsCubit>()
                                  .loadAllCredentials(
                                    blockchainType: context
                                        .read<WalletCubit>()
                                        .state
                                        .currentAccount!
                                        .blockchainType,
                                  );
                            },
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 0.5,
                              ),
                            ),
                            title: Text(
                              profileType.getTitle(
                                name: profile.enterpriseWalletName ?? '',
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            trailing: Icon(
                              state.model.profileType == profileType
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: Sizes.icon2x,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(
                              height: 0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.12),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
