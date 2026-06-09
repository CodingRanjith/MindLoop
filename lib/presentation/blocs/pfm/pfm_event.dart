part of 'pfm_bloc.dart';

sealed class PfmEvent extends Equatable {
  const PfmEvent();
  @override
  List<Object?> get props => [];
}

class PfmLoadRequested extends PfmEvent {
  const PfmLoadRequested();
}

class PfmTransactionSaveRequested extends PfmEvent {
  const PfmTransactionSaveRequested(this.transaction);
  final BudgetTransactionEntity transaction;
  @override
  List<Object?> get props => [transaction];
}

class PfmTransactionDeleteRequested extends PfmEvent {
  const PfmTransactionDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class PfmBulkDeleteRequested extends PfmEvent {
  const PfmBulkDeleteRequested(this.ids);
  final List<String> ids;
  @override
  List<Object?> get props => [ids];
}

class PfmGoalSaveRequested extends PfmEvent {
  const PfmGoalSaveRequested(this.goal);
  final FinancialGoalEntity goal;
  @override
  List<Object?> get props => [goal];
}

class PfmGoalDeleteRequested extends PfmEvent {
  const PfmGoalDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class PfmLoanSaveRequested extends PfmEvent {
  const PfmLoanSaveRequested(this.loan);
  final LoanEntity loan;
  @override
  List<Object?> get props => [loan];
}

class PfmLoanDeleteRequested extends PfmEvent {
  const PfmLoanDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class PfmNetWorthSaveRequested extends PfmEvent {
  const PfmNetWorthSaveRequested(this.item);
  final NetWorthItemEntity item;
  @override
  List<Object?> get props => [item];
}

class PfmBudgetRuleChanged extends PfmEvent {
  const PfmBudgetRuleChanged(this.rule);
  final BudgetRuleType rule;
  @override
  List<Object?> get props => [rule];
}

class PfmProcessRecurringRequested extends PfmEvent {
  const PfmProcessRecurringRequested();
}
