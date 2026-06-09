import 'package:equatable/equatable.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';

class RecurringTransactionEntity extends Equatable {
  const RecurringTransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.frequency,
    required this.nextRun,
    this.paymentMethod = PaymentMethod.upi,
    this.active = true,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final RecurrenceFrequency frequency;
  final DateTime nextRun;
  final PaymentMethod paymentMethod;
  final bool active;

  RecurringTransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    RecurrenceFrequency? frequency,
    DateTime? nextRun,
    PaymentMethod? paymentMethod,
    bool? active,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextRun: nextRun ?? this.nextRun,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, amount, type, category, frequency, nextRun, paymentMethod, active];
}
