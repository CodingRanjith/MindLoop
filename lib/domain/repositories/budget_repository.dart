import 'package:mindloop/domain/entities/budget_transaction_entity.dart';

abstract class BudgetRepository {
  Future<List<BudgetTransactionEntity>> getTransactions();
  Future<void> addTransaction(BudgetTransactionEntity transaction);
  Future<void> deleteTransaction(String id);
}
