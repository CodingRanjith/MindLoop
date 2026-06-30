import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/modules/finance/core/utils/currency_preferences.dart';
import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';
import 'package:mindloop/modules/finance/domain/entities/pfm_dashboard_snapshot.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_empty_data.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_drawer.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_ui_kit.dart';

class PfmNotificationItem {
  const PfmNotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color color;
}

class PfmNotificationsScreen extends StatelessWidget {
  const PfmNotificationsScreen({super.key});

  List<PfmNotificationItem> _buildNotifications(PfmState state) {
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final items = <PfmNotificationItem>[];
    final now = DateTime.now();
    final snapshot = state.snapshot;

    for (final loan in state.loans) {
      final days = loan.nextDueDate.difference(now).inDays;
      if (days >= 0 && days <= 7) {
        items.add(
          PfmNotificationItem(
            title: 'EMI Due Reminder',
            body: '${loan.name} EMI of ${fmt.format(loan.emiAmount)} is due in $days days.',
            time: loan.nextDueDate,
            icon: Icons.account_balance,
            color: PfmTheme.expense,
          ),
        );
      }
    }

    if (snapshot != null) {
      for (final bucket in snapshot.budgetStatus.entries) {
        if (bucket.value == BudgetStatus.nearLimit || bucket.value == BudgetStatus.overBudget) {
          items.add(
            PfmNotificationItem(
              title: 'Budget Alert',
              body:
                  'You are nearing or over your ${PfmCategories.bucketLabel(bucket.key)} budget limit.',
              time: now,
              icon: Icons.pie_chart_outline,
              color: PfmTheme.warning,
            ),
          );
        }
      }
    }

    for (final goal in state.goals) {
      if (goal.completionPercent > 0) {
        items.add(
          PfmNotificationItem(
            title: 'Goal Update',
            body: '${goal.name} completed ${goal.completionPercent.toStringAsFixed(0)}%.',
            time: now,
            icon: Icons.flag_outlined,
            color: PfmTheme.income,
          ),
        );
      }
    }

    final recentExpense = state.transactions
        .where((t) => t.type.name == 'expense')
        .take(3);
    for (final t in recentExpense) {
      items.add(
        PfmNotificationItem(
          title: 'Expense Recorded',
          body: 'You spent ${fmt.format(t.amount)} on ${t.category}.',
          time: t.date,
          icon: Icons.shopping_bag_outlined,
          color: PfmTheme.expense,
        ),
      );
    }

    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final notifications = _buildNotifications(state);

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Notifications',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(child: PfmNoDataBox(message: 'No alerts right now.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: notifications.length,
              itemBuilder: (context, i) {
                final n = notifications[i];
                final isToday = DateTime.now().difference(n.time).inDays == 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PfmSurfaceCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: n.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(n.icon, color: n.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: PfmTheme.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isToday
                                    ? DateFormat.jm().format(n.time)
                                    : DateFormat.MMMd().format(n.time),
                                style: const TextStyle(fontSize: 11, color: PfmTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: PfmTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
