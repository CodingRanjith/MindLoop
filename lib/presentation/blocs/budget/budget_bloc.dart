import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/domain/repositories/pfm_repository.dart';
import 'package:uuid/uuid.dart';

part 'budget_event.dart';
part 'budget_state.dart';

/// Lightweight budget view for reminder dashboard widgets. Full PFM uses [PfmBloc].
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc(this._repository) : super(const BudgetState()) {
    on<BudgetLoadRequested>(_onLoad);
    on<BudgetAddRequested>(_onAdd);
    on<BudgetDeleteRequested>(_onDelete);
  }

  final PfmRepository _repository;
  final _uuid = const Uuid();

  Future<void> _onLoad(BudgetLoadRequested event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _repository.getTransactions();
      double income = 0;
      double expense = 0;
      for (final t in transactions) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
      emit(state.copyWith(
        transactions: transactions,
        totalIncome: income,
        totalExpense: expense,
        balance: income - expense,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAdd(BudgetAddRequested event, Emitter<BudgetState> emit) async {
    final tx = event.transaction.copyWith(
      id: event.transaction.id.isEmpty ? _uuid.v4() : event.transaction.id,
    );
    await _repository.saveTransaction(tx);
    add(const BudgetLoadRequested());
  }

  Future<void> _onDelete(BudgetDeleteRequested event, Emitter<BudgetState> emit) async {
    await _repository.deleteTransaction(event.id);
    add(const BudgetLoadRequested());
  }
}
