import 'package:mindloop/domain/entities/budget_transaction_entity.dart';

class BudgetTransactionModel {
  BudgetTransactionModel({
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
  final String type;
  final DateTime date;
  final String category;

  factory BudgetTransactionModel.fromEntity(BudgetTransactionEntity entity) {
    return BudgetTransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type.name,
      date: entity.date,
      category: entity.category,
    );
  }

  BudgetTransactionEntity toEntity() {
    return BudgetTransactionEntity(
      id: id,
      title: title,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      date: date,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'date': date.toIso8601String(),
        'category': category,
      };

  factory BudgetTransactionModel.fromJson(Map<String, dynamic> json) {
    return BudgetTransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String? ?? 'General',
    );
  }
}
