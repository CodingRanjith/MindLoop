import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/core/di/injection.dart';
import 'package:mindloop/domain/repositories/pfm_repository.dart';
import 'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart';
import 'package:mindloop/widgets/app_list_rows.dart';
import 'package:mindloop/widgets/glass_card.dart';
import 'package:share_plus/share_plus.dart';

class ExpenseDataSettingsSection extends StatelessWidget {
  const ExpenseDataSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              'Expense Data',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          AppNavRow(
            title: 'Backup data',
            subtitle: 'Export all finance data as JSON',
            icon: Icons.cloud_upload_outlined,
            onTap: () => _backup(context),
          ),
          AppNavRow(
            title: 'Restore data',
            subtitle: 'Import from a backup file',
            icon: Icons.cloud_download_outlined,
            onTap: () => _restore(context),
          ),
        ],
      ),
    );
  }

  Future<void> _backup(BuildContext context) async {
    final json = await sl<PfmRepository>().exportBackupJson();
    if (json == null || !context.mounted) return;
    await Share.share(json, subject: 'MindLoop Finance Backup');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup ready to share or save')),
    );
  }

  Future<void> _restore(BuildContext context) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste your backup JSON below. This replaces all local finance data.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Paste JSON here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || ctrl.text.trim().isEmpty || !context.mounted) return;
    try {
      context.read<PfmBloc>().add(PfmBackupRestoreRequested(ctrl.text.trim()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finance data restored')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }
}
