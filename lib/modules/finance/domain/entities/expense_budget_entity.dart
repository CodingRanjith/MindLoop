import 'package:equatable/equatable.dart';

enum ExpenseBudgetPeriod { weekly, monthly }

class ExpenseBudgetEntity extends Equatable {
  const ExpenseBudgetEntity({
    required this.id,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final double amount;
  final ExpenseBudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  ExpenseBudgetEntity copyWith({
    String? id,
    double? amount,
    ExpenseBudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseBudgetEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [id, amount, period, startDate, endDate];
}

enum BudgetAlertLevel { none, warning, exceeded }

class ExpenseBudgetStatus extends Equatable {
  const ExpenseBudgetStatus({
    required this.period,
    required this.budgetAmount,
    required this.spent,
    required this.remaining,
    required this.usagePercent,
    required this.alertLevel,
  });

  final ExpenseBudgetPeriod period;
  final double budgetAmount;
  final double spent;
  final double remaining;
  final double usagePercent;
  final BudgetAlertLevel alertLevel;

  @override
  List<Object?> get props => [period, budgetAmount, spent, remaining, usagePercent, alertLevel];
}
