import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/core/constants/reminder_categories.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:mindloop/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/widgets/dynamic_background.dart';
import 'package:mindloop/widgets/glass_card.dart';
import 'package:mindloop/widgets/glow_button.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
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
              children: [
                if (LocalFileImage.canShowFile(item.imagePath))
                  LocalFileImage(
                    path: item.imagePath!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(16),
                  ),
                const SizedBox(height: 16),
                GlassCard(
                  animate: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(fmt.format(item.scheduledAt)),
                      const SizedBox(height: 8),
                      Chip(label: Text(item.category.label)),
                      if (item.note != null) ...[
                        const SizedBox(height: 12),
                        Text(item.note!),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                GlowButton(
                  label: 'Preview Alert',
                  onPressed: () => context.push('/alert', extra: item),
                ),
                const SizedBox(height: 12),
                GlowButton(
                  label: 'Delete',
                  outlined: true,
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
        ),
      ),
    );
  }
}
