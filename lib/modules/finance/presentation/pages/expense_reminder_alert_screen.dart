import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/finance/core/utils/currency_preferences.dart';
import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_add_sheets.dart';
import 'package:mindloop/modules/finance/services/expense_reminder_service.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';
import 'package:mindloop/modules/finance/presentation/widgets/expense_reminder_feedback.dart';

/// Full-screen habit reminder opened from a high-priority expense notification.
class ExpenseReminderAlertScreen extends StatefulWidget {
  const ExpenseReminderAlertScreen({super.key, this.payload});

  final String? payload;

  @override
  State<ExpenseReminderAlertScreen> createState() => _ExpenseReminderAlertScreenState();
}

class _ExpenseReminderAlertScreenState extends State<ExpenseReminderAlertScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    context.read<PfmBloc>().add(const PfmLoadRequested());
  }

  Future<void> _runAction(Future<void> Function() action, {
    required String successTitle,
    required String successMessage,
    bool popAfter = true,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      await ExpenseReminderFeedback.show(
        context,
        outcome: ExpenseReminderOutcome.success,
        title: successTitle,
        message: successMessage,
      );
      if (popAfter && mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      await ExpenseReminderFeedback.show(
        context,
        outcome: ExpenseReminderOutcome.failed,
        title: 'Something went wrong',
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addExpense() async {
    final before = context.read<PfmBloc>().state.transactions.length;
    PfmAddSheets.showTransaction(context, TransactionType.expense);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final after = context.read<PfmBloc>().state.transactions.length;
    if (after > before) {
      await ExpenseReminderFeedback.show(
        context,
        outcome: ExpenseReminderOutcome.success,
        title: 'Expense saved',
        message: 'Great job keeping your records up to date.',
      );
      if (mounted) context.pop();
    }
  }

  Future<void> _addIncome() async {
    final before = context.read<PfmBloc>().state.transactions.length;
    PfmAddSheets.showTransaction(context, TransactionType.income);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final after = context.read<PfmBloc>().state.transactions.length;
    if (after > before) {
      await ExpenseReminderFeedback.show(
        context,
        outcome: ExpenseReminderOutcome.success,
        title: 'Income saved',
        message: 'Your balance and insights will update automatically.',
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final snapshot = state.snapshot;
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    double todayExpense = 0;
    for (final t in state.transactions) {
      if (t.date.isBefore(todayStart)) continue;
      if (t.type == TransactionType.expense) {
        todayExpense += t.amount;
      }
    }

    final monthlyIncome = snapshot?.totalIncome ?? 0;
    final monthlyExpense = snapshot?.totalExpenses ?? 0;
    final remainingBudget = (monthlyIncome - monthlyExpense).clamp(0, double.infinity);
    final recent = state.transactions.take(4).toList();
    final goalProgress = snapshot?.goalProgress.isNotEmpty == true
        ? snapshot!.goalProgress.first.percent
        : 0.0;
    final insight = snapshot?.insights.isNotEmpty == true
        ? snapshot!.insights.first
        : 'Small daily entries build powerful financial clarity.';

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: PfmTheme.scaffold,
        body: SafeArea(
          child: _busy
              ? const Center(child: CircularProgressIndicator(color: PfmTheme.primary))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Expense Reminder',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: PfmTheme.textSecondary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _HeroIllustration()
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.05, end: 0),
                          const SizedBox(height: 16),
                          const Text(
                            'Did you record today\'s expenses?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: PfmTheme.textPrimary,
                              height: 1.2,
                            ),
                          ).animate().fadeIn(delay: 80.ms),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEEE, d MMMM').format(now),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: PfmTheme.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Today\'s spending',
                                  value: fmt.format(todayExpense),
                                  color: PfmTheme.expense,
                                  icon: Icons.arrow_upward_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Budget left',
                                  value: fmt.format(remainingBudget),
                                  color: PfmTheme.income,
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 120.ms),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: PfmTheme.cardDecoration(),
                            child: Row(
                              children: [
                                const Icon(Icons.savings_outlined, color: PfmTheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Savings progress',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: (goalProgress / 100).clamp(0.0, 1.0),
                                          minHeight: 8,
                                          backgroundColor: PfmTheme.border,
                                          color: PfmTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${goalProgress.toStringAsFixed(0)}% toward your top goal',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: PfmTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (recent.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Recent transactions',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            ...recent.map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _RecentRow(transaction: t, fmt: fmt),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: PfmTheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: PfmTheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome, color: PfmTheme.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    insight,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                      color: PfmTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ActionButton(
                            label: 'Add Expense',
                            icon: Icons.add_circle_outline,
                            filled: true,
                            onPressed: _addExpense,
                          ),
                          const SizedBox(height: 10),
                          _ActionButton(
                            label: 'Add Income',
                            icon: Icons.trending_up,
                            filled: false,
                            onPressed: _addIncome,
                          ),
                          const SizedBox(height: 10),
                          _ActionButton(
                            label: 'Remind Me in 10 Minutes',
                            icon: Icons.snooze,
                            filled: false,
                            onPressed: () => _runAction(
                              () => sl<ExpenseReminderService>().snoozeMinutes(10),
                              successTitle: 'Reminder scheduled',
                              successMessage: 'We\'ll nudge you again in 10 minutes.',
                            ),
                          ),
                          const SizedBox(height: 10),
                          _ActionButton(
                            label: 'Remind Me Tonight',
                            icon: Icons.nights_stay_outlined,
                            filled: false,
                            onPressed: () => _runAction(
                              () => sl<ExpenseReminderService>().snoozeTonight(),
                              successTitle: 'See you tonight',
                              successMessage: 'We\'ll remind you this evening to log expenses.',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _runAction(
                              () => sl<ExpenseReminderService>().skipToday(),
                              successTitle: 'Skipped for today',
                              successMessage: 'No more expense reminders until tomorrow.',
                            ),
                            child: const Text(
                              'Skip Today',
                              style: TextStyle(
                                color: PfmTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: PfmTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 24,
            top: 20,
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Daily finance habit',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
      decoration: PfmTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: PfmTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.transaction, required this.fmt});

  final BudgetTransactionEntity transaction;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? PfmTheme.income : PfmTheme.expense;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PfmTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PfmTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              transaction.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
            style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );

    if (filled) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: PfmTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: PfmTheme.primary,
          side: const BorderSide(color: PfmTheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: child,
      ),
    );
  }
}
