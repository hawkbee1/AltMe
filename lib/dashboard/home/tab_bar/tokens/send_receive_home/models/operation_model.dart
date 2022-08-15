import 'package:altme/dashboard/dashboard.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'operation_model.g.dart';

@JsonSerializable()
class OperationModel extends Equatable {
  const OperationModel({
    required this.type,
    required this.id,
    required this.level,
    required this.timestamp,
    required this.block,
    required this.hash,
    required this.counter,
    required this.sender,
    required this.gasLimit,
    required this.gasUsed,
    required this.storageLimit,
    required this.storageUsed,
    required this.bakerFee,
    required this.storageFee,
    required this.allocationFee,
    required this.target,
    required this.amount,
    required this.status,
    required this.hasInternals,
  });

  factory OperationModel.fromJson(Map<String, dynamic> json) =>
      _$OperationModelFromJson(json);

  final String type;
  final int id;
  final int level;
  final String timestamp;
  final String block;
  final String hash;
  final int counter;
  final OperationAddressModel sender;
  final int gasLimit;
  final int gasUsed;
  final int storageLimit;
  final int storageUsed;
  final int bakerFee;
  final int storageFee;
  final int allocationFee;
  final OperationAddressModel target;
  final int amount;
  final String status;
  final bool hasInternals;

  Map<String, dynamic> toJson() => _$OperationModelToJson(this);

  @override
  List<Object?> get props => [
        type,
        id,
        level,
        timestamp,
        block,
        hash,
        counter,
        sender,
        gasLimit,
        gasUsed,
        storageLimit,
        storageUsed,
        bakerFee,
        storageFee,
        allocationFee,
        target,
        amount,
        status,
        hasInternals,
      ];
}
