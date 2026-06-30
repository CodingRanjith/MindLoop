import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/calculator/core/utils/calculator_usage_tracker.dart';
import 'package:mindloop/modules/pomodoro/core/utils/pomodoro_preferences.dart';
import 'package:mindloop/modules/profile/core/utils/user_profile_store.dart';
import 'package:mindloop/modules/steps/core/utils/steps_preferences.dart';
import 'package:mindloop/modules/finance/core/utils/currency_preferences.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/modules/finance/presentation/bloc/budget_bloc.dart';
import 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/widgets/coming_soon_card.dart';

enum _HubModule { hub, reminders, future }

class _ModuleCardMetrics {
  const _ModuleCardMetrics({
    required this.aspectRatio,
    required this.gridSpacing,
    required this.padding,
    required this.radius,
    required this.iconBox,
    required this.iconSize,
    required this.arrowBox,
    required this.arrowSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.footerSize,
  });

  final double aspectRatio;
  final double gridSpacing;
  final double padding;
  final double radius;
  final double iconBox;
  final double iconSize;
  final double arrowBox;
  final double arrowSize;
  final double titleSize;
  final double subtitleSize;
  final double footerSize;

  factory _ModuleCardMetrics.fromContext(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final viewPadding = media.padding;
    final usableHeight =
        height - viewPadding.top - viewPadding.bottom;

    final gridSpacing = width < 360 ? 10.0 : width < 420 ? 12.0 : 14.0;
    const horizontalInset = 32.0;
    final cellWidth = (width - horizontalInset - gridSpacing) / 2;

    // Header, greeting card, section title, bottom nav + FAB notch.
    const fixedChrome = 300.0;
    const bottomNavReserve = 96.0;
    final gridAreaHeight = (usableHeight - fixedChrome - bottomNavReserve)
        .clamp(280.0, usableHeight * 0.58);
    final cellHeight = (gridAreaHeight - gridSpacing) / 2;
    final aspectRatio = (cellWidth / cellHeight).clamp(0.62, 0.95);

    final textScale = media.textScaler.scale(1).clamp(1.0, 1.35);
    final scale = (cellHeight / 128).clamp(1.0, 1.45) * textScale;

    return _ModuleCardMetrics(
      aspectRatio: aspectRatio,
      gridSpacing: gridSpacing,
      padding: 10 * scale,
      radius: 14 * scale,
      iconBox: 28 * scale,
      iconSize: 16 * scale,
      arrowBox: 22 * scale,
      arrowSize: 12 * scale,
      titleSize: 13 * scale,
      subtitleSize: 10.5 * scale,
      footerSize: 11 * scale,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _HubModule _module = _HubModule.hub;
  String _calculatorFooter = 'Quick math';
  String _pomodoroFooter = 'Start focus';
  String _stepsFooter = 'Shake to count';
  String _futureFooter = 'Coming soon';

  @override
  void initState() {
    super.initState();
    _refreshHubFooters();
  }

  void _refreshHubFooters() {
    setState(() {
      _calculatorFooter = CalculatorUsageTracker.footerLabel(sl());
      _pomodoroFooter = PomodoroPreferences.footerLabel(sl());
      _stepsFooter = StepsPreferences.footerLabel(sl());
      _futureFooter = 'Coming soon';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    final profileName = UserProfileStore(sl()).load().name.trim();
    final hubName = profileName.isNotEmpty ? profileName : auth.userName;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: isHub
                        ? _ProHubHeader(
                            name: _displayName(hubName),
                            onSettings: () => context.push('/settings'),
                          )
                        : _ProModuleHeader(
                            title: _moduleTitle(_module),
                            onBack: _backToHub,
                          ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, isHub ? 16 : 20, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
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
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
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
          calculatorFooter: _calculatorFooter,
          pomodoroFooter: _pomodoroFooter,
          stepsFooter: _stepsFooter,
          futureFooter: _futureFooter,
          onOpenReminders: () => _openModule(_HubModule.reminders),
          onOpenFinance: () => context.go('/finance/dashboard'),
          onOpenFuture: () => _openModule(_HubModule.future),
          onOpenPomodoro: () async {
            await context.push('/pomodoro');
            if (mounted) _refreshHubFooters();
          },
          onOpenSteps: () async {
            await context.push('/steps');
            if (mounted) _refreshHubFooters();
          },
          onOpenCalculator: () async {
            await context.push('/calculator');
            if (mounted) _refreshHubFooters();
          },
        ),
      _HubModule.reminders => _RemindersModuleView(
          reminders: reminders,
          timeFmt: timeFmt,
          onSeeAll: () => context.go('/calendar'),
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
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Good morning,',
      >= 12 && < 17 => 'Good afternoon,',
      >= 17 && < 21 => 'Good evening,',
      _ => 'Good night,',
    };
    const motivationPool = [
      'Small wins today build big results tomorrow.',
      'Stay consistent, your future self is watching.',
      'One focused step is enough for today.',
      'Progress matters more than perfect timing.',
      'Your effort today compounds quietly.',
      'Keep going, momentum loves discipline.',
      'Done is better than delayed.',
      'Show up first, motivation follows.',
      'Every day is a fresh restart.',
      'You are closer than you think.',
    ];
    final daySeed = now.difference(DateTime(now.year, 1, 1)).inDays;
    final dailyMotivation = motivationPool[daySeed % motivationPool.length];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E1E52), Color(0xFF0B153A), Color(0xFF101D4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -6,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProIconButton(
                    icon: Icons.menu_rounded,
                    onTap: onSettings,
                    iconColor: Colors.white,
                    background: Colors.white.withValues(alpha: 0.08),
                  ),
                  const Spacer(),
                  _ProAvatar(initial: name.substring(0, 1).toUpperCase()),
                  const SizedBox(width: 8),
                  _ProIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: onSettings,
                    iconColor: Colors.white,
                    background: Colors.white.withValues(alpha: 0.08),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.6,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dailyMotivation,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProModuleHeader extends StatelessWidget {
  const _ProModuleHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ProIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Track your upcoming tasks with clarity',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
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
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _ProIconButton extends StatelessWidget {
  const _ProIconButton({
    required this.icon,
    required this.onTap,
    this.size = 20,
    this.iconColor = AppColors.textPrimary,
    this.background = AppColors.surface,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: size, color: iconColor),
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
    required this.calculatorFooter,
    required this.pomodoroFooter,
    required this.stepsFooter,
    required this.futureFooter,
    required this.onOpenReminders,
    required this.onOpenFinance,
    required this.onOpenFuture,
    required this.onOpenPomodoro,
    required this.onOpenSteps,
    required this.onOpenCalculator,
  });

  final int todayCount;
  final double balance;
  final int upcomingCount;
  final String calculatorFooter;
  final String pomodoroFooter;
  final String stepsFooter;
  final String futureFooter;
  final VoidCallback onOpenReminders;
  final VoidCallback onOpenFinance;
  final VoidCallback onOpenFuture;
  final Future<void> Function() onOpenPomodoro;
  final Future<void> Function() onOpenSteps;
  final Future<void> Function() onOpenCalculator;

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyPreferences.formatter(decimalDigits: 0);
    final metrics = _ModuleCardMetrics.fromContext(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your Modules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onOpenFuture,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text(
                'View all',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: metrics.gridSpacing,
          crossAxisSpacing: metrics.gridSpacing,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: metrics.aspectRatio,
          children: [
            _PremiumModuleCard(
              metrics: metrics,
              title: 'MindLoop',
              subtitle: 'Daily clarity and focus',
              footerLeft: '$todayCount today',
              footerRight: '$upcomingCount upcoming',
              icon: Icons.psychology_alt_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFD5DAFF), Color(0xFFE8EBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: onOpenReminders,
            ),
            _PremiumModuleCard(
              metrics: metrics,
              title: 'Expense Manager',
              subtitle: 'Track and manage expenses',
              footerLeft: fmt.format(balance),
              footerColor: AppColors.income,
              icon: Icons.account_balance_wallet_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFD5F4EF), Color(0xFFE5FBF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: onOpenFinance,
            ),
            _PremiumModuleCard(
              metrics: metrics,
              title: 'Pomodoro',
              subtitle: 'Focus timer & breaks',
              footerLeft: pomodoroFooter,
              footerColor: const Color(0xFFE85D4C),
              icon: Icons.timer_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE4E1), Color(0xFFFFF0EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => onOpenPomodoro(),
            ),
            _PremiumModuleCard(
              metrics: metrics,
              title: 'Calculator',
              subtitle: 'Quick calculations',
              footerLeft: calculatorFooter,
              footerColor: AppColors.expense,
              icon: Icons.calculate_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFEED8), Color(0xFFFFF6E7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => onOpenCalculator(),
            ),
            _PremiumModuleCard(
              metrics: metrics,
              title: 'Step Counter',
              subtitle: 'Shake-based steps',
              footerLeft: stepsFooter,
              footerColor: const Color(0xFF10B981),
              icon: Icons.directions_walk_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFD1FAE5), Color(0xFFECFDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => onOpenSteps(),
            ),
          ],
        ).animate().fadeIn(duration: 380.ms),
      ],
    );
  }
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your MindLoop',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Keep focus with beautiful daily modules',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NextFocusCard extends StatelessWidget {
  const _NextFocusCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.event_note_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.north_east_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumModuleCard extends StatefulWidget {
  const _PremiumModuleCard({
    required this.metrics,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.footerLeft,
    this.footerRight,
    this.footerColor,
    this.footerProgress,
  });

  final _ModuleCardMetrics metrics;
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final String? footerLeft;
  final String? footerRight;
  final Color? footerColor;
  final double? footerProgress;

  @override
  State<_PremiumModuleCard> createState() => _PremiumModuleCardState();
}

class _PremiumModuleCardState extends State<_PremiumModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(m.padding),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(m.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: _pressed ? 8 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: m.iconBox,
                    height: m.iconBox,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(m.radius * 0.65),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.textPrimary,
                      size: m.iconSize,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: m.arrowBox,
                    height: m.arrowBox,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.north_east_rounded,
                      size: m.arrowSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: m.titleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: m.padding * 0.25),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: m.subtitleSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.footerLeft != null) ...[
                SizedBox(height: m.padding * 0.5),
                Text(
                  widget.footerLeft!,
                  style: TextStyle(
                    color: widget.footerColor ?? AppColors.textSecondary,
                    fontSize: m.footerSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (widget.footerRight != null)
                Text(
                  widget.footerRight!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: m.footerSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (widget.footerProgress != null) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: widget.footerProgress!.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    valueColor: AlwaysStoppedAnimation(
                      widget.footerColor ?? AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyMotivationCard extends StatelessWidget {
  const _DailyMotivationCard();

  @override
  Widget build(BuildContext context) {
    const quotes = [
      'Small steps each day create remarkable progress.',
      'Consistency beats intensity when goals matter.',
      'Focus on one task, finish strong, then move on.',
      'Your discipline today becomes confidence tomorrow.',
      'Clarity comes from action, not overthinking.',
      'Progress is quiet, keep showing up.',
      'Do less, but do it with full attention.',
      'Momentum starts with one completed reminder.',
      'You are building trust with your future self.',
      'A calm plan wins over chaotic hustle.',
    ];
    final now = DateTime.now();
    final daySeed = now.difference(DateTime(now.year, 1, 1)).inDays;
    final quote = quotes[daySeed % quotes.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1745), Color(0xFF132A70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Motivation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  quote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Text(
              DateFormat('MMM d').format(now),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubBottomDock extends StatelessWidget {
  const _HubBottomDock();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 10,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x17000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                _BottomNavItem(icon: Icons.home_filled, label: 'Home', active: true),
                _BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Calendar'),
                Spacer(),
                _BottomNavItem(icon: Icons.account_balance_wallet_outlined, label: 'Budget'),
                _BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
              ],
            ),
          ),
          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: () => context.push('/reminder/create'),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A5BFF), Color(0xFF4B6BFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B6BFF).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF5A5BFF) : AppColors.textMuted;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionDock extends StatelessWidget {
  const _QuickActionDock({
    required this.controller,
    required this.isOpen,
    required this.onToggle,
  });

  final AnimationController controller;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final slide = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    return Positioned(
      right: 18,
      bottom: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _FloatingQuickAction(
            icon: Icons.event_available_rounded,
            label: 'Add Reminder',
            animation: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: const Offset(0, 0),
            ).animate(slide),
            opacity: slide,
            visible: isOpen,
            onTap: () => context.push('/reminder/create'),
          ),
          _FloatingQuickAction(
            icon: Icons.payments_outlined,
            label: 'Add Expense',
            animation: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: const Offset(0, 0),
            ).animate(slide),
            opacity: slide,
            visible: isOpen,
            onTap: () => context.go('/finance/dashboard'),
          ),
          _FloatingQuickAction(
            icon: Icons.task_alt_rounded,
            label: 'Create Future Task',
            animation: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: const Offset(0, 0),
            ).animate(slide),
            opacity: slide,
            visible: isOpen,
            onTap: () => context.push('/future'),
          ),
          _FloatingQuickAction(
            icon: Icons.calculate_rounded,
            label: 'Open Calculator',
            animation: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: const Offset(0, 0),
            ).animate(slide),
            opacity: slide,
            visible: isOpen,
            onTap: () => context.push('/calculator'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'dashboardQuickFab',
            onPressed: onToggle,
            child: AnimatedRotation(
              turns: isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(isOpen ? Icons.close_rounded : Icons.bolt_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingQuickAction extends StatelessWidget {
  const _FloatingQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.animation,
    required this.opacity,
    required this.visible,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Animation<Offset> animation;
  final Animation<double> opacity;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: FadeTransition(
        opacity: opacity,
        child: SlideTransition(
          position: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
  static const _todayGradient = LinearGradient(
    colors: [Color(0xFFCFCBFF), Color(0xFFE3DCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const _upcomingGradient = LinearGradient(
    colors: [Color(0xFFBFF6EA), Color(0xFFDDFCF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final allUpcoming = [
      ...reminders.upcomingReminders,
    ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final todayCount = reminders.todayReminders.length;
    final upcomingCount = allUpcoming.length;
    final highlight = allUpcoming.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReminderMoodHero(
          todayCount: todayCount,
          upcomingCount: upcomingCount,
          onSeeAll: onSeeAll,
        ),
        const SizedBox(height: 16),
        if (highlight.isNotEmpty)
          GridView.builder(
            itemCount: highlight.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.22,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return _MiniReminderCard(
                reminder: highlight[index],
                gradient: index.isEven ? _todayGradient : _upcomingGradient,
              );
            },
          ),
        if (highlight.isNotEmpty) const SizedBox(height: 18),
        _SectionHeader(
          title: 'Upcoming',
          action: 'Calendar',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 12),
        if (allUpcoming.isEmpty)
          const _ProEmptyState(message: 'Nothing scheduled ahead.')
        else
          Column(
            children: [
              for (var i = 0; i < allUpcoming.take(8).length; i++) ...[
                _ReminderTile(
                  reminder: allUpcoming[i],
                  timeFmt: timeFmt,
                  backgroundGradient: i.isEven ? _todayGradient : _upcomingGradient,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

class _ReminderTile extends StatefulWidget {
  const _ReminderTile({
    required this.reminder,
    required this.timeFmt,
    required this.backgroundGradient,
  });

  final ReminderEntity reminder;
  final DateFormat timeFmt;
  final Gradient backgroundGradient;

  @override
  State<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<_ReminderTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d');
    final accent = AppColors.categoryAccent(widget.reminder.category);
    final now = DateTime.now();
    final daysLeft = widget.reminder.scheduledAt.difference(now).inDays.clamp(0, 999);
    final hoursLeft = widget.reminder.scheduledAt.difference(now).inHours.clamp(0, 999);
    final priority = widget.reminder.isCompleted ? 'Done' : 'Upcoming';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              widget.backgroundGradient.colors.first.withValues(alpha: 0.35),
              widget.backgroundGradient.colors.last.withValues(alpha: 0.26),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
          boxShadow: [
            const BoxShadow(
              color: Color(0x100A2A3C),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 20,
              spreadRadius: -10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.reminder.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: widget.backgroundGradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    dateFmt.format(widget.reminder.scheduledAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.timeFmt.format(widget.reminder.scheduledAt),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: _expanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${widget.timeFmt.format(widget.reminder.scheduledAt)} - ${DateFormat('hh:mm a').format(widget.reminder.scheduledAt.add(const Duration(hours: 1)))}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      daysLeft == 0
                          ? '${hoursLeft + 1}h left'
                          : '${daysLeft + 1}d left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.998, 0.998),
          end: const Offset(1, 1),
          duration: 2200.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _ReminderMoodHero extends StatelessWidget {
  const _ReminderMoodHero({
    required this.todayCount,
    required this.upcomingCount,
    required this.onSeeAll,
  });

  final int todayCount;
  final int upcomingCount;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECE6FF), Color(0xFFE3F7F5), Color(0xFFF3EFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E3F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120A2A3C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                ),
                child: const Icon(Icons.grid_view_rounded, size: 18),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFC9BAFF),
                child: const Icon(Icons.person_rounded, size: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Let's stay focused.\nYour reminders are on track.",
            style: TextStyle(
              fontSize: 24,
              height: 1.05,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$todayCount today • $upcomingCount upcoming',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSeeAll,
              child: const Text('Calendar'),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 2600.ms,
          color: Colors.white.withValues(alpha: 0.26),
        );
  }
}

class _MiniReminderCard extends StatelessWidget {
  const _MiniReminderCard({
    required this.reminder,
    required this.gradient,
  });

  final ReminderEntity reminder;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/reminder/${reminder.id}'),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120A2A3C),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.notes_rounded, size: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.north_east_rounded, size: 16, color: AppColors.textSecondary),
                ],
              ),
              const Spacer(),
              Text(
                reminder.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm().format(reminder.scheduledAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.996, 0.996),
          end: const Offset(1, 1),
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _PrimaryTaskCard extends StatelessWidget {
  const _PrimaryTaskCard({
    required this.reminder,
    required this.timeFmt,
  });

  final ReminderEntity reminder;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/reminder/${reminder.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.chartMint.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.task_alt_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'At ${timeFmt.format(reminder.scheduledAt)} • ${reminder.category.label}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderStatChip extends StatelessWidget {
  const _ReminderStatChip({
    required this.title,
    required this.value,
    required this.gradient,
  });

  final String title;
  final String value;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureModuleView extends StatelessWidget {
  const _FutureModuleView();

  static const _previewFeatures = [
    (Icons.timer_outlined, 'Pomodoro Clock', 'Focus sessions with breaks', true, '/pomodoro'),
    (Icons.directions_walk_outlined, 'Step Counter', 'Shake phone to count steps', true, '/steps'),
    (Icons.psychology_outlined, 'AI Assistant', 'Smart memory companion', false, ''),
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
            child: f.$4
                ? _LiveFeatureCard(
                    title: f.$2,
                    subtitle: f.$3,
                    icon: f.$1,
                    onTap: () => context.push(f.$5),
                  )
                : ComingSoonCard(title: f.$2, subtitle: f.$3, icon: f.$1),
          ),
        ),
      ],
    );
  }
}

class _LiveFeatureCard extends StatelessWidget {
  const _LiveFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE85D4C).withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: const Color(0xFFE85D4C)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
