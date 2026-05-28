import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/core/constants/reminder_categories.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:mindloop/themes/calendar_ui_colors.dart';
import 'package:table_calendar/table_calendar.dart';

enum _CalendarView { month, agenda }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  _CalendarView _view = _CalendarView.month;
  ReminderCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
  }

  List<ReminderEntity> _remindersForDay(
    List<ReminderEntity> all,
    DateTime day,
  ) {
    return all
        .where(
          (r) =>
              r.scheduledAt.year == day.year &&
              r.scheduledAt.month == day.month &&
              r.scheduledAt.day == day.day,
        )
        .toList();
  }

  List<ReminderEntity> _filtered(List<ReminderEntity> all) {
    if (_categoryFilter == null) return all;
    return all.where((r) => r.category == _categoryFilter).toList();
  }

  List<ReminderEntity> _monthReminders(
    List<ReminderEntity> all,
    DateTime month,
  ) {
    return _filtered(all)
        .where(
          (r) =>
              r.scheduledAt.year == month.year &&
              r.scheduledAt.month == month.month,
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final allReminders = context.watch<ReminderBloc>().state.reminders;
    final filtered = _filtered(allReminders);
    final selected = _selected ?? DateTime.now();
    final dayReminders = _remindersForDay(filtered, selected);
    final monthReminders = _monthReminders(filtered, _focused);
    final monthDone = monthReminders.where((r) => r.isCompleted).length;
    final monthProgress = monthReminders.isEmpty
        ? 0.0
        : monthDone / monthReminders.length;
    final timeFmt = DateFormat.jm();
    final monthFmt = DateFormat.yMMMM();

    return ColoredBox(
      color: CalendarUiColors.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: CalendarUiColors.chipInactive,
                          child: Text(
                            (auth.userName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: CalendarUiColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CalendarUiColors.textSecondary,
                                ),
                              ),
                              Text(
                                auth.userName ?? 'Explorer',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: CalendarUiColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push('/reminder/create'),
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: CalendarUiColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: CalendarUiColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ViewChips(
                      selected: _view,
                      onChanged: (v) => setState(() => _view = v),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _categoryFilter == null,
                            onTap: () => setState(() => _categoryFilter = null),
                          ),
                          ...ReminderCategory.values.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _FilterChip(
                                label: c.label,
                                selected: _categoryFilter == c,
                                accent: CalendarUiColors.categoryAccent(c),
                                onTap: () => setState(
                                  () => _categoryFilter =
                                      _categoryFilter == c ? null : c,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_view == _CalendarView.month) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _LightCard(
                    child: TableCalendar<ReminderEntity>(
                      firstDay: DateTime.utc(2020),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focused,
                      selectedDayPredicate: (d) => isSameDay(_selected, d),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      daysOfWeekHeight: 28,
                      rowHeight: 44,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: false,
                        leftChevronIcon: Icon(
                          Icons.chevron_left_rounded,
                          color: CalendarUiColors.textPrimary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right_rounded,
                          color: CalendarUiColors.textPrimary,
                        ),
                        titleTextStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: CalendarUiColors.textPrimary,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: CalendarUiColors.textMuted,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: CalendarUiColors.textMuted,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        cellMargin: const EdgeInsets.all(4),
                        defaultTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CalendarUiColors.textPrimary,
                        ),
                        weekendTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CalendarUiColors.textPrimary,
                        ),
                        todayTextStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: CalendarUiColors.textPrimary,
                        ),
                        selectedTextStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        todayDecoration: BoxDecoration(
                          color: CalendarUiColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CalendarUiColors.textPrimary,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CalendarUiColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: CalendarUiColors.selectedDay,
                          shape: BoxShape.circle,
                        ),
                        defaultDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: CalendarUiColors.progressFill,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        markerSize: 5,
                        markerMargin: const EdgeInsets.only(top: 28),
                      ),
                      eventLoader: (day) => _remindersForDay(filtered, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selected = selectedDay;
                          _focused = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() => _focused = focusedDay);
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _LightCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthFmt.format(_focused),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: CalendarUiColors.textPrimary,
                              ),
                            ),
                            Text(
                              '$monthDone / ${monthReminders.length} done',
                              style: const TextStyle(
                                fontSize: 12,
                                color: CalendarUiColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: monthReminders.isEmpty ? 0 : monthProgress,
                            minHeight: 8,
                            backgroundColor: CalendarUiColors.progressTrack,
                            color: CalendarUiColors.progressFill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  _view == _CalendarView.month
                      ? 'Reminders · ${DateFormat.MMMd().format(selected)}'
                      : 'All reminders · ${monthFmt.format(_focused)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: CalendarUiColors.textPrimary,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _view == _CalendarView.month
                  ? _buildDayListSliver(dayReminders, timeFmt)
                  : _buildAgendaSliver(monthReminders, timeFmt),
            ),
            SliverToBoxAdapter(
              child: _BottomSummaryBar(
                count: _view == _CalendarView.month
                    ? dayReminders.length
                    : monthReminders.length,
                label: _view == _CalendarView.month
                    ? DateFormat.MMMd().format(selected)
                    : monthFmt.format(_focused),
                onAdd: () => context.push('/reminder/create'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayListSliver(List<ReminderEntity> items, DateFormat timeFmt) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: _LightCard(
          child: Text(
            'Nothing scheduled. Tap + to add a reminder.',
            style: TextStyle(color: CalendarUiColors.textSecondary),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final r = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReminderRow(
              reminder: r,
              time: timeFmt.format(r.scheduledAt),
              onTap: () => context.push('/reminder/${r.id}'),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  Widget _buildAgendaSliver(List<ReminderEntity> items, DateFormat timeFmt) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: _LightCard(
          child: Text(
            'No reminders this month.',
            style: TextStyle(color: CalendarUiColors.textSecondary),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final r = items[index];
          final showDateHeader = index == 0 ||
              !isSameDay(
                r.scheduledAt,
                items[index - 1].scheduledAt,
              );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader) ...[
                if (index > 0) const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    DateFormat('EEE, MMM d').format(r.scheduledAt),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CalendarUiColors.textSecondary,
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReminderRow(
                  reminder: r,
                  time: timeFmt.format(r.scheduledAt),
                  onTap: () => context.push('/reminder/${r.id}'),
                ),
              ),
            ],
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class _ViewChips extends StatelessWidget {
  const _ViewChips({required this.selected, required this.onChanged});

  final _CalendarView selected;
  final ValueChanged<_CalendarView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('Month', _CalendarView.month),
        const SizedBox(width: 8),
        _pill('Agenda', _CalendarView.agenda),
      ],
    );
  }

  Widget _pill(String label, _CalendarView value) {
    final isActive = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? CalendarUiColors.chipActive
              : CalendarUiColors.chipInactive,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isActive ? Colors.white : CalendarUiColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (accent ?? CalendarUiColors.chipActive)
              : CalendarUiColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : CalendarUiColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : CalendarUiColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LightCard extends StatelessWidget {
  const _LightCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: CalendarUiColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: CalendarUiColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminder,
    required this.time,
    required this.onTap,
  });

  final ReminderEntity reminder;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = CalendarUiColors.categoryAccent(reminder.category);
    return Material(
      color: CalendarUiColors.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      shadowColor: CalendarUiColors.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: CalendarUiColors.surface,
            boxShadow: const [
              BoxShadow(
                color: CalendarUiColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    reminder.category.icon,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: CalendarUiColors.textPrimary,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$time · ${reminder.category.label}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CalendarUiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  reminder.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: reminder.isCompleted
                      ? CalendarUiColors.progressFill
                      : CalendarUiColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSummaryBar extends StatelessWidget {
  const _BottomSummaryBar({
    required this.count,
    required this.label,
    required this.onAdd,
  });

  final int count;
  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
        decoration: BoxDecoration(
          color: CalendarUiColors.selectedDay,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
            bottom: Radius.circular(28),
          ),
          boxShadow: const [
            BoxShadow(
              color: CalendarUiColors.shadow,
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0
                        ? 'No reminders'
                        : '$count reminder${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: CalendarUiColors.textPrimary,
                minimumSize: const Size(0, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Add reminder',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
