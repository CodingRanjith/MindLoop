import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class BudgetTransactionEntity extends Equatable {
  const BudgetTransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category = 'General',
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category;

  @override
  List<Object?> get props => [id, title, amount, type, date, category];
}
