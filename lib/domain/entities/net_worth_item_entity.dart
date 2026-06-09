import 'package:equatable/equatable.dart';

enum NetWorthType { asset, liability }

class NetWorthItemEntity extends Equatable {
  const NetWorthItemEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    this.category = 'Other',
  });

  final String id;
  final String name;
  final double amount;
  final NetWorthType type;
  final String category;

  NetWorthItemEntity copyWith({
    String? id,
    String? name,
    double? amount,
    NetWorthType? type,
    String? category,
  }) {
    return NetWorthItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, type, category];
}
