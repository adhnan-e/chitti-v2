/// Slot Ledger Screen - Shows complete payment history and EMI schedule for a slot
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:chitt/services/services.dart';
import 'package:chitt/core/models/models.dart';
import 'package:chitt/utils/currency_utils.dart';
import 'package:chitt/screens/payment_success_screen.dart';
import 'package:chitt/screens/gold_handover_dialog.dart';
import 'package:chitt/core/design/tokens/tokens.dart';
import 'package:chitt/core/design/components/components.dart';

class SlotLedgerScreen extends StatefulWidget {
  const SlotLedgerScreen({super.key});

  @override
  State<SlotLedgerScreen> createState() => _SlotLedgerScreenState();
}

class _SlotLedgerScreenState extends State<SlotLedgerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _args;
  List<Transaction> _transactions = [];
  EMISchedule? _schedule;
  Slot? _slot;
  Map<String, dynamic>? _chittiData;
  bool _isLoading = true;
  String? _error;
  String _chittiName = 'Chitti';

  // Extracted from args
  String get _chittiId => _args?['chittiId'] ?? '';
  String get _slotId => _args?['slotId'] ?? '';
  int get _slotNumber => _args?['slotNumber'] ?? 0;
  String get _userName => _args?['userName'] ?? 'Member';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && _args == null) {
      _args = args;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_chittiId.isEmpty || _slotId.isEmpty) {
      setState(() {
        _error = 'Invalid slot data';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Load transactions
      final txnService = TransactionService();
      final transactions = await txnService.getSlotTransactions(
        _chittiId,
        _slotId,
      );

      // Load slot data for EMI schedule
      final chittiService = ChittiService();
      final chittiData = await chittiService.getChitti(_chittiId);

      if (chittiData != null) {
        final slotData = (chittiData['members'] as Map?)?[_slotId];
        if (slotData != null) {
          final slot = Slot.fromFirebase(
            _slotId,
            Map<String, dynamic>.from(slotData as Map),
          );

          final startMonth = chittiData['startMonth'] ?? '';

          int? discountPerMonthInCents;
          if (slot.discountPerMonth != null && slot.discountPerMonth! > 0) {
            discountPerMonthInCents = CurrencyUtils.toCents(
              slot.discountPerMonth!,
            );
          } else if (slot.isWinner && slot.winnerMonth != null) {
            final goldOptionRewards = chittiData['goldOptionRewards'] as Map?;
            if (goldOptionRewards != null) {
              final goldOptionId = slot.goldOptionId;
              if (goldOptionRewards.containsKey(goldOptionId)) {
                final reward = goldOptionRewards[goldOptionId] as Map;
                final value = (reward['value'] as num?)?.toDouble() ?? 0;
                if (value > 0) {
                  discountPerMonthInCents = CurrencyUtils.toCents(value);
                }
              } else {
                for (final entry in goldOptionRewards.entries) {
                  final reward = entry.value as Map;
                  if (reward['enabled'] == true) {
                    final value = (reward['value'] as num?)?.toDouble() ?? 0;
                    if (value > 0) {
                      discountPerMonthInCents = CurrencyUtils.toCents(value);
                      break;
                    }
                  }
                }
              }
            }
          }

          final schedule = BalanceCalculator.generateSchedule(
            slotId: _slotId,
            chittyId: _chittiId,

            totalAmountInCents: CurrencyUtils.toCents(slot.totalDue),
            duration: chittiData['duration'] ?? 12,
            startMonth: startMonth,
            paymentDay: chittiData['paymentDay'] ?? 7,
            winnerMonth: slot.winnerMonth,
            discountPerMonthInCents: discountPerMonthInCents,
            transactions: transactions,
          );

          setState(() {
            _transactions = transactions;
            _schedule = schedule;
            _slot = slot;
            _chittiData = Map<String, dynamic>.from(chittiData);
            _chittiName = chittiData['name'] ?? 'Chitti';
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_args == null) {
      return const AppScaffold(
        body: Center(child: Text('No slot data provided')),
      );
    }

    if (_isLoading) {
      return const AppScaffold(
        body: AppLoadingState(message: 'Loading ledger...'),
      );
    }

    if (_error != null) {
      return AppScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(_error!, style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              AppButton.primary(label: 'Retry', onPressed: _loadData),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      body: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.xs,
              Spacing.lg,
              Spacing.xl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back,
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Slot #$_slotNumber Ledger',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _userName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _loadData,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                  // Gold handover button
                  if (_slot != null && _slot!.isWinner) ...[
                    const SizedBox(height: 12),
                    _buildGoldHandoverSection(),
                  ],
                ],
              ),
            ),
          ),

          // Tabs
          Container(
            color: Colors.transparent,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D9488),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF0D9488),
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'EMI Schedule'),
                Tab(text: 'Transactions'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildEMIScheduleTab(), _buildTransactionsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final currency = DatabaseService().getCurrencySymbol();
    final schedule = _schedule;

    if (schedule == null) return const SizedBox.shrink();

    final totalDue = CurrencyUtils.fromCents(schedule.totalAmountInCents);
    final totalPaid = CurrencyUtils.fromCents(schedule.totalPaidInCents);
    final remaining = CurrencyUtils.fromCents(schedule.totalRemainingInCents);
    final progress = schedule.overallProgress;

    final hasHandover =
        _slot != null && _slot!.settlementStatus != SlotSettlementStatus.none;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: hasHandover ? 1.0 : progress / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(
                        hasHandover ? Colors.amber : Colors.white,
                      ),
                    ),
                  ),
                  hasHandover
                      ? const Icon(
                          Icons.diamond_rounded,
                          color: Colors.amber,
                          size: 28,
                        )
                      : Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    if (hasHandover) ...[
                      _buildSummaryRow(
                        'Locked Price',
                        '$currency ${totalDue.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Market Rate',
                        '$currency ${(_slot!.currentTotalGoldCost ?? totalDue).toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Collected',
                        '$currency ${totalPaid.toStringAsFixed(0)}',
                      ),
                      if ((_slot!.settlementDifference ?? 0) != 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          (_slot!.settlementDifference ?? 0) > 0
                              ? 'Adjustment'
                              : 'Refund',
                          '$currency ${(_slot!.settlementDifference ?? 0).abs().toStringAsFixed(0)}',
                        ),
                      ],
                    ] else ...[
                      _buildSummaryRow(
                        'Total',
                        '$currency ${totalDue.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Paid',
                        '$currency ${totalPaid.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Remaining',
                        '$currency ${remaining.toStringAsFixed(0)}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Settlement status row after handover
          if (hasHandover) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    _slot!.settlementStatus.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _slot!.settlementStatus.displayLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Show handover date
                  Text(
                    DateFormat(
                      'dd MMM yy',
                    ).format(_slot!.lastPaymentDate ?? DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGoldHandoverSection() {
    final slot = _slot;
    if (slot == null) return const SizedBox.shrink();

    final status = slot.settlementStatus;
    final currency = DatabaseService().getCurrencySymbol();

    // No handover yet - show handover button
    if (status == SlotSettlementStatus.none) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _onInitiateHandover,
          icon: const Icon(Icons.diamond_rounded, size: 18),
          label: Text(
            'Gold Handover',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
        ),
      );
    }

    // Has handover - show status
    final emoji = status.emoji;
    final label = status.displayLabel;
    final diff = slot.settlementDifference ?? 0;
    final absAmount = diff.abs();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (diff != 0)
                      Text(
                        '${diff > 0 ? "Member owes" : "Refund"}: $currency ${absAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                  ],
                ),
              ),
              if (status == SlotSettlementStatus.settlementPending ||
                  status == SlotSettlementStatus.refundPending)
                TextButton(
                  onPressed: _onInitiateHandover,
                  child: Text(
                    'Settle',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/settlement_bill',
                  arguments: {
                    'chittiId': _chittiId,
                    'slotId': _slotId,
                    'slotNumber': _slotNumber,
                    'userName': _userName,
                  },
                );
              },
              icon: const Icon(Icons.receipt_long_rounded, size: 16),
              label: Text(
                'View Settlement Bill',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onInitiateHandover() async {
    if (_slot == null || _chittiData == null) return;

    final result = await showGoldHandoverDialog(
      context: context,
      chittiId: _chittiId,
      slotId: _slotId,
      slot: _slot!,
      chittiData: _chittiData!,
    );

    if (result == true) {
      // Refresh data
      _loadData();
    }
  }

  Widget _buildEMIScheduleTab() {
    final schedule = _schedule;
    if (schedule == null || schedule.entries.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.calendar_today_rounded,
          title: 'No EMI Schedule',
          message: 'No schedule found for this slot.',
        ),
      );
    }

    final currency = DatabaseService().getCurrencySymbol();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: schedule.entries.length,
      itemBuilder: (context, index) {
        final entry = schedule.entries[index];
        return _buildEMIEntryCard(entry, currency);
      },
    );
  }

  Widget _buildEMIEntryCard(EMIEntry entry, String currency) {
    final statusColor = _getStatusColor(entry.status);
    final statusIcon = _getStatusIcon(entry.status);
    final netAmount = CurrencyUtils.fromCents(entry.netAmountInCents);

    final hasDiscount =
        entry.hasWinnerDiscount ||
        entry.discountInCents > 0 ||
        (entry.originalAmountInCents > entry.netAmountInCents);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: () => _showEMIDetails(context, entry, currency),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (hasDiscount ? const Color(0xFFF59E0B) : statusColor)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasDiscount ? Icons.emoji_events_rounded : statusIcon,
                  size: 20,
                  color: hasDiscount ? const Color(0xFFF59E0B) : statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.monthLabel,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.status.displayLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currency ${netAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  if (hasDiscount)
                    Text(
                      'Discounted',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'No Transactions',
          message: 'No payments recorded yet.',
        ),
      );
    }

    final currency = DatabaseService().getCurrencySymbol();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final txn = _transactions[_transactions.length - 1 - index];
        return _buildTransactionCard(txn, currency);
      },
    );
  }

  Widget _buildTransactionCard(Transaction txn, String currency) {
    final isPositive = txn.isCredit;
    final amountColor = isPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final amount = CurrencyUtils.fromCents(txn.amountInCents);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(context, txn, currency),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTransactionTypeIcon(txn.type),
                  size: 20,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM, yyyy').format(txn.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? '+' : '-'}$currency ${amount.abs().toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(EMIStatus status) {
    switch (status) {
      case EMIStatus.paid:
        return const Color(0xFF10B981);
      case EMIStatus.partial:
        return const Color(0xFF3B82F6);
      case EMIStatus.overdue:
        return const Color(0xFFEF4444);
      case EMIStatus.due:
        return const Color(0xFFF59E0B);
      case EMIStatus.upcoming:
      case EMIStatus.future:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData _getStatusIcon(EMIStatus status) {
    switch (status) {
      case EMIStatus.paid:
        return Icons.check_circle_rounded;
      case EMIStatus.partial:
        return Icons.pie_chart_rounded;
      case EMIStatus.overdue:
        return Icons.warning_rounded;
      case EMIStatus.due:
        return Icons.schedule_rounded;
      case EMIStatus.upcoming:
      case EMIStatus.future:
        return Icons.calendar_today_rounded;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.payment:
        return Icons.payments_rounded;
      case TransactionType.discount:
        return Icons.discount_rounded;
      case TransactionType.prizePayout:
        return Icons.emoji_events_rounded;
      case TransactionType.reversal:
        return Icons.undo_rounded;
      case TransactionType.adjustment:
        return Icons.tune_rounded;
      case TransactionType.openingBalance:
        return Icons.account_balance_wallet_rounded;
      case TransactionType.goldHandover:
        return Icons.diamond_rounded;
      case TransactionType.settlementPayment:
        return Icons.price_check_rounded;
      case TransactionType.settlementRefund:
        return Icons.currency_exchange_rounded;
    }
  }

  void _showEMIDetails(BuildContext context, EMIEntry entry, String currency) {
    final monthTransactions = _transactions
        .where(
          (t) =>
              t.monthKey == entry.monthKey && t.type == TransactionType.payment,
        )
        .toList();

    if (monthTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No payment recorded for ${entry.monthLabel}',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
      return;
    }

    _navigateToReceipt(context, monthTransactions.last, entry);
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction txn,
    String currency,
  ) {
    final emiEntry = _schedule?.entries.firstWhere(
      (e) => e.monthKey == txn.monthKey,
      orElse: () => EMIEntry(
        monthNumber: 0,
        monthKey: txn.monthKey,
        monthLabel: txn.monthKey,
        dueDate: txn.createdAt,
        originalAmountInCents: txn.amountInCents,
        netAmountInCents: txn.amountInCents,
        status: EMIStatus.paid,
      ),
    );

    _navigateToReceipt(context, txn, emiEntry);
  }

  void _navigateToReceipt(
    BuildContext context,
    Transaction txn,
    EMIEntry? entry,
  ) {
    final schedule = _schedule;
    final duration = schedule?.duration ?? 12;
    final paidCount = schedule?.paidMonthsCount ?? entry?.monthNumber ?? 1;

    int? discountInCents;
    int? originalAmountInCents;
    String? winnerMonth;

    if (entry != null && entry.hasWinnerDiscount) {
      discountInCents = entry.discountInCents;
      originalAmountInCents = entry.originalAmountInCents;
      winnerMonth = entry.monthLabel;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          transaction: txn,
          chittiName: _chittiName,
          memberName: _userName,
          installmentInfo: '$paidCount / $duration',
          primaryColor: const Color(0xFF0D9488),
          onRecordAnother: () {},
          winnerMonth: winnerMonth,
          discountInCents: discountInCents,
          originalAmountInCents: originalAmountInCents,
        ),
      ),
    );
  }
}
