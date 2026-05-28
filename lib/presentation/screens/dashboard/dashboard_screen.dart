import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/budget/budget_bloc.dart';
import 'package:mindloop/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:mindloop/themes/app_colors.dart';
import 'package:mindloop/widgets/coming_soon_card.dart';

enum _HubModule { hub, reminders, expenses, future }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _HubModule _module = _HubModule.hub;

  void _openModule(_HubModule module) {
    HapticFeedback.selectionClick();
    setState(() => _module = module);
  }

  void _backToHub() {
    HapticFeedback.selectionClick();
    setState(() => _module = _HubModule.hub);
  }

  String _displayName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Explorer';
    final t = name.trim();
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final reminders = context.watch<ReminderBloc>().state;
    final budget = context.watch<BudgetBloc>().state;
    final isHub = _module == _HubModule.hub;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: isHub
                    ? _ProHubHeader(
                        name: _displayName(auth.userName),
                        onSettings: () => context.push('/settings'),
                      )
                    : _ProModuleHeader(
                        title: _moduleTitle(_module),
                        onBack: _backToHub,
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: KeyedSubtree(
                      key: ValueKey(_module),
                      child: _buildModuleBody(
                        context,
                        module: _module,
                        reminders: reminders,
                        budget: budget,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _moduleTitle(_HubModule module) {
    return switch (module) {
      _HubModule.hub => 'Home',
      _HubModule.reminders => 'Reminders',
      _HubModule.expenses => 'Expense Manager',
      _HubModule.future => 'Future Works',
    };
  }

  Widget _buildModuleBody(
    BuildContext context, {
    required _HubModule module,
    required ReminderState reminders,
    required BudgetState budget,
  }) {
    final timeFmt = DateFormat.jm();

    return switch (module) {
      _HubModule.hub => _HubView(
          todayCount: reminders.todayReminders.length,
          balance: budget.balance,
          upcomingCount: reminders.upcomingReminders.length,
          onOpenReminders: () => _openModule(_HubModule.reminders),
          onOpenExpenses: () => _openModule(_HubModule.expenses),
          onOpenFuture: () => _openModule(_HubModule.future),
        ),
      _HubModule.reminders => _RemindersModuleView(
          reminders: reminders,
          timeFmt: timeFmt,
          onSeeAll: () => context.go('/calendar'),
        ),
      _HubModule.expenses => _ExpensesModuleView(
          budget: budget,
          onOpenFull: () => context.go('/budget'),
        ),
      _HubModule.future => const _FutureModuleView(),
    };
  }
}

// ——— Professional hub ———

class _ProHubHeader extends StatelessWidget {
  const _ProHubHeader({required this.name, required this.onSettings});

  final String name;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        _ProAvatar(initial: name.substring(0, 1).toUpperCase()),
        const SizedBox(width: 10),
        _ProIconButton(icon: Icons.settings_outlined, onTap: onSettings),
      ],
    );
  }
}

class _ProModuleHeader extends StatelessWidget {
  const _ProModuleHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _ProAvatar extends StatelessWidget {
  const _ProAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProIconButton extends StatelessWidget {
  const _ProIconButton({
    required this.icon,
    required this.onTap,
    this.size = 22,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: size, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _HubView extends StatelessWidget {
  const _HubView({
    required this.todayCount,
    required this.balance,
    required this.upcomingCount,
    required this.onOpenReminders,
    required this.onOpenExpenses,
    required this.onOpenFuture,
  });

  final int todayCount;
  final double balance;
  final int upcomingCount;
  final VoidCallback onOpenReminders;
  final VoidCallback onOpenExpenses;
  final VoidCallback onOpenFuture;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryHeroCard(
          balance: fmt.format(balance),
          todayCount: todayCount,
          upcomingCount: upcomingCount,
        ),
        const SizedBox(height: 32),
        const _ProSectionTitle(title: 'Services'),
        const SizedBox(height: 12),
        _ProGroupedList(
          children: [
            _ProListTile(
              icon: Icons.event_note_outlined,
              title: 'Reminders',
              subtitle: todayCount > 0
                  ? '$todayCount today · $upcomingCount upcoming'
                  : 'Schedule and track tasks',
              onTap: onOpenReminders,
            ),
            _ProListTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Expense Manager',
              subtitle: 'Balance ${fmt.format(balance)}',
              onTap: onOpenExpenses,
            ),
            _ProListTile(
              icon: Icons.layers_outlined,
              title: 'Future Works',
              subtitle: 'Upcoming product features',
              onTap: onOpenFuture,
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _ProSectionTitle(title: 'Quick actions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.add_circle_outline,
                label: 'New reminder',
                onTap: () => context.push('/reminder/create'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                onTap: () => context.go('/calendar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({
    required this.balance,
    required this.todayCount,
    required this.upcomingCount,
  });

  final String balance;
  final int todayCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260A2A3C),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available balance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnPrimary.withValues(alpha: 0.72),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroMetric(label: 'Today', value: '$todayCount'),
              _HeroMetric(label: 'Upcoming', value: '$upcomingCount'),
              const _HeroMetric(label: 'Status', value: 'Active'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnPrimary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProSectionTitle extends StatelessWidget {
  const _ProSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ProGroupedList extends StatelessWidget {
  const _ProGroupedList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProListTile extends StatelessWidget {
  const _ProListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 22, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 70, color: AppColors.border),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: AppColors.textPrimary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ——— Module detail views ———

class _RemindersModuleView extends StatelessWidget {
  const _RemindersModuleView({
    required this.reminders,
    required this.timeFmt,
    required this.onSeeAll,
  });

  final ReminderState reminders;
  final DateFormat timeFmt;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Today's reminders",
          action: 'Calendar',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 12),
        if (reminders.todayReminders.isEmpty)
          const _ProEmptyState(message: 'No reminders today. Tap + to add one.')
        else
          _ProGroupedList(
            children: [
              for (var i = 0; i < reminders.todayReminders.length; i++)
                _ReminderTile(
                  reminder: reminders.todayReminders[i],
                  timeFmt: timeFmt,
                  showDivider: i < reminders.todayReminders.length - 1,
                ),
            ],
          ),
        const SizedBox(height: 28),
        const _ProSectionTitle(title: 'Upcoming'),
        const SizedBox(height: 12),
        if (reminders.upcomingReminders.isEmpty)
          const _ProEmptyState(message: 'Nothing scheduled ahead.')
        else
          _ProGroupedList(
            children: [
              for (var i = 0; i < reminders.upcomingReminders.take(5).length; i++)
                _ReminderTile(
                  reminder: reminders.upcomingReminders[i],
                  timeFmt: timeFmt,
                  showDivider: i < reminders.upcomingReminders.take(5).length - 1,
                ),
            ],
          ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.timeFmt,
    required this.showDivider,
  });

  final ReminderEntity reminder;
  final DateFormat timeFmt;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: () => context.push('/reminder/${reminder.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeFmt.format(reminder.scheduledAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, color: AppColors.border),
      ],
    );
  }
}

class _ExpensesModuleView extends StatelessWidget {
  const _ExpensesModuleView({
    required this.budget,
    required this.onOpenFull,
  });

  final BudgetState budget;
  final VoidCallback onOpenFull;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final spentRatio = budget.totalIncome > 0
        ? (budget.totalExpense / budget.totalIncome).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpenseSummaryCard(budget: budget, fmt: fmt),
        const SizedBox(height: 24),
        _ProGroupedList(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InlineStat(label: 'Income', value: fmt.format(budget.totalIncome)),
                      _InlineStat(label: 'Expense', value: fmt.format(budget.totalExpense)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: spentRatio,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(spentRatio * 100).toStringAsFixed(0)}% of income used',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onOpenFull,
            child: const Text('Open full budget'),
          ),
        ),
      ],
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({required this.budget, required this.fmt});

  final BudgetState budget;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260A2A3C),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net balance',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textOnPrimary.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(budget.balance),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroMetric(label: 'Income', value: fmt.format(budget.totalIncome)),
              _HeroMetric(label: 'Spent', value: fmt.format(budget.totalExpense)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FutureModuleView extends StatelessWidget {
  const _FutureModuleView();

  static const _previewFeatures = [
    (Icons.psychology_outlined, 'AI Assistant', 'Smart memory companion'),
    (Icons.mic_none_outlined, 'Voice AI', 'Speak to create reminders'),
    (Icons.watch_outlined, 'Wearable Sync', 'Apple Watch & Wear OS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Roadmap',
          action: 'View all',
          onAction: () => context.push('/future'),
        ),
        const SizedBox(height: 12),
        ..._previewFeatures.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ComingSoonCard(title: f.$2, subtitle: f.$3, icon: f.$1),
          ),
        ),
      ],
    );
  }
}

class _ProEmptyState extends StatelessWidget {
  const _ProEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}
