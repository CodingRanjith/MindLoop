import 'package:flutter/material.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';

class PfmPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PfmPageHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.showDrawer = false,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  /// Opens [PfmDrawer] on the parent [Scaffold] (swipe from left edge also works).
  final bool showDrawer;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: PfmTheme.scaffold,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: leading ??
          (showDrawer
              ? Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: PfmTheme.textPrimary),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              : null),
      title: Text(title, style: PfmTheme.titleStyle),
      actions: actions,
    );
  }
}

class PfmHeroBalanceCard extends StatelessWidget {
  const PfmHeroBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.monthGrowthPercent,
    this.showGrowth = false,
  });

  final String label;
  final String amount;
  final double? monthGrowthPercent;
  final bool showGrowth;

  @override
  Widget build(BuildContext context) {
    final growth = monthGrowthPercent ?? 0;
    final positive = growth >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: PfmTheme.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PfmTheme.primary.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          if (showGrowth) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(
                  positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${growth.abs().toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Mockup-style white stat card (label, value, trend footer).
class PfmStatCard extends StatelessWidget {
  const PfmStatCard({
    super.key,
    required this.label,
    required this.value,
    this.trendUp,
    this.footerLabel,
  });

  final String label;
  final String value;
  final bool? trendUp;
  final String? footerLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PfmTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: PfmTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: PfmTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          if (footerLabel != null)
            Text(
              footerLabel!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: trendUp == true ? PfmTheme.income : PfmTheme.textSecondary,
              ),
            )
          else if (trendUp != null)
            Icon(
              trendUp! ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 18,
              color: trendUp! ? PfmTheme.income : PfmTheme.expense,
            )
          else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class PfmGreetingHeader extends StatelessWidget {
  const PfmGreetingHeader({
    super.key,
    required this.name,
    this.subtitle = 'Welcome Back',
    this.onAvatarTap,
  });

  final String name;
  final String subtitle;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PfmTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: PfmTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: PfmTheme.brandGradient,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: PfmTheme.surface,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: PfmTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: PfmTheme.chartNeeds,
                    shape: BoxShape.circle,
                    border: Border.all(color: PfmTheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PfmGradientFab extends StatelessWidget {
  const PfmGradientFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: PfmTheme.brandGradient,
        boxShadow: [
          BoxShadow(
            color: PfmTheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class PfmGrowthBadge extends StatelessWidget {
  const PfmGrowthBadge({super.key, required this.label, this.positive = true});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class PfmMetricTile extends StatelessWidget {
  const PfmMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendUp,
    this.iconColor = PfmTheme.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final bool? trendUp;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: PfmTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: PfmTheme.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PfmTheme.textPrimary),
          ),
          if (trend != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                if (trendUp != null)
                  Icon(
                    trendUp! ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 11,
                    color: trendUp! ? PfmTheme.income : PfmTheme.expense,
                  ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    trend!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: trendUp == true ? PfmTheme.income : PfmTheme.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class PfmSectionTitle extends StatelessWidget {
  const PfmSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: PfmTheme.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class PfmSurfaceCard extends StatelessWidget {
  const PfmSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PfmTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: PfmTheme.cardDecoration(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class PfmFilterChipRow extends StatelessWidget {
  const PfmFilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < labels.length - 1 ? 8 : 0),
            child: FilterChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) => onSelected(i),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : PfmTheme.textSecondary,
                fontSize: 13,
              ),
              backgroundColor: PfmTheme.surface,
              selectedColor: PfmTheme.primary,
              side: BorderSide(color: selected ? PfmTheme.primary : PfmTheme.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }),
      ),
    );
  }
}

class PfmMenuRow extends StatelessWidget {
  const PfmMenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PfmTheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? PfmTheme.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? PfmTheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: titleColor ?? PfmTheme.textPrimary,
                  ),
                ),
              ),
              if (showChevron)
                const Icon(Icons.chevron_right_rounded, color: PfmTheme.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class PfmProfileHeaderCard extends StatelessWidget {
  const PfmProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.initials,
  });

  final String name;
  final String email;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final letters = initials ?? (name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PfmTheme.profileGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: PfmTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              letters.length > 2 ? letters.substring(0, 2) : letters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PfmInsightTile extends StatelessWidget {
  const PfmInsightTile({
    super.key,
    required this.icon,
    required this.text,
    required this.iconBg,
    required this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return PfmSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: PfmTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PfmPrimaryButton extends StatelessWidget {
  const PfmPrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: PfmTheme.brandGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PfmTheme.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
