part of 'budget_bloc.dart';

class BudgetState extends Equatable {
  const BudgetState({
    this.transactions = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
    this.isLoading = false,
    this.error,
  });

  final List<BudgetTransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final bool isLoading;
  final String? error;

  BudgetState copyWith({
    List<BudgetTransactionEntity>? transactions,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    bool? isLoading,
    String? error,
  }) {
    return BudgetState(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [transactions, totalIncome, totalExpense, balance, isLoading, error];
}
