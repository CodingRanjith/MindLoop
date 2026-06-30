import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/widgets/dynamic_background.dart';
import 'package:mindloop/shared/widgets/glass_card.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key, required this.reminderId});

  final String reminderId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReminderBloc>().state;
    ReminderEntity? reminder;
    for (final r in state.reminders) {
      if (r.id == reminderId) {
        reminder = r;
        break;
      }
    }

    if (reminder == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Reminder not found')),
      );
    }

    final item = reminder;
    final fmt = DateFormat.yMMMd().add_jm();
    final hasImage = LocalFileImage.canShowFile(item.imagePath);
    final categoryColor = AppColors.categoryAccent(item.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminder Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, size: 20),
            onPressed: () => context.push('/alert', extra: item),
          ),
        ],
      ),
      body: DynamicBackground(
        category: item.category,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Reminder',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A cleaner action-first layout for quick reminder control.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  animate: false,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.chartLavender.withValues(alpha: 0.22),
                              AppColors.chartMint.withValues(alpha: 0.18),
                              AppColors.chartAmber.withValues(alpha: 0.14),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                            height: 1.05,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.category.label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        children: [
                                          TextSpan(
                                            text: DateFormat.jm().format(item.scheduledAt),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '  Scheduled',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Hero(
                                tag: 'preview-${item.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: hasImage
                                      ? LocalFileImage(
                                          path: item.imagePath!,
                                          height: 96,
                                          width: 88,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 96,
                                          width: 88,
                                          color: AppColors.surfaceMuted,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.image_outlined,
                                            size: 20,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            item.note!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(18),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 17,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      fmt.format(item.scheduledAt),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _ActionCircleButton(
                              icon: Icons.visibility_rounded,
                              tooltip: 'Preview',
                              color: const Color(0xFFDCE5EE),
                              iconColor: AppColors.primary,
                              onPressed: () => _showImagePreview(context, item),
                            ),
                            const SizedBox(width: 8),
                            _ActionCircleButton(
                              icon: Icons.edit_rounded,
                              tooltip: 'Edit',
                              color: const Color(0xFFDDEEE8),
                              iconColor: AppColors.accent,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                context.push('/reminder/create', extra: item);
                              },
                            ),
                            const SizedBox(width: 8),
                            _ActionCircleButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'Delete',
                              color: const Color(0xFFFFE8E8),
                              iconColor: Colors.redAccent,
                              onPressed: () {
                                context.read<ReminderBloc>().add(
                                      ReminderDeleteRequested(item.id),
                                    );
                                context.pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, ReminderEntity reminder) {
    final hasImage = LocalFileImage.canShowFile(reminder.imagePath);
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Image Preview',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, _, _) {
        return SafeArea(
          child: Dismissible(
            key: const ValueKey('previewDismiss'),
            direction: DismissDirection.down,
            onDismissed: (_) => Navigator.of(context).pop(),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: Hero(
                  tag: 'preview-${reminder.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: hasImage
                        ? LocalFileImage(
                            path: reminder.imagePath!,
                            width: double.infinity,
                            height: 460,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.surfaceMuted,
                            height: 460,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_outlined,
                              size: 52,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = Curves.easeOutCubic.transform(animation.value);
        return Transform.scale(
          scale: 0.92 + (curved * 0.08),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  const _ActionCircleButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.9)),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
      ),
    );
  }
}
