import 'package:equatable/equatable.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';

enum TransactionType { income, expense }

class BudgetTransactionEntity extends Equatable {
  const BudgetTransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category = 'General',
    this.notes = '',
    this.tags = const [],
    this.paymentMethod = PaymentMethod.upi,
    this.isRecurring = false,
    this.receiptPath,
    this.incomeSource,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category;
  final String notes;
  final List<String> tags;
  final PaymentMethod paymentMethod;
  final bool isRecurring;
  final String? receiptPath;
  final IncomeSource? incomeSource;

  ExpenseBucket? get expenseBucket =>
      type == TransactionType.expense ? PfmCategories.bucketFor(category) : null;

  BudgetTransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? category,
    String? notes,
    List<String>? tags,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
    String? receiptPath,
    IncomeSource? incomeSource,
  }) {
    return BudgetTransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      receiptPath: receiptPath ?? this.receiptPath,
      incomeSource: incomeSource ?? this.incomeSource,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        type,
        date,
        category,
        notes,
        tags,
        paymentMethod,
        isRecurring,
        receiptPath,
        incomeSource,
      ];
}
