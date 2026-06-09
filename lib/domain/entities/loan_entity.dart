import 'package:equatable/equatable.dart';

class LoanEntity extends Equatable {
  const LoanEntity({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.emiAmount,
    required this.remainingEmiCount,
    required this.interestRate,
    required this.nextDueDate,
    this.lender = '',
  });

  final String id;
  final String name;
  final double totalAmount;
  final double paidAmount;
  final double emiAmount;
  final int remainingEmiCount;
  final double interestRate;
  final DateTime nextDueDate;
  final String lender;

  double get pendingAmount => (totalAmount - paidAmount).clamp(0, double.infinity);

  double get progressPercent =>
      totalAmount > 0 ? (paidAmount / totalAmount * 100).clamp(0, 100) : 0;

  LoanEntity copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? paidAmount,
    double? emiAmount,
    int? remainingEmiCount,
    double? interestRate,
    DateTime? nextDueDate,
    String? lender,
  }) {
    return LoanEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      emiAmount: emiAmount ?? this.emiAmount,
      remainingEmiCount: remainingEmiCount ?? this.remainingEmiCount,
      interestRate: interestRate ?? this.interestRate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lender: lender ?? this.lender,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        totalAmount,
        paidAmount,
        emiAmount,
        remainingEmiCount,
        interestRate,
        nextDueDate,
        lender,
      ];
}
