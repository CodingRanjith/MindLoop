import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/domain/entities/loan_entity.dart';
import 'package:mindloop/domain/entities/net_worth_item_entity.dart';
import 'package:mindloop/domain/entities/recurring_transaction_entity.dart';

abstract class PfmRepository {
  Future<List<BudgetTransactionEntity>> getTransactions();
  Future<void> saveTransaction(BudgetTransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<void> deleteTransactions(Iterable<String> ids);

  Future<List<FinancialGoalEntity>> getGoals();
  Future<void> saveGoal(FinancialGoalEntity goal);
  Future<void> deleteGoal(String id);

  Future<List<LoanEntity>> getLoans();
  Future<void> saveLoan(LoanEntity loan);
  Future<void> deleteLoan(String id);

  Future<List<NetWorthItemEntity>> getNetWorthItems();
  Future<void> saveNetWorthItem(NetWorthItemEntity item);
  Future<void> deleteNetWorthItem(String id);

  Future<List<RecurringTransactionEntity>> getRecurring();
  Future<void> saveRecurring(RecurringTransactionEntity recurring);
  Future<void> deleteRecurring(String id);

  Future<BudgetRuleType> getBudgetRule();
  Future<void> setBudgetRule(BudgetRuleType rule);

  Future<String?> exportBackupJson();
  Future<void> restoreBackupJson(String json);
}
