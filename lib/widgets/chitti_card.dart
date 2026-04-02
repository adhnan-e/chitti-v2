import 'package:flutter/material.dart';
import 'package:chitt/core/design/tokens/tokens.dart';
import 'package:chitt/core/design/components/components.dart';
import 'package:intl/intl.dart';

/// Chitti card displaying comprehensive information with long-press summary
class ChittiCard extends StatelessWidget {
  final Map<String, dynamic> chitti;
  final VoidCallback onTap;

  const ChittiCard({super.key, required this.chitti, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // --- Extract Data ---
    final name = chitti['name'] ?? 'Chitti';
    final status = (chitti['status'] ?? 'pending').toString().toLowerCase();
    final duration = chitti['duration'] ?? 12;
    final startMonth = chitti['startMonth'] ?? 'N/A';
    final endMonth = chitti['endMonth'] ?? 'N/A';
    final maxSlots = chitti['maxSlots'] ?? 0;
    final membersMap = chitti['members'] as Map? ?? {};
    final filledSlots = membersMap.keys.length;

    // Months completed calculation
    final monthsCompleted = chitti['monthsCompleted'] ?? 0;

    // Payment and winner dates
    final nextPaymentDate = _parseDate(chitti['nextPaymentDate']);
    final nextWinnerDate = _parseDate(chitti['nextWinnerDate']);

    // Outstanding dues count
    final outstandingDuesCount = _getOutstandingDuesCount(membersMap);

    // --- Status Badge ---
    AppBadgeVariant statusVariant;
    if (status == 'active') {
      statusVariant = AppBadgeVariant.success;
    } else if (status == 'completed') {
      statusVariant = AppBadgeVariant.info;
    } else {
      statusVariant = AppBadgeVariant.warning;
    }

    return AppCard(
      onTap: onTap,
      padding: Spacing.cardPaddingCompact,
      child: GestureDetector(
        onLongPress: () => _showPaymentSummary(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Name & Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppBadge(label: status.toUpperCase(), variant: statusVariant),
              ],
            ),
            const VSpace.xs(),

            // --- Duration ---
            _InfoRow(
              icon: Icons.timelapse_outlined,
              label: 'Duration: $duration months',
              context: context,
            ),
            const VSpace.xs(),

            // --- Date Range ---
            _InfoRow(
              icon: Icons.date_range_outlined,
              label: '$startMonth → $endMonth',
              context: context,
            ),
            const VSpace.xs(),

            // --- Slots ---
            _InfoRow(
              icon: Icons.group_outlined,
              label: 'Slots: $filledSlots / $maxSlots filled',
              context: context,
            ),
            const VSpace.xs(),

            // --- Progress (Months Completed) ---
            _InfoRow(
              icon: Icons.pie_chart_outline,
              label: 'Progress: $monthsCompleted / $duration months',
              context: context,
            ),
            const VSpace.sm(),

            // --- Divider ---
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const VSpace.sm(),

            // --- Next Payment Date ---
            if (nextPaymentDate != null)
              _DateCountdownRow(
                icon: Icons.payments_outlined,
                label: 'Next Payment',
                date: nextPaymentDate,
                context: context,
              ),
            if (nextPaymentDate != null) const VSpace.xs(),

            // --- Next Winner Date ---
            if (nextWinnerDate != null)
              _DateCountdownRow(
                icon: Icons.emoji_events_outlined,
                label: 'Next Winner',
                date: nextWinnerDate,
                context: context,
              ),

            // --- Outstanding Dues ---
            if (outstandingDuesCount > 0) ...[
              const VSpace.sm(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const HSpace.xs(),
                    Text(
                      '$outstandingDuesCount members with outstanding dues',
                      style: AppTypography.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  int _getOutstandingDuesCount(Map members) {
    int count = 0;
    for (final entry in members.entries) {
      final memberData = entry.value;
      if (memberData is Map) {
        final dueAmount = (memberData['dueAmount'] ?? 0) as num;
        if (dueAmount > 0) count++;
      }
    }
    return count;
  }

  void _showPaymentSummary(BuildContext context) {
    final membersMap = chitti['members'] as Map? ?? {};
    final paymentHistory = chitti['paymentHistory'] as List? ?? [];

    // Calculate totals from history
    double totalCollected = 0;
    double totalPending = 0;
    for (final payment in paymentHistory) {
      if (payment is Map) {
        totalCollected += (payment['amount'] ?? 0) as num;
      }
    }
    // Calculate pending from member dues
    List<MapEntry<String, num>> membersWithDues = [];
    for (final entry in membersMap.entries) {
      final memberData = entry.value;
      if (memberData is Map) {
        final dueAmount = (memberData['dueAmount'] ?? 0) as num;
        if (dueAmount > 0) {
          totalPending += dueAmount;
          membersWithDues.add(
            MapEntry(
              memberData['name']?.toString() ?? entry.key.toString(),
              dueAmount,
            ),
          );
        }
      }
    }
    // Sort by due amount descending
    membersWithDues.sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: Spacing.screenPadding,
          child: ListView(
            controller: scrollController,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                'Payment Summary',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
              const VSpace.md(),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Collected',
                      value: '₹${totalCollected.toStringAsFixed(0)}',
                      color: Theme.of(ctx).colorScheme.primary,
                      context: ctx,
                    ),
                  ),
                  const HSpace.md(),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Pending',
                      value: '₹${totalPending.toStringAsFixed(0)}',
                      color: Theme.of(ctx).colorScheme.error,
                      context: ctx,
                    ),
                  ),
                ],
              ),
              const VSpace.lg(),

              // Members with High Dues
              if (membersWithDues.isNotEmpty) ...[
                Text(
                  'Members with Outstanding Dues',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const VSpace.sm(),
                ...membersWithDues.map(
                  (entry) => _DueMemberTile(
                    name: entry.key,
                    amount: entry.value.toDouble(),
                    context: ctx,
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Text(
                      'No outstanding dues!',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
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

// --- Helper Widgets ---

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const HSpace.xs(),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DateCountdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime date;
  final BuildContext context;

  const _DateCountdownRow({
    required this.icon,
    required this.label,
    required this.date,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final now = DateTime.now();
    final daysRemaining = date.difference(now).inDays;
    final dateFormatted = DateFormat('MMM d').format(date);

    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const HSpace.xs(),
        Text(
          '$label: $dateFormatted',
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const HSpace.xs(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: daysRemaining <= 3
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            daysRemaining >= 0
                ? 'in $daysRemaining days'
                : '${-daysRemaining} days ago',
            style: AppTypography.labelSmall.copyWith(
              color: daysRemaining <= 3
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final BuildContext context;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const VSpace.xs(),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueMemberTile extends StatelessWidget {
  final String name;
  final double amount;
  final BuildContext context;

  const _DueMemberTile({
    required this.name,
    required this.amount,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const HSpace.sm(),
              Text(
                name,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTypography.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
