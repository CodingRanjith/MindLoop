part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class BudgetLoadRequested extends BudgetEvent {
  const BudgetLoadRequested();
}

class BudgetAddRequested extends BudgetEvent {
  const BudgetAddRequested(this.transaction);
  final BudgetTransactionEntity transaction;

  @override
  List<Object?> get props => [transaction];
}

class BudgetDeleteRequested extends BudgetEvent {
  const BudgetDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
