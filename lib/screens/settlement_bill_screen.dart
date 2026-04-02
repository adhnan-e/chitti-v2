/// Settlement Bill Screen - Complete bill with all EMI & settlement transactions
///
/// Shows a printable-style bill after gold handover settlement with:
/// - Gold details (type, purity, weight)
/// - Complete EMI payment history
/// - Gold handover & settlement entries
/// - Final summary with locked price, market rate, adjustment
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chitt/services/services.dart';
import 'package:chitt/core/models/models.dart';
import 'package:chitt/utils/currency_utils.dart';

class SettlementBillScreen extends StatefulWidget {
  const SettlementBillScreen({super.key});

  @override
  State<SettlementBillScreen> createState() => _SettlementBillScreenState();
}

class _SettlementBillScreenState extends State<SettlementBillScreen> {
  Map<String, dynamic>? _args;
  Slot? _slot;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _chittiName = 'Chitti';

  String get _chittiId => _args?['chittiId'] ?? '';
  String get _slotId => _args?['slotId'] ?? '';
  int get _slotNumber => _args?['slotNumber'] ?? 0;
  String get _userName => _args?['userName'] ?? 'Member';

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
    try {
      setState(() => _isLoading = true);

      final txnService = TransactionService();
      final chittiService = ChittiService();

      final transactions = await txnService.getSlotTransactions(
        _chittiId,
        _slotId,
      );
      final chittiData = await chittiService.getChitti(_chittiId);

      Slot? slot;
      if (chittiData != null) {
        _chittiName = chittiData['name'] ?? 'Chitti';
        final slotData = (chittiData['members'] as Map?)?[_slotId];
        if (slotData != null) {
          slot = Slot.fromFirebase(
            _slotId,
            Map<String, dynamic>.from(slotData as Map),
          );
        }
      }

      // Sort transactions by date (oldest first for bill display)
      transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      setState(() {
        _transactions = transactions;
        _slot = slot;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _shareBill() {
    if (_slot == null) return;
    final currency = CurrencyUtils.currencySymbol;
    final goldOption = _slot!.goldOption;

    final buffer = StringBuffer();
    buffer.writeln('📋 *SETTLEMENT BILL*');
    buffer.writeln('═══════════════════════');
    buffer.writeln('*Chitti:* $_chittiName');
    buffer.writeln('*Member:* $_userName');
    buffer.writeln('*Slot:* #$_slotNumber');
    if (goldOption != null) {
      buffer.writeln(
        '*Gold:* ${goldOption.type} | ${goldOption.purity} | ${goldOption.weight}g',
      );
    }
    buffer.writeln('───────────────────────');
    buffer.writeln('*TRANSACTIONS:*');

    for (final txn in _transactions) {
      final date = DateFormat('dd/MM/yy').format(txn.createdAt);
      final amount = CurrencyUtils.formatCents(txn.amountInCents);
      buffer.writeln('$date  ${txn.type.displayLabel}  $amount');
    }

    buffer.writeln('───────────────────────');
    final totalPaid = _transactions.fold<int>(
      0,
      (sum, t) => sum + t.amountInCents,
    );
    buffer.writeln('*Total Paid:* ${CurrencyUtils.formatCents(totalPaid)}');
    buffer.writeln(
      '*Locked Price:* $currency ${_slot!.totalDue.toStringAsFixed(0)}',
    );
    if (_slot!.currentTotalGoldCost != null) {
      buffer.writeln(
        '*Market Rate:* $currency ${_slot!.currentTotalGoldCost!.toStringAsFixed(0)}',
      );
    }
    if (_slot!.settlementDifference != null &&
        _slot!.settlementDifference != 0) {
      final diff = _slot!.settlementDifference!;
      buffer.writeln(
        '*${diff > 0 ? 'Settlement Due' : 'Refund Due'}:* $currency ${diff.abs().toStringAsFixed(0)}',
      );
    }
    buffer.writeln(
      '*Status:* ${_slot!.settlementStatus.emoji} ${_slot!.settlementStatus.displayLabel}',
    );
    buffer.writeln('═══════════════════════');

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Settlement Bill',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          if (_slot != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: _shareBill,
              tooltip: 'Share Bill',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _slot == null
          ? Center(
              child: Text(
                'No settlement data found',
                style: GoogleFonts.inter(color: textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Header Card ──
                  _buildHeaderCard(
                    cardColor,
                    textPrimary,
                    textSecondary,
                    borderColor,
                  ),
                  const SizedBox(height: 16),

                  // ── Gold Details Card ──
                  if (_slot!.goldOption != null)
                    _buildGoldDetailsCard(
                      cardColor,
                      textPrimary,
                      textSecondary,
                      borderColor,
                    ),
                  if (_slot!.goldOption != null) const SizedBox(height: 16),

                  // ── Transaction List ──
                  _buildTransactionList(
                    cardColor,
                    textPrimary,
                    textSecondary,
                    borderColor,
                  ),
                  const SizedBox(height: 16),

                  // ── Settlement Summary ──
                  _buildSettlementSummary(
                    cardColor,
                    textPrimary,
                    textSecondary,
                    borderColor,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Chitti name
          Text(
            _chittiName,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Settlement Bill',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeaderField(
                  'Member',
                  _userName,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildHeaderField(
                  'Slot',
                  '#$_slotNumber',
                  textPrimary,
                  textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeaderField(
                  'Status',
                  '${_slot!.settlementStatus.emoji} ${_slot!.settlementStatus.displayLabel}',
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildHeaderField(
                  'Date',
                  _slot!.lastPaymentDate != null
                      ? DateFormat(
                          'dd MMM yyyy',
                        ).format(_slot!.lastPaymentDate!)
                      : '-',
                  textPrimary,
                  textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderField(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoldDetailsCard(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    final gold = _slot!.goldOption!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Gold Details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGoldField(
                  'Type',
                  gold.type,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildGoldField(
                  'Purity',
                  gold.purity,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildGoldField(
                  'Weight',
                  '${gold.weight.toStringAsFixed(2)} g',
                  textPrimary,
                  textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGoldField(
                  'Monthly EMI',
                  CurrencyUtils.format(gold.price),
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildGoldField(
                  'Total Value',
                  CurrencyUtils.format(_slot!.totalDue),
                  textPrimary,
                  textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoldField(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  'All Transactions',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_transactions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    'Date',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Description',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Method',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Transaction rows
          ...List.generate(_transactions.length, (i) {
            final txn = _transactions[i];
            final isGold =
                txn.type == TransactionType.goldHandover ||
                txn.type == TransactionType.settlementPayment ||
                txn.type == TransactionType.settlementRefund;
            final isEven = i.isEven;

            return Container(
              color: isEven
                  ? Colors.transparent
                  : textSecondary.withValues(alpha: 0.03),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      DateFormat('dd/MM/yy').format(txn.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGold
                              ? txn.type.displayLabel
                              : 'EMI - ${txn.monthKey}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isGold ? Colors.amber.shade700 : textPrimary,
                          ),
                        ),
                        if (txn.receiptNumber != null)
                          Text(
                            '#${txn.receiptNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      txn.paymentMethod.displayLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      CurrencyUtils.formatCents(txn.amountInCents),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isGold ? Colors.amber.shade700 : textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Total row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'TOTAL PAID',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyUtils.formatCents(
                    _transactions.fold<int>(
                      0,
                      (sum, t) => sum + t.amountInCents,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementSummary(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    final currency = CurrencyUtils.currencySymbol;
    final lockedPrice = _slot!.totalDue;
    final marketRate = _slot!.currentTotalGoldCost ?? lockedPrice;
    final totalPaidCents = _transactions.fold<int>(
      0,
      (sum, t) => sum + t.amountInCents,
    );
    final totalPaid = CurrencyUtils.fromCents(totalPaidCents);
    final difference = _slot!.settlementDifference ?? 0.0;
    final isFullySettled =
        _slot!.settlementStatus == SlotSettlementStatus.settledUp ||
        _slot!.settlementStatus == SlotSettlementStatus.refundCompleted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFullySettled
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFullySettled
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                color: isFullySettled ? const Color(0xFF10B981) : Colors.amber,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Settlement Summary',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Locked Price (Total EMIs)',
            '$currency ${lockedPrice.toStringAsFixed(0)}',
            textPrimary,
            textSecondary,
          ),
          _buildSummaryRow(
            'Current Market Rate',
            '$currency ${marketRate.toStringAsFixed(0)}',
            textPrimary,
            textSecondary,
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            'Total Collected',
            '$currency ${totalPaid.toStringAsFixed(0)}',
            textPrimary,
            textSecondary,
            isBold: true,
          ),
          if (difference != 0) ...[
            const Divider(height: 20),
            _buildSummaryRow(
              difference > 0
                  ? 'Settlement Due (Member → Organizer)'
                  : 'Refund Due (Organizer → Member)',
              '$currency ${difference.abs().toStringAsFixed(0)}',
              difference > 0 ? Colors.orange : const Color(0xFF10B981),
              textSecondary,
              isBold: true,
              isHighlight: true,
            ),
          ],
          const SizedBox(height: 16),
          // Status badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isFullySettled
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFullySettled
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${_slot!.settlementStatus.emoji}  ${_slot!.settlementStatus.displayLabel}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isFullySettled
                      ? const Color(0xFF10B981)
                      : Colors.amber.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: labelColor),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
