// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etherlink_network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EtherlinkNetwork _$EtherlinkNetworkFromJson(Map<String, dynamic> json) =>
    EtherlinkNetwork(
      networkname: json['networkname'] as String,
      apiUrl: json['apiUrl'] as String,
      rpcNodeUrl: json['rpcNodeUrl'],
      title: json['title'] as String,
      subTitle: json['subTitle'] as String,
      chainId: (json['chainId'] as num).toInt(),
      chain: json['chain'] as String,
      type: $enumDecode(_$BlockchainTypeEnumMap, json['type']),
      apiKey: json['apiKey'] as String? ?? '',
    );

Map<String, dynamic> _$EtherlinkNetworkToJson(EtherlinkNetwork instance) =>
    <String, dynamic>{
      'networkname': instance.networkname,
      'apiUrl': instance.apiUrl,
      'apiKey': instance.apiKey,
      'rpcNodeUrl': instance.rpcNodeUrl,
      'title': instance.title,
      'subTitle': instance.subTitle,
      'type': _$BlockchainTypeEnumMap[instance.type]!,
      'chainId': instance.chainId,
      'chain': instance.chain,
    };

const _$BlockchainTypeEnumMap = {
  BlockchainType.tezos: 'tezos',
  BlockchainType.ethereum: 'ethereum',
  BlockchainType.fantom: 'fantom',
  BlockchainType.polygon: 'polygon',
  BlockchainType.binance: 'binance',
  BlockchainType.etherlink: 'etherlink',
};
