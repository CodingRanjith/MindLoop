part of 'pfm_bloc.dart';

class PfmState extends Equatable {
  const PfmState({
    this.transactions = const [],
    this.goals = const [],
    this.loans = const [],
    this.netWorthItems = const [],
    this.recurring = const [],
    this.budgetRule = BudgetRuleType.custom,
    this.snapshot,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
    this.monthComparisons = const {},
    this.isLoading = false,
    this.error,
    this.selectedTransactionIds = const {},
  });

  final List<BudgetTransactionEntity> transactions;
  final List<FinancialGoalEntity> goals;
  final List<LoanEntity> loans;
  final List<NetWorthItemEntity> netWorthItems;
  final List<RecurringTransactionEntity> recurring;
  final BudgetRuleType budgetRule;
  final PfmDashboardSnapshot? snapshot;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> monthComparisons;
  final bool isLoading;
  final String? error;
  final Set<String> selectedTransactionIds;

  PfmState copyWith({
    List<BudgetTransactionEntity>? transactions,
    List<FinancialGoalEntity>? goals,
    List<LoanEntity>? loans,
    List<NetWorthItemEntity>? netWorthItems,
    List<RecurringTransactionEntity>? recurring,
    BudgetRuleType? budgetRule,
    PfmDashboardSnapshot? snapshot,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    Map<String, double>? monthComparisons,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<String>? selectedTransactionIds,
  }) {
    return PfmState(
      transactions: transactions ?? this.transactions,
      goals: goals ?? this.goals,
      loans: loans ?? this.loans,
      netWorthItems: netWorthItems ?? this.netWorthItems,
      recurring: recurring ?? this.recurring,
      budgetRule: budgetRule ?? this.budgetRule,
      snapshot: snapshot ?? this.snapshot,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      monthComparisons: monthComparisons ?? this.monthComparisons,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedTransactionIds: selectedTransactionIds ?? this.selectedTransactionIds,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        goals,
        loans,
        snapshot,
        totalIncome,
        totalExpense,
        balance,
        isLoading,
        error,
        selectedTransactionIds,
      ];
}
