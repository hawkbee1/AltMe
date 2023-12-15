import 'dart:async';

import 'package:altme/app/app.dart';
import 'package:altme/credentials/credentials.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/did/cubit/did_cubit.dart';
import 'package:altme/splash/helper_function/is_wallet_created.dart';
import 'package:altme/wallet/cubit/wallet_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:secure_storage/secure_storage.dart';

part 'splash_cubit.g.dart';
part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this.secureStorageProvider,
    required this.didCubit,
    required this.homeCubit,
    required this.walletCubit,
    required this.credentialsCubit,
    required this.client,
  }) : super(const SplashState()) {
    _getAppVersion();
  }

  final SecureStorageProvider secureStorageProvider;
  final DIDCubit didCubit;
  final HomeCubit homeCubit;
  final WalletCubit walletCubit;
  final CredentialsCubit credentialsCubit;
  final DioClient client;

  Future<void> initialiseApp() async {
    double counter = 0;

    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      counter = counter + 0.5;
      emit(state.copyWith(loadedValue: counter / 5));
      if (counter > 5) {
        timer.cancel();

        final bool hasWallet = await isWalletCreated(
          secureStorageProvider: secureStorageProvider,
          didCubit: didCubit,
          walletCubit: walletCubit,
          credentialsCubit: credentialsCubit,
        );

        if (hasWallet) {
          await homeCubit.emitHasWallet();
          emit(state.copyWith(status: SplashStatus.routeToPassCode));
          // if (Parameters.walletHandlesCrypto) {
          //   unawaited(
          //     homeCubit.periodicCheckRewardOnTezosBlockchain(),
          //   );
          // }
        } else {
          homeCubit.emitHasNoWallet();
          emit(state.copyWith(status: SplashStatus.routeToOnboarding));
        }
      }
    });
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String? savedVersion = await secureStorageProvider.get(
      SecureStorageKeys.version,
    );

    final String? savedBuildNumber = await secureStorageProvider.get(
      SecureStorageKeys.buildNumber,
    );

    var isNewVersion = false;

    if (savedVersion != null && savedBuildNumber != null) {
      if (savedVersion != packageInfo.version ||
          savedBuildNumber != packageInfo.buildNumber) {
        isNewVersion = true;
      }
    }

    await secureStorageProvider.set(
      SecureStorageKeys.version,
      packageInfo.version,
    );

    await secureStorageProvider.set(
      SecureStorageKeys.buildNumber,
      packageInfo.buildNumber,
    );

    emit(
      state.copyWith(
        versionNumber: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isNewVersion: isNewVersion,
        status: SplashStatus.idle,
      ),
    );
  }

  void disableWhatsNewPopUp() {
    emit(
      state.copyWith(
        isNewVersion: false,
        status: SplashStatus.idle,
      ),
    );
  }
}
