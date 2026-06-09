import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';

class BudgetTransactionModel {
  BudgetTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category = 'General',
    this.notes = '',
    this.tags = const [],
    this.paymentMethod = 'upi',
    this.isRecurring = false,
    this.receiptPath,
    this.incomeSource,
  });

  final String id;
  final String title;
  final double amount;
  final String type;
  final DateTime date;
  final String category;
  final String notes;
  final List<String> tags;
  final String paymentMethod;
  final bool isRecurring;
  final String? receiptPath;
  final String? incomeSource;

  factory BudgetTransactionModel.fromEntity(BudgetTransactionEntity entity) {
    return BudgetTransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type.name,
      date: entity.date,
      category: entity.category,
      notes: entity.notes,
      tags: List<String>.from(entity.tags),
      paymentMethod: entity.paymentMethod.name,
      isRecurring: entity.isRecurring,
      receiptPath: entity.receiptPath,
      incomeSource: entity.incomeSource?.name,
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
      notes: notes,
      tags: tags,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == paymentMethod,
        orElse: () => PaymentMethod.other,
      ),
      isRecurring: isRecurring,
      receiptPath: receiptPath,
      incomeSource: incomeSource != null
          ? IncomeSource.values.firstWhere(
              (e) => e.name == incomeSource,
              orElse: () => IncomeSource.other,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'date': date.toIso8601String(),
        'category': category,
        'notes': notes,
        'tags': tags,
        'paymentMethod': paymentMethod,
        'isRecurring': isRecurring,
        if (receiptPath != null) 'receiptPath': receiptPath,
        if (incomeSource != null) 'incomeSource': incomeSource,
      };

  factory BudgetTransactionModel.fromJson(Map<String, dynamic> json) {
    return BudgetTransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String? ?? 'General',
      notes: json['notes'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      paymentMethod: json['paymentMethod'] as String? ?? 'upi',
      isRecurring: json['isRecurring'] as bool? ?? false,
      receiptPath: json['receiptPath'] as String?,
      incomeSource: json['incomeSource'] as String?,
    );
  }
}
