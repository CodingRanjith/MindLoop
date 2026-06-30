import 'package:equatable/equatable.dart';

class FinancialGoalEntity extends Equatable {
  const FinancialGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.icon = 'flag',
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String icon;

  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);

  double get completionPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  FinancialGoalEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? icon,
  }) {
    return FinancialGoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [id, name, targetAmount, currentAmount, targetDate, icon];
}
