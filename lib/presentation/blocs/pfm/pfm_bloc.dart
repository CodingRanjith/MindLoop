import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/domain/entities/loan_entity.dart';
import 'package:mindloop/domain/entities/net_worth_item_entity.dart';
import 'package:mindloop/domain/entities/expense_budget_entity.dart';
import 'package:mindloop/domain/entities/expense_category_entity.dart';
import 'package:mindloop/domain/entities/pfm_dashboard_snapshot.dart';
import 'package:mindloop/domain/entities/recurring_transaction_entity.dart';
import 'package:mindloop/domain/repositories/pfm_repository.dart';
import 'package:mindloop/services/expense_tracker_service.dart';
import 'package:mindloop/services/finance_analytics_service.dart';
import 'package:mindloop/services/finance_insights_service.dart';
import 'package:uuid/uuid.dart';

part 'pfm_event.dart';
part 'pfm_state.dart';

class PfmBloc extends Bloc<PfmEvent, PfmState> {
  PfmBloc(
    this._repository, {
    FinanceAnalyticsService? analytics,
    FinanceInsightsService? insights,
    ExpenseTrackerService? expenseTracker,
  })  : _analytics = analytics ?? FinanceAnalyticsService(),
        _insights = insights ?? FinanceInsightsService(),
        _expenseTracker = expenseTracker ?? ExpenseTrackerService(),
        super(const PfmState()) {
    on<PfmLoadRequested>(_onLoad);
    on<PfmTransactionSaveRequested>(_onSaveTransaction);
    on<PfmTransactionDeleteRequested>(_onDeleteTransaction);
    on<PfmBulkDeleteRequested>(_onBulkDelete);
    on<PfmGoalSaveRequested>(_onSaveGoal);
    on<PfmGoalDeleteRequested>(_onDeleteGoal);
    on<PfmLoanSaveRequested>(_onSaveLoan);
    on<PfmLoanDeleteRequested>(_onDeleteLoan);
    on<PfmNetWorthSaveRequested>(_onSaveNetWorth);
    on<PfmBudgetRuleChanged>(_onBudgetRuleChanged);
    on<PfmProcessRecurringRequested>(_onProcessRecurring);
    on<PfmCategorySaveRequested>(_onSaveCategory);
    on<PfmCategoryDeleteRequested>(_onDeleteCategory);
    on<PfmExpenseBudgetSetRequested>(_onSetExpenseBudget);
    on<PfmBackupRestoreRequested>(_onRestoreBackup);
  }

  final PfmRepository _repository;
  final FinanceAnalyticsService _analytics;
  final FinanceInsightsService _insights;
  final ExpenseTrackerService _expenseTracker;
  final _uuid = const Uuid();

  Future<void> _onLoad(PfmLoadRequested event, Emitter<PfmState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final transactions = await _repository.getTransactions();
      final goals = await _repository.getGoals();
      final loans = await _repository.getLoans();
      final netWorth = await _repository.getNetWorthItems();
      final recurring = await _repository.getRecurring();
      final budgetRule = await _repository.getBudgetRule();
      final categories = await _repository.getExpenseCategories();
      final monthlyBudget = await _repository.getMonthlyBudget();
      final weeklyBudget = await _repository.getWeeklyBudget();

      final periodTotals = _expenseTracker.periodTotals(transactions);
      final monthlyBudgetStatus = _expenseTracker.budgetStatus(
        period: ExpenseBudgetPeriod.monthly,
        budgetAmount: monthlyBudget,
        transactions: transactions,
      );
      final weeklyBudgetStatus = _expenseTracker.budgetStatus(
        period: ExpenseBudgetPeriod.weekly,
        budgetAmount: weeklyBudget,
        transactions: transactions,
      );

      double totalIncome = 0;
      double totalExpense = 0;
      for (final t in transactions) {
        if (t.type == TransactionType.income) {
          totalIncome += t.amount;
        } else {
          totalExpense += t.amount;
        }
      }

      final insightList = _insights.generate(
        transactions: transactions,
        goals: goals,
        loans: loans,
        totalIncome: totalIncome,
        totalExpenses: totalExpense,
      );

      final snapshot = _analytics.buildSnapshot(
        transactions: transactions,
        goals: goals,
        loans: loans,
        netWorthItems: netWorth,
        budgetRule: budgetRule,
        insights: insightList,
      );

      final comparisons = _analytics.compareMonths(transactions);

      emit(state.copyWith(
        transactions: transactions,
        goals: goals,
        loans: loans,
        netWorthItems: netWorth,
        recurring: recurring,
        budgetRule: budgetRule,
        expenseCategories: categories,
        monthlyBudget: monthlyBudget,
        weeklyBudget: weeklyBudget,
        periodTotals: periodTotals,
        monthlyBudgetStatus: monthlyBudgetStatus,
        weeklyBudgetStatus: weeklyBudgetStatus,
        snapshot: snapshot,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        monthComparisons: comparisons,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSaveTransaction(
    PfmTransactionSaveRequested event,
    Emitter<PfmState> emit,
  ) async {
    final tx = event.transaction.copyWith(
      id: event.transaction.id.isEmpty ? _uuid.v4() : event.transaction.id,
    );
    await _repository.saveTransaction(tx);
    add(const PfmLoadRequested());
  }

  Future<void> _onDeleteTransaction(
    PfmTransactionDeleteRequested event,
    Emitter<PfmState> emit,
  ) async {
    await _repository.deleteTransaction(event.id);
    add(const PfmLoadRequested());
  }

  Future<void> _onBulkDelete(PfmBulkDeleteRequested event, Emitter<PfmState> emit) async {
    await _repository.deleteTransactions(event.ids);
    add(const PfmLoadRequested());
  }

  Future<void> _onSaveGoal(PfmGoalSaveRequested event, Emitter<PfmState> emit) async {
    final goal = event.goal.copyWith(
      id: event.goal.id.isEmpty ? _uuid.v4() : event.goal.id,
    );
    await _repository.saveGoal(goal);
    add(const PfmLoadRequested());
  }

  Future<void> _onDeleteGoal(PfmGoalDeleteRequested event, Emitter<PfmState> emit) async {
    await _repository.deleteGoal(event.id);
    add(const PfmLoadRequested());
  }

  Future<void> _onSaveLoan(PfmLoanSaveRequested event, Emitter<PfmState> emit) async {
    final loan = event.loan.copyWith(
      id: event.loan.id.isEmpty ? _uuid.v4() : event.loan.id,
    );
    await _repository.saveLoan(loan);
    add(const PfmLoadRequested());
  }

  Future<void> _onDeleteLoan(PfmLoanDeleteRequested event, Emitter<PfmState> emit) async {
    await _repository.deleteLoan(event.id);
    add(const PfmLoadRequested());
  }

  Future<void> _onSaveNetWorth(PfmNetWorthSaveRequested event, Emitter<PfmState> emit) async {
    final item = event.item.copyWith(
      id: event.item.id.isEmpty ? _uuid.v4() : event.item.id,
    );
    await _repository.saveNetWorthItem(item);
    add(const PfmLoadRequested());
  }

  Future<void> _onBudgetRuleChanged(
    PfmBudgetRuleChanged event,
    Emitter<PfmState> emit,
  ) async {
    await _repository.setBudgetRule(event.rule);
    add(const PfmLoadRequested());
  }

  Future<void> _onProcessRecurring(
    PfmProcessRecurringRequested event,
    Emitter<PfmState> emit,
  ) async {
    final now = DateTime.now();
    for (final r in state.recurring.where((r) => r.active && !r.nextRun.isAfter(now))) {
      await _repository.saveTransaction(
        BudgetTransactionEntity(
          id: _uuid.v4(),
          title: r.title,
          amount: r.amount,
          type: r.type,
          date: r.nextRun,
          category: r.category,
          paymentMethod: r.paymentMethod,
          isRecurring: true,
        ),
      );
      final next = _nextRun(r.nextRun, r.frequency);
      await _repository.saveRecurring(r.copyWith(nextRun: next));
    }
    add(const PfmLoadRequested());
  }

  DateTime _nextRun(DateTime current, RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.daily => current.add(const Duration(days: 1)),
      RecurrenceFrequency.weekly => current.add(const Duration(days: 7)),
      RecurrenceFrequency.monthly => DateTime(current.year, current.month + 1, current.day),
      RecurrenceFrequency.yearly => DateTime(current.year + 1, current.month, current.day),
    };
  }

  Future<void> _onSaveCategory(
    PfmCategorySaveRequested event,
    Emitter<PfmState> emit,
  ) async {
    final cat = event.category.copyWith(
      id: event.category.id.isEmpty ? _uuid.v4() : event.category.id,
    );
    await _repository.saveExpenseCategory(cat);
    add(const PfmLoadRequested());
  }

  Future<void> _onDeleteCategory(
    PfmCategoryDeleteRequested event,
    Emitter<PfmState> emit,
  ) async {
    await _repository.deleteExpenseCategory(event.id);
    add(const PfmLoadRequested());
  }

  Future<void> _onSetExpenseBudget(
    PfmExpenseBudgetSetRequested event,
    Emitter<PfmState> emit,
  ) async {
    if (event.period == ExpenseBudgetPeriod.monthly) {
      await _repository.setMonthlyBudget(event.amount);
    } else {
      await _repository.setWeeklyBudget(event.amount);
    }
    add(const PfmLoadRequested());
  }

  Future<void> _onRestoreBackup(
    PfmBackupRestoreRequested event,
    Emitter<PfmState> emit,
  ) async {
    await _repository.restoreBackupJson(event.json);
    add(const PfmLoadRequested());
  }
}
