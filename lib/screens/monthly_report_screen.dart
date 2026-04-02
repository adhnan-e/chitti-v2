/// Monthly Report Screen - Month-wise collection breakdown
///
/// Features:
/// - Month selector to navigate between months
/// - Summary card for selected month
/// - Member-wise breakdown per month
/// - Visual status indicators
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/services.dart';
import '../core/models/models.dart';
import '../utils/currency_utils.dart';

class MonthlyReportScreen extends StatefulWidget {
  final Map<String, dynamic> chittiData;
  final List<Map<String, dynamic>> members;
  final List<Transaction> transactions;
  final Map<String, Map<String, dynamic>> slotWinners;

  const MonthlyReportScreen({
    super.key,
    required this.chittiData,
    required this.members,
    required this.transactions,
    required this.slotWinners,
  });

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late List<String> _monthKeys;
  late List<String> _monthLabels;
  int _selectedMonthIndex = 0;

  String get _chittiId => widget.chittiData['id'] ?? '';
  String get _chittiName => widget.chittiData['name'] ?? 'Chitti';
  int get _duration => widget.chittiData['duration'] ?? 12;
  String get _startMonth => widget.chittiData['startMonth'] ?? '';

  @override
  void initState() {
    super.initState();
    _generateMonthList();
    _selectCurrentMonth();
  }

  void _generateMonthList() {
    _monthKeys = [];
    _monthLabels = [];

    final startDate = CurrencyUtils.parseMonth(_startMonth);
    if (startDate == null) return;

    for (int i = 0; i < _duration; i++) {
      final monthDate = DateTime(startDate.year, startDate.month + i, 1);
      _monthKeys.add(DateFormat('yyyy-MM').format(monthDate));
      _monthLabels.add(DateFormat('MMM yyyy').format(monthDate));
    }
  }

  void _selectCurrentMonth() {
    final now = DateTime.now();
    final currentKey = DateFormat('yyyy-MM').format(now);

    // Find the index of current month, or the closest past month
    int index = _monthKeys.indexWhere((k) => k == currentKey);
    if (index == -1) {
      // Find the last month that is <= current date
      for (int i = _monthKeys.length - 1; i >= 0; i--) {
        if (_monthKeys[i].compareTo(currentKey) <= 0) {
          index = i;
          break;
        }
      }
    }
    _selectedMonthIndex = index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final contentColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const primaryColor = Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: contentColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Report',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColorPrimary,
              ),
            ),
            Text(
              _chittiName,
              style: GoogleFonts.inter(fontSize: 12, color: primaryColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Month Selector
          _buildMonthSelector(
            contentColor,
            borderColor,
            textColorPrimary,
            primaryColor,
          ),
          // Summary and Members List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMonthlySummary(
                    contentColor,
                    borderColor,
                    textColorPrimary,
                    textColorSecondary,
                    primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildMembersList(
                    contentColor,
                    borderColor,
                    textColorPrimary,
                    textColorSecondary,
                    primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color primaryColor,
  ) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: contentColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _monthLabels.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedMonthIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                _monthLabels[index],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : textColorPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryColor,
              backgroundColor: contentColor,
              side: BorderSide(color: isSelected ? primaryColor : borderColor),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedMonthIndex = index);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlySummary(
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color primaryColor,
  ) {
    if (_monthKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedMonthKey = _monthKeys[_selectedMonthIndex];
    int totalTargetCents = 0;
    int totalCollectedCents = 0;
    int paidCount = 0;
    int partialCount = 0;
    int unpaidCount = 0;

    for (final member in widget.members) {
      final slotId = member['slotId'];
      final winnerData = widget.slotWinners[slotId];
      final winnerMonth = winnerData?['monthKey'];
      final discountInCents = _getDiscountInCents(member, winnerData != null);

      final schedule = BalanceCalculator.generateSchedule(
        slotId: member['slotId'] ?? '',
        chittyId: _chittiId,
        totalAmountInCents: CurrencyUtils.toCents(
          (member['totalAmount'] as num?)?.toDouble() ?? 0,
        ),
        duration: _duration,
        startMonth: _startMonth,
        paymentDay: widget.chittiData['paymentDay'] ?? 15,
        winnerMonth: winnerMonth,
        discountPerMonthInCents: discountInCents,
        transactions: widget.transactions
            .where((t) => t.slotId == slotId)
            .toList(),
      );

      final entry = schedule.entries.cast<EMIEntry?>().firstWhere(
        (e) => e?.monthKey == selectedMonthKey,
        orElse: () => null,
      );

      if (entry != null) {
        totalTargetCents += entry.netAmountInCents;
        totalCollectedCents += entry.paidAmountInCents;

        if (entry.isFullyPaid) {
          paidCount++;
        } else if (entry.paidAmountInCents > 0) {
          partialCount++;
        } else {
          unpaidCount++;
        }
      }
    }

    final totalTarget = CurrencyUtils.fromCents(totalTargetCents);
    final totalCollected = CurrencyUtils.fromCents(totalCollectedCents);
    final collectionRate = totalTarget > 0
        ? (totalCollected / totalTarget)
        : 0.0;
    final remainingBalance = (totalTarget - totalCollected).clamp(
      0.0,
      double.infinity,
    );

    return Container(
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header with month and stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _monthLabels[_selectedMonthIndex],
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(collectionRate * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: collectionRate,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          // Stats Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Target',
                        CurrencyUtils.format(totalTarget),
                        Icons.flag_outlined,
                        primaryColor,
                        textColorPrimary,
                        textColorSecondary,
                      ),
                    ),
                    Container(width: 1, height: 40, color: borderColor),
                    Expanded(
                      child: _buildStatItem(
                        'Collected',
                        CurrencyUtils.format(totalCollected),
                        Icons.check_circle_outline,
                        const Color(0xFF10B981),
                        textColorPrimary,
                        textColorSecondary,
                      ),
                    ),
                    Container(width: 1, height: 40, color: borderColor),
                    Expanded(
                      child: _buildStatItem(
                        'Balance',
                        CurrencyUtils.format(remainingBalance),
                        Icons.account_balance_wallet_outlined,
                        Colors.orange,
                        textColorPrimary,
                        textColorSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: borderColor),
                const SizedBox(height: 12),
                // Payment Status Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusChip(
                      'Paid',
                      paidCount,
                      const Color(0xFF10B981),
                    ),
                    _buildStatusChip(
                      'Partial',
                      partialCount,
                      const Color(0xFF3B82F6),
                    ),
                    _buildStatusChip('Unpaid', unpaidCount, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColorPrimary,
    Color textColorSecondary,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: textColorSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColorPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color primaryColor,
  ) {
    if (_monthKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedMonthKey = _monthKeys[_selectedMonthIndex];

    // Build list of member entries for this month
    final memberEntries = <Map<String, dynamic>>[];

    for (final member in widget.members) {
      final slotId = member['slotId'];
      final winnerData = widget.slotWinners[slotId];
      final winnerMonth = winnerData?['monthKey'];
      final discountInCents = _getDiscountInCents(member, winnerData != null);

      final schedule = BalanceCalculator.generateSchedule(
        slotId: member['slotId'] ?? '',
        chittyId: _chittiId,
        totalAmountInCents: CurrencyUtils.toCents(
          (member['totalAmount'] as num?)?.toDouble() ?? 0,
        ),
        duration: _duration,
        startMonth: _startMonth,
        paymentDay: widget.chittiData['paymentDay'] ?? 15,
        winnerMonth: winnerMonth,
        discountPerMonthInCents: discountInCents,
        transactions: widget.transactions
            .where((t) => t.slotId == slotId)
            .toList(),
      );

      final entry = schedule.entries.cast<EMIEntry?>().firstWhere(
        (e) => e?.monthKey == selectedMonthKey,
        orElse: () => null,
      );

      if (entry != null) {
        memberEntries.add({
          'member': member,
          'entry': entry,
          'isWinner': winnerData != null,
        });
      }
    }

    // Sort by status (unpaid first, then partial, then paid)
    memberEntries.sort((a, b) {
      final entryA = a['entry'] as EMIEntry;
      final entryB = b['entry'] as EMIEntry;
      final orderA = entryA.isFullyPaid
          ? 2
          : entryA.paidAmountInCents > 0
          ? 1
          : 0;
      final orderB = entryB.isFullyPaid
          ? 2
          : entryB.paidAmountInCents > 0
          ? 1
          : 0;
      return orderA.compareTo(orderB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Member Breakdown',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColorPrimary,
            ),
          ),
        ),
        ...memberEntries.map((data) {
          final member = data['member'] as Map<String, dynamic>;
          final entry = data['entry'] as EMIEntry;
          final isWinner = data['isWinner'] as bool;

          return _buildMemberCard(
            member,
            entry,
            isWinner,
            contentColor,
            borderColor,
            textColorPrimary,
            textColorSecondary,
            primaryColor,
          );
        }),
      ],
    );
  }

  Widget _buildMemberCard(
    Map<String, dynamic> member,
    EMIEntry entry,
    bool isWinner,
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color primaryColor,
  ) {
    final slotNumber = member['slotNumber'] ?? 0;
    final userName = member['userName'] ?? 'Unknown';

    Color statusColor;
    String statusLabel;
    if (entry.isFullyPaid) {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'Paid';
    } else if (entry.paidAmountInCents > 0) {
      statusColor = const Color(0xFF3B82F6);
      statusLabel = 'Partial';
    } else {
      statusColor = Colors.orange;
      statusLabel = 'Unpaid';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Slot Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isWinner
                  ? Colors.amber.withOpacity(0.1)
                  : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                slotNumber.toString(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isWinner ? Colors.amber : primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColorPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Due: ${CurrencyUtils.format(entry.netAmount)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textColorSecondary,
                      ),
                    ),
                    if (entry.hasWinnerDiscount) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${CurrencyUtils.format(entry.discount)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Payment Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.format(
                  entry.paidAmountInCents > 0 || entry.isFullyPaid
                      ? entry.paidAmount
                      : entry.netAmount,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int? _getDiscountInCents(Map<String, dynamic> member, bool isWinner) {
    if (!isWinner) return null;

    final balance = member['balance'] as Map?;
    int? discountInCents;

    // 1. Try balance first
    if (balance != null &&
        (balance['discountAmount'] as num?) != null &&
        (balance['discountAmount'] as num) > 0) {
      discountInCents = CurrencyUtils.toCents(
        (balance['discountAmount'] as num).toDouble(),
      );
      if (discountInCents > 0) return discountInCents;
    }

    // 2. Fallback: Calculate from rewardConfigs
    final rewardConfig = widget.chittiData['rewardConfig'] as Map?;
    final goldOptionRewards = widget.chittiData['goldOptionRewards'] as Map?;
    final totalAmount = (member['totalAmount'] as num?)?.toDouble() ?? 0.0;

    // Try global reward config first
    if (rewardConfig != null && rewardConfig['enabled'] == true) {
      final rewardVal = (rewardConfig['value'] as num?)?.toDouble() ?? 0.0;
      if (rewardConfig['type'] == 'Percentage') {
        final regularEMI = totalAmount / _duration;
        discountInCents = CurrencyUtils.toCents(regularEMI * (rewardVal / 100));
      } else {
        discountInCents = CurrencyUtils.toCents(rewardVal);
      }
      if (discountInCents > 0) return discountInCents;
    }

    // Try gold option specific rewards
    if (goldOptionRewards != null) {
      // Step A: Precise matching by goldOption ID if available
      final goldOption = member['goldOption'] as Map?;
      final optionId = goldOption?['id']?.toString();
      if (optionId != null && goldOptionRewards.containsKey(optionId)) {
        final reward = goldOptionRewards[optionId] as Map;
        if (reward['enabled'] == true) {
          final amt = (reward['calculatedAmount'] ?? reward['value'] ?? 0);
          discountInCents = CurrencyUtils.toCents((amt as num).toDouble());
          if (discountInCents > 0) return discountInCents;
        }
      }

      // Step B: Lenient matching by totalAmount if ID match failed
      for (var reward in goldOptionRewards.values) {
        if (reward is Map && reward['enabled'] == true) {
          final rewardTotalCost = (reward['totalCost'] as num?)?.toDouble();
          if (rewardTotalCost != null &&
              (rewardTotalCost - totalAmount).abs() < 5) {
            // Increased tolerance to 5
            final amt = (reward['calculatedAmount'] ?? reward['value'] ?? 0);
            discountInCents = CurrencyUtils.toCents((amt as num).toDouble());
            if (discountInCents > 0) return discountInCents;
          }
        }
      }
    }

    // Ensure it's capped at EMI amount (approximated)
    int? cap;
    if (member['totalAmount'] != null) {
      cap = CurrencyUtils.toCents(
        (member['totalAmount'] as num).toDouble() / _duration,
      );
    }
    if (discountInCents != null && cap != null && discountInCents > cap) {
      discountInCents = cap;
    }

    return discountInCents;
  }
}
