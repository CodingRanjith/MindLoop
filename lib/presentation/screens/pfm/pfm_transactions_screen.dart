import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmTransactionsScreen extends StatefulWidget {
  const PfmTransactionsScreen({super.key});

  @override
  State<PfmTransactionsScreen> createState() => _PfmTransactionsScreenState();
}

class _PfmTransactionsScreenState extends State<PfmTransactionsScreen> {
  final _searchCtrl = TextEditingController();
  int _filterIndex = 0;
  static const _filters = ['All', 'Income', 'Expense'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final query = _searchCtrl.text.toLowerCase();

    var list = state.transactions.where((t) {
      if (_filterIndex == 1 && t.type != TransactionType.income) return false;
      if (_filterIndex == 2 && t.type != TransactionType.expense) return false;
      if (query.isNotEmpty &&
          !t.title.toLowerCase().contains(query) &&
          !t.category.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    final grouped = <String, List<BudgetTransactionEntity>>{};
    for (final t in list) {
      final key = DateFormat('EEEE, d MMM yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Transactions',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: PfmTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PfmFilterChipRow(
              labels: _filters,
              selectedIndex: _filterIndex,
              onSelected: (i) => setState(() => _filterIndex = i),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: list.isEmpty
                ? const Center(child: PfmNoDataBox(message: 'No transactions to show.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: grouped.length,
                    itemBuilder: (context, gi) {
                      final dateKey = grouped.keys.elementAt(gi);
                      final items = grouped[dateKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(
                              dateKey,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: PfmTheme.textSecondary,
                              ),
                            ),
                          ),
                          ...items.map((t) => _TransactionRow(
                                transaction: t,
                                fmt: fmt,
                                onTap: () => PfmAddSheets.showTransaction(context, t.type, existing: t),
                              )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.fmt,
    required this.onTap,
  });

  final BudgetTransactionEntity transaction;
  final NumberFormat fmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? PfmTheme.income : PfmTheme.expense;
    final icon = isIncome ? Icons.work_outline : Icons.shopping_bag_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PfmTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: PfmTheme.cardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        Text(
                          transaction.category,
                          style: const TextStyle(fontSize: 12, color: PfmTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15),
                      ),
                      Text(
                        isIncome ? 'Income' : PfmCategories.bucketLabel(
                              PfmCategories.bucketFor(transaction.category),
                            ),
                        style: const TextStyle(fontSize: 11, color: PfmTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
