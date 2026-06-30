import 'package:flutter/material.dart';
import 'package:mindloop/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/services/expense_tracker_service.dart';
import 'package:mindloop/themes/pfm_theme.dart';

/// Period selector with income vs expense breakdown — replaces cramped stat chips.
class PfmMoneyOverviewCard extends StatefulWidget {
  const PfmMoneyOverviewCard({
    super.key,
    required this.transactions,
    required this.formatAmount,
    this.initialPeriod = FinancePeriod.month,
  });

  final List<BudgetTransactionEntity> transactions;
  final String Function(double) formatAmount;
  final FinancePeriod initialPeriod;

  @override
  State<PfmMoneyOverviewCard> createState() => _PfmMoneyOverviewCardState();
}

class _PfmMoneyOverviewCardState extends State<PfmMoneyOverviewCard> {
  late FinancePeriod _period;
  final _tracker = ExpenseTrackerService();

  static const _labels = ['Today', 'This Week', 'This Month'];
  static const _periods = [FinancePeriod.today, FinancePeriod.week, FinancePeriod.month];

  @override
  void initState() {
    super.initState();
    _period = widget.initialPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final summary = _tracker.moneySummary(widget.transactions, _period);
    final total = summary.income + summary.expense;
    final incomeShare = total > 0 ? summary.income / total : 0.5;
    final expenseShare = total > 0 ? summary.expense / total : 0.5;
    final periodIndex = _periods.indexOf(_period);

    return Container(
      decoration: PfmTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Money Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PfmTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PfmTheme.scaffold,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PfmTheme.border),
              ),
              child: Row(
                children: List.generate(_labels.length, (i) {
                  final selected = i == periodIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _period = _periods[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? PfmTheme.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: selected ? PfmTheme.cardShadow : null,
                        ),
                        child: Text(
                          _labels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? PfmTheme.primary : PfmTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MoneyStat(
                    label: 'Income',
                    value: widget.formatAmount(summary.income),
                    color: PfmTheme.income,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoneyStat(
                    label: 'Expenses',
                    value: widget.formatAmount(summary.expense),
                    color: PfmTheme.expense,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    if (summary.income > 0)
                      Expanded(
                        flex: (incomeShare * 100).round().clamp(1, 100),
                        child: Container(color: PfmTheme.income),
                      ),
                    if (summary.expense > 0)
                      Expanded(
                        flex: (expenseShare * 100).round().clamp(1, 100),
                        child: Container(color: PfmTheme.expense),
                      ),
                    if (total <= 0)
                      const Expanded(child: ColoredBox(color: PfmTheme.border)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _LegendDot(color: PfmTheme.income, label: 'Income'),
                const SizedBox(width: 16),
                _LegendDot(color: PfmTheme.expense, label: 'Expenses'),
                const Spacer(),
                Text(
                  'Net ${widget.formatAmount(summary.net)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: summary.net >= 0 ? PfmTheme.income : PfmTheme.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyStat extends StatelessWidget {
  const _MoneyStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: PfmTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: PfmTheme.textSecondary),
        ),
      ],
    );
  }
}
