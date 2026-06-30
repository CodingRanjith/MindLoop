import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/modules/finance/core/constants/pfm_categories.dart';
import 'package:mindloop/modules/finance/domain/entities/expense_category_entity.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_drawer.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_form_fields.dart';
import 'package:mindloop/modules/finance/presentation/widgets/pfm_ui_kit.dart';

class PfmCategoriesScreen extends StatelessWidget {
  const PfmCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PfmBloc>().state;
    final custom = state.expenseCategories.where((c) => !c.isDefault).toList();

    return Scaffold(
      backgroundColor: PfmTheme.scaffold,
      drawer: const PfmDrawer(),
      appBar: PfmPageHeader(
        title: 'Categories',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategorySheet(context),
        backgroundColor: PfmTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Category', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const PfmSectionTitle('Default Categories'),
          const SizedBox(height: 8),
          ...PfmCategories.defaultExpenseCategories.map(
            (c) => _CategoryTile(category: c, canEdit: false),
          ),
          if (custom.isNotEmpty) ...[
            const SizedBox(height: 20),
            const PfmSectionTitle('Custom Categories'),
            const SizedBox(height: 8),
            ...custom.map(
              (c) => _CategoryTile(
                category: c,
                canEdit: true,
                onEdit: () => _showCategorySheet(context, existing: c),
                onDelete: () => _confirmDelete(context, c),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseCategoryEntity category) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Remove "${category.name}"? Existing expenses keep this label.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<PfmBloc>().add(PfmCategoryDeleteRequested(category.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: PfmTheme.expense)),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context, {ExpenseCategoryEntity? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var icon = existing?.icon ?? 'more';
    var color = existing?.color ?? 0xFF6C5CE7;

    const iconOptions = [
      ('restaurant', Icons.restaurant_rounded),
      ('shopping_bag', Icons.shopping_bag_rounded),
      ('transport', Icons.directions_bus_rounded),
      ('health', Icons.health_and_safety_rounded),
      ('school', Icons.school_rounded),
      ('more', Icons.more_horiz_rounded),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return PfmFormSheet(
            title: existing == null ? 'New Category' : 'Edit Category',
            primaryLabel: 'Save',
            onPrimary: () {
              if (nameCtrl.text.trim().isEmpty) return;
              context.read<PfmBloc>().add(
                    PfmCategorySaveRequested(
                      ExpenseCategoryEntity(
                        id: existing?.id ?? '',
                        name: nameCtrl.text.trim(),
                        icon: icon,
                        color: color,
                      ),
                    ),
                  );
              Navigator.pop(ctx);
            },
            children: [
              PfmFormTextField(label: 'Name', controller: nameCtrl, hint: 'e.g. Subscriptions'),
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: iconOptions.map((opt) {
                  final selected = icon == opt.$1;
                  return ChoiceChip(
                    selected: selected,
                    label: Icon(opt.$2, size: 20),
                    onSelected: (_) => setState(() => icon = opt.$1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  0xFF6C5CE7,
                  0xFFEF4444,
                  0xFF22C55E,
                  0xFF3B82F6,
                  0xFFF59E0B,
                  0xFFEC4899,
                ].map((c) {
                  final selected = color == c;
                  return GestureDetector(
                    onTap: () => setState(() => color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: PfmTheme.textPrimary, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.canEdit,
    this.onEdit,
    this.onDelete,
  });

  final ExpenseCategoryEntity category;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PfmSurfaceCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: category.colorValue.withValues(alpha: 0.15),
              child: Icon(category.iconData, color: category.colorValue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            if (category.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PfmTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PfmTheme.primary),
                ),
              ),
            if (canEdit) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: PfmTheme.expense),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
