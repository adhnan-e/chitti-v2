/// Payment Collection Screen - Organizer UI for collecting payments
///
/// Features:
/// - View all members with pending dues
/// - Record payments with receipt generation
/// - View payment method breakdown
/// - Verify pending payments
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/services.dart';
import '../core/models/models.dart';
import '../utils/currency_utils.dart';
import 'payment_success_screen.dart';
import 'winner_selection_screen.dart';
import 'monthly_report_screen.dart';

class PaymentCollectionScreen extends StatefulWidget {
  final Map<String, dynamic> chittiData;

  const PaymentCollectionScreen({super.key, required this.chittiData});

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _members = [];
  List<Transaction> _allTransactions = [];
  Map<String, Map<String, dynamic>> _slotWinners = {}; // slotId -> winnerData
  bool _isLoading = true;
  String? _error;

  String get _chittiId => widget.chittiData['id'] ?? '';
  late String _chittiName;
  late int _duration;
  late String _startMonth;
  Map<String, dynamic>? _chittiMetadata;

  @override
  void initState() {
    super.initState();
    _chittiMetadata = widget.chittiData;
    _chittiName = widget.chittiData['name'] ?? 'Chitti';
    _duration = widget.chittiData['duration'] ?? 12;
    _startMonth = widget.chittiData['startMonth'] ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      // Fetch fresh Chitti data from Database
      final chittiSnap = await DatabaseService().getChitti(_chittiId);
      if (chittiSnap == null) {
        throw Exception('Chitti not found');
      }

      final freshChittiData = Map<String, dynamic>.from(chittiSnap);
      _chittiMetadata = freshChittiData;
      _chittiName = freshChittiData['name'] ?? 'Chitti';
      _duration = freshChittiData['duration'] ?? 12;
      _startMonth = freshChittiData['startMonth'] ?? '';

      // Load members data
      final membersData = freshChittiData['members'] as Map?;
      if (membersData != null) {
        _members = membersData.entries.map((e) {
          final slotData = Map<String, dynamic>.from(e.value as Map);
          slotData['slotId'] = e.key;
          // UI State for expansion
          slotData['isExpanded'] = false;
          return slotData;
        }).toList();

        // Sort by slot number
        _members.sort(
          (a, b) => (a['slotNumber'] ?? 0).compareTo(b['slotNumber'] ?? 0),
        );

        // Track seen slot numbers for group detection if needed
        _checkAndFetchMissingNames();
      }

      // Load all transactions
      final txnService = TransactionService();
      _allTransactions = await txnService.getChittiTransactions(_chittiId);

      // Load winners
      final winnersList = await DatabaseService().getChittiWinners(_chittiId);
      final winnersMap = <String, Map<String, dynamic>>{};
      for (var w in winnersList) {
        final slotId = w['slotId'];
        if (slotId != null) {
          winnersMap[slotId] = w;
        }
      }
      _slotWinners = winnersMap;

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAndFetchMissingNames() async {
    bool updated = false;
    for (int i = 0; i < _members.length; i++) {
      if (_members[i]['userName'] == null ||
          _members[i]['userName'] == 'Unknown') {
        final userId = _members[i]['userId'];
        if (userId != null) {
          final profile = await DatabaseService().getUserProfile(userId);
          if (profile != null && mounted) {
            final name = '${profile['firstName']} ${profile['lastname'] ?? ''}'
                .trim();
            setState(() {
              _members[i]['userName'] = name;
            });
            updated = true;
          }
        }
      }
    }
    if (updated && mounted) setState(() {});
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(
              context,
              contentColor,
              borderColor,
              textColorPrimary,
              primaryColor,
            ),

            // Loading / Error / Content
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: textColorSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Collection Summary
                    _buildCollectionSummary(
                      contentColor,
                      borderColor,
                      textColorPrimary,
                      textColorSecondary,
                      primaryColor,
                    ),
                    // Members List
                    Expanded(
                      child: _buildMembersTab(
                        contentColor,
                        borderColor,
                        textColorPrimary,
                        textColorSecondary,
                        primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickPaymentDialog(context, primaryColor),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Record Payment',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: contentColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 20, color: textColorPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Collection',
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WinnerSelectionScreen(
                    chittiId: _chittiId,
                    chittiName: _chittiName,
                    duration: _duration,
                    startMonth: _startMonth,
                    primaryColor: primaryColor,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.emoji_events_outlined,
              color: Colors.amber,
              size: 22,
            ),
            tooltip: 'Manage Winners',
          ),
          IconButton(
            onPressed: _loadData,
            icon: Icon(Icons.refresh, color: textColorPrimary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSummary(
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color primaryColor,
  ) {
    // Cumulative calculation from start month to current month
    final currentMonthKey = _getCurrentMonthKey(); // "2026-02"

    int totalCumulativeTargetCents = 0;
    int totalCumulativeCollectedCents = 0;

    for (final member in _members) {
      final slotId = member['slotId'];
      final winnerData = _slotWinners[slotId];
      final winnerMonth = winnerData?['monthKey'];
      int? discountInCents;
      final balance = member['balance'] as Map?;
      if (balance != null && balance['discountAmount'] != null) {
        discountInCents = CurrencyUtils.toCents(
          (balance['discountAmount'] as num).toDouble(),
        );
      }

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
        transactions: _allTransactions
            .where((t) => t.slotId == member['slotId'])
            .toList(),
      );

      // Sum all entries from start month up to and including current month
      for (final entry in schedule.entries) {
        if (entry.monthKey.compareTo(currentMonthKey) <= 0) {
          totalCumulativeTargetCents += entry.netAmountInCents;
          totalCumulativeCollectedCents += entry.paidAmountInCents;
        }
      }
    }

    final totalCollected = CurrencyUtils.fromCents(
      totalCumulativeCollectedCents,
    );
    final totalTarget = CurrencyUtils.fromCents(totalCumulativeTargetCents);
    final collectionRate = totalTarget > 0
        ? (totalCollected / totalTarget)
        : 0.0;
    final remainingBalance = (totalTarget - totalCollected).clamp(
      0.0,
      double.infinity,
    );

    final dateRangeLabel = _getDateRangeLabel();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Overview',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateRangeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Collection progress',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${(collectionRate * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
              ],
            ),
          ),
          // Bottom section with metrics
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
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
                  child: _buildMetricItem(
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
          ),
          // View Details Button
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyReportScreen(
                        chittiData: widget.chittiData,
                        members: _members,
                        transactions: _allTransactions,
                        slotWinners: _slotWinners,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.calendar_month, size: 16, color: primaryColor),
                label: Text(
                  'View Monthly Report',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColorPrimary,
    Color textColorSecondary,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColorSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColorPrimary,
          ),
        ),
      ],
    );
  }

  /// Returns a date range label from start month to current month
  /// e.g., "Jan - Feb 2026" or "Jan 2025 - Feb 2026" if spanning years
  String _getDateRangeLabel() {
    try {
      final startDate = CurrencyUtils.parseMonth(_startMonth);
      if (startDate == null) throw Exception('Invalid start month');

      final startYear = startDate.year;
      final startMonth = startDate.month;
      final now = DateTime.now();

      // Calculate which month we're in (clamped to duration)
      final monthsDiff =
          (now.year - startYear) * 12 + (now.month - startMonth) + 1;
      final currentMonthNum = monthsDiff.clamp(1, _duration);

      final currentDate = DateTime(
        startYear,
        startMonth + currentMonthNum - 1,
        1,
      );

      // Format the range
      if (startDate.year == currentDate.year) {
        // Same year: "Jan - Feb 2026"
        return '${DateFormat('MMM').format(startDate)} - ${DateFormat('MMM yyyy').format(currentDate)}';
      } else {
        // Different years: "Jan 2025 - Feb 2026"
        return '${DateFormat('MMM yyyy').format(startDate)} - ${DateFormat('MMM yyyy').format(currentDate)}';
      }
    } catch (_) {
      return DateFormat('MMMM yyyy').format(DateTime.now());
    }
  }

  String _getCurrentMonthKey() {
    try {
      final startDate = CurrencyUtils.parseMonth(_startMonth);
      if (startDate == null) throw Exception('Invalid start month');

      final startYear = startDate.year;
      final startMonth = startDate.month;
      final now = DateTime.now();

      final monthsDiff =
          (now.year - startYear) * 12 + (now.month - startMonth) + 1;
      final currentMonthNum = monthsDiff.clamp(1, _duration);

      final currentDate = DateTime(
        startYear,
        startMonth + currentMonthNum - 1,
        1,
      );
      return DateFormat('yyyy-MM').format(currentDate);
    } catch (_) {
      return DateFormat('yyyy-MM').format(DateTime.now());
    }
  }

  Widget _buildMembersTab(
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color primaryColor,
  ) {
    if (_members.isEmpty) {
      return Center(
        child: Text(
          'No members in this chitti',
          style: GoogleFonts.inter(fontSize: 14, color: textColorSecondary),
        ),
      );
    }

    final currency = SettingsService().getCurrencySymbol();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return _buildMemberCard(
          context,
          member,
          currency,
          contentColor,
          borderColor,
          textColorPrimary,
          textColorSecondary,
          primaryColor,
        );
      },
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Map<String, dynamic> member,
    String currency,
    Color contentColor,
    Color borderColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color primaryColor,
  ) {
    final slotId = member['slotId'];
    final slotNumber = member['slotNumber'] ?? 0;
    final userName = member['userName'] ?? 'Unknown';

    // Get Winner Details
    final winnerData = _slotWinners[slotId];
    final isWinner = winnerData != null;
    final String? winnerMonth = winnerData?['monthKey'] != null
        ? (() {
            final date = CurrencyUtils.parseMonth(winnerData!['monthKey'])!;
            return '${date.year}-${date.month.toString().padLeft(2, '0')}';
          })()
        : null;

    final balance = member['balance'] as Map?;
    final totalDueBalance = (balance?['totalDue'] as num?)?.toDouble() ?? 0;

    // Get Discount from balance or calculator config
    int? discountInCents;
    if (balance != null &&
        (balance['discountAmount'] as num?) != null &&
        (balance['discountAmount'] as num) > 0) {
      discountInCents = CurrencyUtils.toCents(
        (balance['discountAmount'] as num).toDouble(),
      );
    } else if (isWinner) {
      // Fallback: Calculate from rewardConfig or goldOptionRewards if balance is 0 or missing
      final rewardConfig = _chittiMetadata?['rewardConfig'] as Map?;
      final goldOptionRewards = _chittiMetadata?['goldOptionRewards'] as Map?;
      final totalAmount = (member['totalAmount'] as num?)?.toDouble() ?? 0.0;

      if (rewardConfig != null && rewardConfig['enabled'] == true) {
        final rewardVal = (rewardConfig['value'] as num?)?.toDouble() ?? 0.0;
        if (rewardConfig['type'] == 'Percentage') {
          final regularEMI = totalAmount / _duration;
          discountInCents = CurrencyUtils.toCents(
            regularEMI * (rewardVal / 100),
          );
        } else {
          discountInCents = CurrencyUtils.toCents(rewardVal);
        }
      } else if (goldOptionRewards != null) {
        // Try to find a matching reward by totalAmount
        for (var reward in goldOptionRewards.values) {
          if (reward is Map && reward['enabled'] == true) {
            final rewardTotalCost = (reward['totalCost'] as num?)?.toDouble();
            if (rewardTotalCost != null &&
                (rewardTotalCost - totalAmount).abs() < 1) {
              discountInCents = CurrencyUtils.toCents(
                (reward['calculatedAmount'] ?? 0).toDouble(),
              );
              break;
            }
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
      // Only cap if it's clearly wrong (e.g. prize instead of discount)
      discountInCents = cap;
    }

    // Fallback to member's totalAmount if totalDue is missing or zero (for new chittis)
    // totalDue is not used here as schedule generation handles it

    final goldOption = member['goldOption'] as Map?;
    final goldWeight = goldOption?['weight'] ?? '-';

    final isExpanded = member['isExpanded'] ?? false;

    // Settlement status
    final settlementStatusStr = member['settlementStatus'] as String? ?? 'none';
    final settlementStatus = SlotSettlementStatusX.fromString(
      settlementStatusStr,
    );
    final hasSettlement = settlementStatus != SlotSettlementStatus.none;
    final isFullySettled =
        settlementStatus == SlotSettlementStatus.settledUp ||
        settlementStatus == SlotSettlementStatus.refundCompleted;

    // Generate EMI Schedule for detailed view
    final schedule = BalanceCalculator.generateSchedule(
      slotId: slotId,
      chittyId: _chittiId,
      totalAmountInCents: CurrencyUtils.toCents(
        (member['totalAmount'] as num?)?.toDouble() ?? 0,
      ),
      duration: _duration,
      startMonth: _startMonth,
      paymentDay: widget.chittiData['paymentDay'] ?? 15,
      winnerMonth: winnerMonth,
      discountPerMonthInCents: discountInCents,
      transactions: _allTransactions
          .where((t) => t.slotId == member['slotId'])
          .toList(),
    );

    final totalPayableInCents = schedule.pendingEntries
        .where(
          (e) =>
              e.status == EMIStatus.overdue ||
              e.status == EMIStatus.due ||
              e.status == EMIStatus.upcoming ||
              e.status == EMIStatus.partial,
        )
        .fold(0, (sum, e) => sum + e.remainingInCents);

    final payableAmount = isFullySettled ? 0.0 : totalPayableInCents / 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded ? primaryColor.withOpacity(0.5) : borderColor,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    member['isExpanded'] = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar/Slot
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isWinner
                              ? Colors.amber.withOpacity(0.1)
                              : primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            slotNumber.toString(),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isWinner ? Colors.amber : primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: textColorPrimary,
                                  ),
                                ),
                                if (isWinner) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.emoji_events,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                ],
                              ],
                            ),
                            if (isWinner) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.military_tech,
                                      size: 10,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'WINNER',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Settlement status badge
                            if (hasSettlement) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isFullySettled
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isFullySettled
                                        ? const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      settlementStatus.emoji,
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      settlementStatus.displayLabel
                                          .toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isFullySettled
                                            ? const Color(0xFF10B981)
                                            : Colors.orange.shade700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              'Slot #$slotNumber • $goldWeight g Gold',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Payable Amount instead of Total Balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyUtils.format(payableAmount),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: payableAmount > 0
                                  ? Colors.orange
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            payableAmount > 0 ? 'PAYABLE' : 'PAID',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: payableAmount > 0
                                  ? Colors.orange
                                  : const Color(0xFF10B981),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, color: borderColor),
              _buildEMIExpandedSection(
                context,
                schedule,
                member,
                primaryColor,
                textColorPrimary,
                textColorSecondary,
                borderColor,
                winnerMonth: winnerMonth,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            hasSettlement
                                ? '/settlement_bill'
                                : '/payment_history',
                            arguments: {
                              'chittiId': _chittiId,
                              'slotId': member['slotId'],
                              'slotNumber': member['slotNumber'],
                              'userName': member['userName'],
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          hasSettlement ? 'Settlement Bill' : 'View Details',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Hide Record Payment when settlement is complete
                    if (!isFullySettled) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showPaymentDialog(
                            context,
                            member,
                            primaryColor,
                            winnerMonth: winnerMonth,
                            discountInCents: discountInCents,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Record Payment',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEMIExpandedSection(
    BuildContext context,
    EMISchedule schedule,
    Map<String, dynamic> member,
    Color primaryColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color borderColor, {
    String? winnerMonth,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EMI SCHEDULE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColorSecondary,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${schedule.paidMonthsCount}/${schedule.duration} Months Paid',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal scrolling EMI list
          SizedBox(
            height: 125,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: schedule.entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final entry = schedule.entries[index];
                return _buildEMITile(
                  entry,
                  member['userName'] ?? 'Member',
                  schedule.duration,
                  primaryColor,
                  textColorPrimary,
                  textColorSecondary,
                  borderColor,
                  isWinningMonth: entry.monthKey == winnerMonth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMITile(
    EMIEntry entry,
    String memberName,
    int totalDuration,
    Color primaryColor,
    Color textColorPrimary,
    Color textColorSecondary,
    Color borderColor, {
    bool isWinningMonth = false,
  }) {
    Color statusColor;
    IconData? statusIcon;

    switch (entry.status) {
      case EMIStatus.paid:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case EMIStatus.overdue:
        statusColor = const Color(0xFFF43F5E);
        statusIcon = Icons.error;
        break;
      case EMIStatus.due:
      case EMIStatus.upcoming:
      case EMIStatus.partial:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case EMIStatus.future:
        statusColor = textColorSecondary.withOpacity(0.3);
        statusIcon = null;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.status == EMIStatus.paid && entry.transactionIds.isNotEmpty
            ? () {
                final txnId = entry.transactionIds.first;
                final txn = _allTransactions.cast<Transaction?>().firstWhere(
                  (t) => t?.id == txnId,
                  orElse: () => null,
                );
                if (txn != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSuccessScreen(
                        transaction: txn,
                        chittiName: _chittiName,
                        memberName: memberName,
                        installmentInfo:
                            '${entry.monthNumber} / $totalDuration',
                        primaryColor: primaryColor,
                        onRecordAnother: () => Navigator.pop(context),
                        winnerMonth: isWinningMonth ? entry.monthKey : null,
                        discountInCents: entry.discountInCents,
                        originalAmountInCents: entry.originalAmountInCents,
                      ),
                    ),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isWinningMonth
                ? Colors.amber.withOpacity(0.1)
                : (entry.status == EMIStatus.future
                      ? Colors.transparent
                      : statusColor.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWinningMonth
                  ? Colors.amber
                  : (entry.status == EMIStatus.future
                        ? borderColor
                        : statusColor.withOpacity(0.2)),
              width: isWinningMonth ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              if (isWinningMonth)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Month ${entry.monthNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.monthLabel.split(' ')[0], // Jan, Feb, etc.
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColorPrimary,
                    ),
                  ),
                  // Amount Breakdown based on Status and Discount
                  if (entry.status == EMIStatus.paid) ...[
                    // User requirement: "if already paid then show the paid amount it have no discount"
                    Text(
                      entry.paidAmount.toStringAsFixed(0),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ] else if (entry.discountInCents > 0) ...[
                    // Unpaid, show discount breakdown
                    Text(
                      '${(entry.originalAmountInCents / 100).toStringAsFixed(0)} - ${(entry.discountInCents / 100).toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: textColorSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.netAmount.toStringAsFixed(0),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ] else ...[
                    // Regular unpaid installment
                    Text(
                      entry.isFirstMonth && entry.roundingRemainderInCents > 0
                          ? '${(entry.netAmount - entry.roundingRemainder).toStringAsFixed(0)} + ${entry.roundingRemainder % 1 == 0 ? entry.roundingRemainder.toInt().toString() : entry.roundingRemainder.toStringAsFixed(2)}'
                          : entry.netAmount.toStringAsFixed(0),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  if (statusIcon != null)
                    Icon(statusIcon, size: 14, color: statusColor)
                  else
                    Text(
                      '---',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: textColorSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    Map<String, dynamic> member,
    Color primaryColor, {
    String? winnerMonth,
    int? discountInCents,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentEntrySheet(
        chittyId: _chittiId,
        chittiName: _chittiName,
        member: member,
        duration: _duration,
        startMonth: _startMonth,
        primaryColor: primaryColor,
        transactions:
            _allTransactions, // Match member's transactions within sheet
        onPaymentRecorded: () {
          Navigator.pop(context);
          _loadData();
        },
        winnerMonth: winnerMonth,
        discountInCents: discountInCents,
      ),
    );
  }

  void _showQuickPaymentDialog(BuildContext context, Color primaryColor) {
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members to collect from')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickPaymentSheet(
        chittyId: _chittiId,
        chittiName: _chittiName,
        members: _members,
        duration: _duration,
        startMonth: _startMonth,
        primaryColor: primaryColor,
        transactions: _allTransactions,
        onPaymentRecorded: () {
          Navigator.pop(context);
          _loadData();
        },
        slotWinners: _slotWinners,
      ),
    );
  }
}

/// Bottom sheet for recording a payment
class _PaymentEntrySheet extends StatefulWidget {
  final String chittyId;
  final String chittiName;
  final Map<String, dynamic> member;
  final int duration;
  final String startMonth;
  final Color primaryColor;
  final List<Transaction> transactions;
  final VoidCallback onPaymentRecorded;
  final String? winnerMonth;
  final int? discountInCents;

  const _PaymentEntrySheet({
    required this.chittyId,
    required this.chittiName,
    required this.member,
    required this.duration,
    required this.startMonth,
    required this.primaryColor,
    required this.transactions,
    required this.onPaymentRecorded,
    this.winnerMonth,
    this.discountInCents,
  });

  @override
  State<_PaymentEntrySheet> createState() => _PaymentEntrySheetState();
}

class _PaymentEntrySheetState extends State<_PaymentEntrySheet> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  String? _selectedMonth;
  bool _isLoading = false;

  List<EMIEntry> get _schedule {
    final balance = widget.member['balance'] as Map?;
    final totalDueBalance = (balance?['totalDue'] as num?)?.toDouble() ?? 0;
    final totalDue =
        (totalDueBalance > 0
            ? totalDueBalance
            : (widget.member['totalAmount'] as num?)?.toDouble()) ??
        0;

    return BalanceCalculator.generateSchedule(
      slotId: widget.member['slotId'] ?? '',
      chittyId: widget.chittyId,
      totalAmountInCents: CurrencyUtils.toCents(totalDue),
      duration: widget.duration,
      startMonth: widget.startMonth,
      paymentDay: 15,
      winnerMonth: widget.winnerMonth,
      discountPerMonthInCents: widget.discountInCents,
      transactions: widget.transactions
          .where((t) => t.slotId == widget.member['slotId'])
          .toList(),
    ).entries;
  }

  List<EMIEntry> get _unpaidEntries {
    return _schedule.where((e) => e.status != EMIStatus.paid).toList();
  }

  EMIEntry? _getSelectedEntry() {
    final schedule = _schedule;
    if (schedule.isEmpty) return null;
    return schedule.firstWhere(
      (e) => e.monthKey == _selectedMonth,
      orElse: () => schedule.first,
    );
  }

  @override
  void initState() {
    super.initState();
    final unpaid = _unpaidEntries;
    if (unpaid.isNotEmpty) {
      _selectedMonth = unpaid.first.monthKey;
      _amountController.text = CurrencyUtils.fromCents(
        unpaid.first.remainingInCents,
      ).toStringAsFixed(0);
    }
  }

  Color _getStatusColor(EMIStatus status) {
    switch (status) {
      case EMIStatus.overdue:
        return const Color(0xFFF43F5E);
      case EMIStatus.due:
      case EMIStatus.partial:
      case EMIStatus.upcoming:
        return Colors.orange;
      case EMIStatus.future:
        return Colors.grey;
      case EMIStatus.paid:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final currency = SettingsService().getCurrencySymbol();

    final slotNumber = widget.member['slotNumber'] ?? 0;
    final userName = widget.member['userName'] ?? 'Unknown';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Payment',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColorPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Slot #$slotNumber - $userName',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: widget.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Amount field
            Text(
              'Amount ($currency)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColorSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColorPrimary,
              ),
              decoration: InputDecoration(
                prefixText: '$currency ',
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText:
                    _getSelectedEntry()?.discountInCents != null &&
                        _getSelectedEntry()!.discountInCents > 0
                    ? 'Includes ${CurrencyUtils.formatCentsCompact(_getSelectedEntry()!.discountInCents)} winner discount'
                    : null,
                helperStyle: GoogleFonts.inter(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Month selector
            Text(
              'For Month',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColorSecondary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedMonth,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText:
                    _getSelectedEntry()?.discountInCents != null &&
                        _getSelectedEntry()!.discountInCents > 0
                    ? 'Includes ${CurrencyUtils.formatCentsCompact(_getSelectedEntry()!.discountInCents)} winner discount'
                    : null,
                helperStyle: GoogleFonts.inter(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              isExpanded: true,
              items: _unpaidEntries.map((entry) {
                return DropdownMenuItem(
                  value: entry.monthKey,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(entry.status),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(entry.monthLabel),
                      const SizedBox(width: 12),
                      if (entry.discountInCents > 0) ...[
                        Text(
                          '${(entry.originalAmountInCents / 100).toStringAsFixed(0)} - ${(entry.discountInCents / 100).toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: textColorSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '($currency ${(entry.remainingInCents / 100).toStringAsFixed(0)})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(entry.status),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedMonth = v;
                  if (v != null) {
                    final entry = _unpaidEntries.firstWhere(
                      (e) => e.monthKey == v,
                    );
                    _amountController.text = CurrencyUtils.fromCents(
                      entry.remainingInCents,
                    ).toStringAsFixed(0);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Payment method
            Text(
              'Payment Method',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColorSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentMethod.values.map((method) {
                final isSelected = method == _selectedMethod;
                return ChoiceChip(
                  label: Text(method.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMethod = method);
                  },
                  selectedColor: widget.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColorSecondary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Reference (for non-cash)
            if (_selectedMethod != PaymentMethod.cash) ...[
              Text(
                'Reference Number',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColorSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _referenceController,
                decoration: InputDecoration(
                  hintText: 'Transaction ID / Cheque No.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            Text(
              'Notes (optional)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColorSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any additional notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _recordPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Record Payment',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _recordPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedMonth == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a month')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final txnService = TransactionService();
      final createdTxn = await txnService.recordPayment(
        slotId: widget.member['slotId'] ?? '',
        chittyId: widget.chittyId,
        amountInCents: CurrencyUtils.toCents(amount),
        monthKey: _selectedMonth!,
        paymentMethod: _selectedMethod,
        status: TransactionStatus.verified,
        referenceNumber: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        userName: widget.member['userName'],
        slotNumber: widget.member['slotNumber'],
      );

      if (mounted) {
        // Refresh data first
        widget.onPaymentRecorded();

        // Close the record sheet first
        Navigator.pop(context);

        // Calculate installment info (e.g. "3 / 12")
        final schedule = _schedule;
        final monthIndex = schedule.indexWhere(
          (e) => e.monthKey == _selectedMonth,
        );
        final installmentInfo = monthIndex != -1
            ? '${monthIndex + 1} / ${schedule.length}'
            : 'N/A';

        // Navigate to dedicated success screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              transaction: createdTxn,
              chittiName: widget.chittiName,
              memberName: widget.member['userName'] ?? 'Member',
              installmentInfo: installmentInfo,
              primaryColor: widget.primaryColor,
              onRecordAnother: () {
                // Return to collection screen (which is now refreshed)
              },
              winnerMonth: _getSelectedEntry()?.monthKey == widget.winnerMonth
                  ? widget.winnerMonth
                  : null,
              discountInCents: _getSelectedEntry()?.discountInCents,
              originalAmountInCents: _getSelectedEntry()?.originalAmountInCents,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Quick payment sheet for selecting member first
class _QuickPaymentSheet extends StatefulWidget {
  final String chittyId;
  final String chittiName;
  final List<Map<String, dynamic>> members;
  final int duration;
  final String startMonth;
  final Color primaryColor;
  final List<Transaction> transactions;
  final VoidCallback onPaymentRecorded;
  final Map<String, Map<String, dynamic>> slotWinners;

  const _QuickPaymentSheet({
    required this.chittyId,
    required this.chittiName,
    required this.members,
    required this.duration,
    required this.startMonth,
    required this.primaryColor,
    required this.transactions,
    required this.onPaymentRecorded,
    required this.slotWinners,
  });

  @override
  State<_QuickPaymentSheet> createState() => _QuickPaymentSheetState();
}

class _QuickPaymentSheetState extends State<_QuickPaymentSheet> {
  Map<String, dynamic>? _selectedMember;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    if (_selectedMember != null) {
      final slotId = _selectedMember!['slotId'];
      final winnerData = widget.slotWinners[slotId];
      final winnerMonth = winnerData?['monthKey'];
      int? discountInCents;
      final balance = _selectedMember!['balance'] as Map?;
      if (balance != null && balance['discountAmount'] != null) {
        discountInCents = CurrencyUtils.toCents(
          (balance['discountAmount'] as num).toDouble(),
        );
      }

      return _PaymentEntrySheet(
        chittyId: widget.chittyId,
        chittiName: widget.chittiName,
        member: _selectedMember!,
        duration: widget.duration,
        startMonth: widget.startMonth,
        primaryColor: widget.primaryColor,
        transactions: widget.transactions,
        onPaymentRecorded: widget.onPaymentRecorded,
        winnerMonth: winnerMonth,
        discountInCents: discountInCents,
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Member',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColorPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Member list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                final slotNumber = member['slotNumber'] ?? 0;
                final userName = member['userName'] ?? 'Unknown';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.primaryColor.withOpacity(0.1),
                    child: Text(
                      '#$slotNumber',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    userName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColorPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Slot #$slotNumber',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textColorSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => setState(() => _selectedMember = member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
