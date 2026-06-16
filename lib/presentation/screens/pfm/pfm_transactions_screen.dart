import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/core/constants/pfm_categories.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart';
import 'package:mindloop/domain/entities/expense_category_entity.dart';
import 'package:mindloop/services/expense_tracker_service.dart';
import 'package:mindloop/themes/pfm_theme.dart';
import 'package:mindloop/widgets/pfm/pfm_drawer.dart';
import 'package:mindloop/widgets/pfm/pfm_empty_data.dart';
import 'package:mindloop/widgets/pfm/pfm_ui_kit.dart';

class PfmTransactionsScreen extends StatefulWidget {
  const PfmTransactionsScreen({super.key});

  @override
  State<PfmTransactionsScreen> createState() => _PfmTransactionsScreenState();
}

class _PfmTransactionsScreenState extends State<PfmTransactionsScreen> {
  final _searchCtrl = TextEditingController();
  final _tracker = ExpenseTrackerService();
  int _filterIndex = 0;
  static const _filters = ['All', 'Income', 'Expense'];

  ExpenseSortOption _sort = ExpenseSortOption.latest;
  String? _categoryFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  bool _showSearch = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  ExpenseFilter _buildFilter() {
    return ExpenseFilter(
      query: _searchCtrl.text,
      category: _categoryFilter,
      startDate: _startDate,
      endDate: _endDate != null
          ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
          : null,
      minAmount: _minAmount,
      maxAmount: _maxAmount,
      sort: _sort,
      expensesOnly: _filterIndex == 2,
    );
  }

  List<BudgetTransactionEntity> _filtered(PfmState state) {
    var list = _tracker.filterTransactions(state.transactions, _buildFilter());
    if (_filterIndex == 1) {
      list = list.where((t) => t.type == TransactionType.income).toList();
    }
    return list;
  }

  Future<void> _showAdvancedFilters(BuildContext context, PfmState state) async {
    var category = _categoryFilter;
    var start = _startDate;
    var end = _endDate;
    final minCtrl = TextEditingController(text: _minAmount?.toString() ?? '');
    final maxCtrl = TextEditingController(text: _maxAmount?.toString() ?? '');
    var sort = _sort;

    final categories = PfmCategories.allExpenseCategoryNames(
      state.expenseCategories.where((c) => !c.isDefault).toList(),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
            decoration: const BoxDecoration(
              color: PfmTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All categories')),
                        ...categories.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c)),
                        ),
                      ],
                      onChanged: (v) => setModal(() => category = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: start ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setModal(() => start = picked);
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              start == null ? 'From date' : DateFormat('d MMM yy').format(start!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: end ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setModal(() => end = picked);
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              end == null ? 'To date' : DateFormat('d MMM yy').format(end!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Min amount'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: maxCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Max amount'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExpenseSortOption>(
                      value: sort,
                      decoration: const InputDecoration(labelText: 'Sort by'),
                      items: const [
                        DropdownMenuItem(value: ExpenseSortOption.latest, child: Text('Latest')),
                        DropdownMenuItem(value: ExpenseSortOption.oldest, child: Text('Oldest')),
                        DropdownMenuItem(
                          value: ExpenseSortOption.highestAmount,
                          child: Text('Highest amount'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseSortOption.lowestAmount,
                          child: Text('Lowest amount'),
                        ),
                      ],
                      onChanged: (v) => setModal(() => sort = v ?? sort),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _categoryFilter = null;
                                _startDate = null;
                                _endDate = null;
                                _minAmount = null;
                                _maxAmount = null;
                                _sort = ExpenseSortOption.latest;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _categoryFilter = category;
                                _startDate = start;
                                _endDate = end;
                                _minAmount = double.tryParse(minCtrl.text);
                                _maxAmount = double.tryParse(maxCtrl.text);
                                _sort = sort;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    minCtrl.dispose();
    maxCtrl.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, BudgetTransactionEntity t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('Remove "${t.title}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: PfmTheme.expense)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<PfmBloc>().add(PfmTransactionDeleteRequested(t.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final list = _filtered(state);

    final grouped = <String, List<BudgetTransactionEntity>>{};
    for (final t in list) {
      final key = DateFormat('EEEE, d MMM yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final hasActiveFilters = _categoryFilter != null ||
        _startDate != null ||
        _endDate != null ||
        _minAmount != null ||
        _maxAmount != null;

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Expenses',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              color: PfmTheme.textPrimary,
            ),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              smallSize: 8,
              child: const Icon(Icons.tune_rounded, color: PfmTheme.textPrimary),
            ),
            onPressed: () => _showAdvancedFilters(context, state),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by title, category, notes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: PfmTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: PfmTheme.border),
                  ),
                ),
              ),
            ),
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
                ? const Center(child: PfmNoDataBox(message: 'No transactions match your filters.'))
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
                          ...items.map(
                            (t) => Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: PfmTheme.expense,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                await _confirmDelete(context, t);
                                return false;
                              },
                              child: _TransactionRow(
                                transaction: t,
                                fmt: fmt,
                                categories: state.expenseCategories,
                                onTap: () => PfmAddSheets.showTransaction(
                                  context,
                                  t.type,
                                  existing: t,
                                ),
                              ),
                            ),
                          ),
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
    required this.categories,
    required this.onTap,
  });

  final BudgetTransactionEntity transaction;
  final NumberFormat fmt;
  final List<ExpenseCategoryEntity> categories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? PfmTheme.income : PfmTheme.expense;
    final meta = PfmCategories.categoryMeta(transaction.category, categories);
    final icon = meta?.iconData ?? (isIncome ? Icons.work_outline : Icons.shopping_bag_outlined);
    final avatarColor = meta?.colorValue ?? color;

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
                    backgroundColor: avatarColor.withValues(alpha: 0.12),
                    child: Icon(icon, color: avatarColor, size: 20),
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
                          '${transaction.category} · ${transaction.paymentMethod.name}',
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
                        DateFormat('h:mm a').format(transaction.date),
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
