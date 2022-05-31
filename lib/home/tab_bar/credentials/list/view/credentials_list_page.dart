import 'package:altme/app/app.dart';
import 'package:altme/home/home.dart';
import 'package:altme/home/tab_bar/credentials/list/view/search.dart';
import 'package:altme/theme/theme.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CredentialsListPage extends StatefulWidget {
  const CredentialsListPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CredentialsListPage> createState() => _CredentialsListPageState();
}

class _CredentialsListPageState extends State<CredentialsListPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext credentialListContext) {
    return BasePage(
      padding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.transparent,
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          var _credentialList = <CredentialModel>[];
          _credentialList = state.credentials;
          return Column(
            children: [
              const Search(),
              const SizedBox(height: 8),
              ...List.generate(
                _credentialList.length,
                (index) => CredentialsListPageItem(
                  credentialModel: _credentialList[index],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}