/// Gold Handover Dialog - Handles gold handover initiation and settlement options
///
/// Multi-step dialog:
/// Step 1: Enter current total gold cost
/// Step 2: Review settlement calculation
/// Step 3: Choose settlement option (if applicable)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/services.dart';
import 'package:chitt/core/models/models.dart';

/// Shows the gold handover dialog
/// Returns true if handover was completed successfully
Future<bool?> showGoldHandoverDialog({
  required BuildContext context,
  required String chittiId,
  required String slotId,
  required Slot slot,
  required Map<String, dynamic> chittiData,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => GoldHandoverDialog(
      chittiId: chittiId,
      slotId: slotId,
      slot: slot,
      chittiData: chittiData,
    ),
  );
}

class GoldHandoverDialog extends StatefulWidget {
  final String chittiId;
  final String slotId;
  final Slot slot;
  final Map<String, dynamic> chittiData;

  const GoldHandoverDialog({
    super.key,
    required this.chittiId,
    required this.slotId,
    required this.slot,
    required this.chittiData,
  });

  @override
  State<GoldHandoverDialog> createState() => _GoldHandoverDialogState();
}

class _GoldHandoverDialogState extends State<GoldHandoverDialog> {
  final _goldCostController = TextEditingController();
  final _notesController = TextEditingController();
  final _manualAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _step = 0; // 0: enter cost, 1: review, 2: settlement options
  bool _isProcessing = false;
  String? _error;

  late double _totalPaid;
  late double _lockedTotalValue;
  late String _goldType;
  late String _goldPurity;
  late double _goldWeight;
  late String _currency;

  double _currentTotalGoldCost = 0;
  double _settlementDifference = 0;

  GoldHandover? _handover;

  // For revamp EMI
  int _revampInstallments = 3;
  int _maxInstallments = 12;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _totalPaid = widget.slot.totalPaid;
    _lockedTotalValue = widget.slot.totalDue;
    _currency = DatabaseService().getCurrencySymbol();

    // Get gold option details
    final goldOption = widget.slot.goldOption;
    if (goldOption != null) {
      _goldType = goldOption.type;
      _goldPurity = goldOption.purity;
      _goldWeight = goldOption.weight;
    } else {
      _goldType = 'Gold';
      _goldPurity = 'N/A';
      _goldWeight = 0;
    }

    // Calculate max installments from remaining chitti duration
    final duration = widget.chittiData['duration'] as int? ?? 12;
    final startMonth = widget.chittiData['startMonth'] as String? ?? '';
    if (startMonth.isNotEmpty) {
      try {
        final parts = startMonth.split('-');
        final startDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        final endDate = DateTime(startDate.year, startDate.month + duration);
        final now = DateTime.now();
        _maxInstallments = _monthsBetween(now, endDate);
        if (_maxInstallments < 1) _maxInstallments = 1;
        if (_revampInstallments > _maxInstallments) {
          _revampInstallments = _maxInstallments;
        }
      } catch (_) {
        _maxInstallments = duration;
      }
    } else {
      _maxInstallments = duration;
    }
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  @override
  void dispose() {
    _goldCostController.dispose();
    _notesController.dispose();
    _manualAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Gold Handover', 'Settlement Review', 'Settlement Options'];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[_step],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Slot #${widget.slot.slotNumber} • ${widget.slot.userName ?? 'Member'}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0:
        return _buildCostInputStep();
      case 1:
        return _buildReviewStep();
      case 2:
        return _buildSettlementOptionsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ============ Step 0: Enter Gold Cost ============

  Widget _buildCostInputStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),

          // Gold details summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Type', _goldType),
                const SizedBox(height: 8),
                _buildInfoRow('Purity', _goldPurity),
                const SizedBox(height: 8),
                _buildInfoRow('Weight', '${_goldWeight}g'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Locked Price',
                  '$_currency ${_lockedTotalValue.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Total Paid',
                  '$_currency ${_totalPaid.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Current Total Gold Cost',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter the total market cost of the gold being handed over',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _goldCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '$_currency ',
              prefixStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF59E0B),
                  width: 2,
                ),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter gold cost';
              final cost = double.tryParse(value);
              if (cost == null || cost <= 0) return 'Must be greater than 0';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Optional notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _onProceedToReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Calculate Settlement',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onProceedToReview() {
    if (!_formKey.currentState!.validate()) return;

    _currentTotalGoldCost = double.parse(_goldCostController.text);
    _settlementDifference = _currentTotalGoldCost - _totalPaid;

    setState(() {
      _step = 1;
      _error = null;
    });
  }

  // ============ Step 1: Settlement Review ============

  Widget _buildReviewStep() {
    final isExactMatch = _settlementDifference == 0;
    final memberOwes = _settlementDifference > 0;
    final absAmount = _settlementDifference.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        // Settlement calculation breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _buildCalcRow(
                'Current Gold Cost',
                '$_currency ${_currentTotalGoldCost.toStringAsFixed(0)}',
              ),
              const Divider(height: 16),
              _buildCalcRow(
                'Total Paid',
                '- $_currency ${_totalPaid.toStringAsFixed(0)}',
              ),
              const Divider(height: 16, thickness: 2),
              _buildCalcRow(
                'Settlement Difference',
                '${_settlementDifference >= 0 ? '+' : '-'}$_currency ${absAmount.toStringAsFixed(0)}',
                isBold: true,
                valueColor: isExactMatch
                    ? const Color(0xFF10B981)
                    : memberOwes
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF3B82F6),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Status indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isExactMatch
                ? const Color(0xFFD1FAE5)
                : memberOwes
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                isExactMatch
                    ? Icons.check_circle_rounded
                    : memberOwes
                    ? Icons.warning_rounded
                    : Icons.info_rounded,
                color: isExactMatch
                    ? const Color(0xFF10B981)
                    : memberOwes
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF3B82F6),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isExactMatch
                      ? 'No settlement needed! Gold cost matches amount paid.'
                      : memberOwes
                      ? 'Member owes $_currency ${absAmount.toStringAsFixed(0)} more for the gold.'
                      : 'Organizer owes $_currency ${absAmount.toStringAsFixed(0)} refund to member.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _error!,
              style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _step = 0;
                  _error = null;
                }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _onConfirmHandover,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isExactMatch
                            ? 'Confirm & Complete'
                            : 'Confirm Handover',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onConfirmHandover() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final service = GoldHandoverService();
      _handover = await service.initiateGoldHandover(
        chittiId: widget.chittiId,
        slotId: widget.slotId,
        userId: widget.slot.userId,
        userName: widget.slot.userName ?? 'Member',
        goldType: _goldType,
        goldPurity: _goldPurity,
        goldWeight: _goldWeight,
        lockedTotalValue: _lockedTotalValue,
        currentTotalGoldCost: _currentTotalGoldCost,
        totalPaidByMember: _totalPaid,
        slotNumber: widget.slot.slotNumber,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (_settlementDifference == 0) {
        // Exact match - done!
        if (mounted) Navigator.pop(context, true);
        return;
      }

      // Need settlement
      setState(() {
        _step = 2;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to process handover: $e';
        _isProcessing = false;
      });
    }
  }

  // ============ Step 2: Settlement Options ============

  Widget _buildSettlementOptionsStep() {
    final memberOwes = _settlementDifference > 0;
    final absAmount = _settlementDifference.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        // Amount summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: memberOwes
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                memberOwes
                    ? Icons.account_balance_wallet_rounded
                    : Icons.payment_rounded,
                color: memberOwes
                    ? const Color(0xFFD97706)
                    : const Color(0xFF3B82F6),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberOwes ? 'Member Owes' : 'Refund Due',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '$_currency ${absAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Choose Settlement Option',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),

        if (memberOwes) ...[
          // Option 1: One-time payment
          _buildOptionCard(
            icon: Icons.price_check_rounded,
            title: 'Settle Up (One-Time)',
            subtitle:
                'Member pays $_currency ${absAmount.toStringAsFixed(0)} now',
            color: const Color(0xFF10B981),
            onTap: () => _processOneTimePayment(absAmount),
          ),
          const SizedBox(height: 10),

          // Option 2: Revamp EMI
          _buildRevampEMIOption(absAmount),
          const SizedBox(height: 10),

          // Option 3: Manual transaction
          _buildOptionCard(
            icon: Icons.edit_note_rounded,
            title: 'Manual Transaction',
            subtitle: 'Record receive/give amount manually',
            color: const Color(0xFF8B5CF6),
            onTap: () => _showManualTransactionInput(isReceive: true),
          ),
        ] else ...[
          // Refund options
          _buildOptionCard(
            icon: Icons.currency_exchange_rounded,
            title: 'Refund Full Amount',
            subtitle:
                'Pay $_currency ${absAmount.toStringAsFixed(0)} to member',
            color: const Color(0xFF3B82F6),
            onTap: () => _processRefund(absAmount),
          ),
          const SizedBox(height: 10),

          _buildOptionCard(
            icon: Icons.edit_note_rounded,
            title: 'Manual Transaction',
            subtitle: 'Record payment manually',
            color: const Color(0xFF8B5CF6),
            onTap: () => _showManualTransactionInput(isReceive: false),
          ),
        ],

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _error!,
              style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Later option
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Settle Later',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevampEMIOption(double amount) {
    final emiAmount = amount / _revampInstallments;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revamp as EMI',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '$_currency ${emiAmount.toStringAsFixed(0)} × $_revampInstallments months',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Installment slider
          Row(
            children: [
              Text(
                '1',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _revampInstallments.toDouble(),
                  min: 1,
                  max: _maxInstallments.toDouble(),
                  divisions: _maxInstallments > 1 ? _maxInstallments - 1 : 1,
                  activeColor: const Color(0xFFF59E0B),
                  onChanged: (value) {
                    setState(() {
                      _revampInstallments = value.round();
                    });
                  },
                ),
              ),
              Text(
                '$_maxInstallments',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          // Confirm revamp button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processRevampEMI(amount),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Revamp in $_revampInstallments installments',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // ============ Settlement Actions ============

  Future<void> _processOneTimePayment(double amount) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final service = GoldHandoverService();
      await service.settleUpOneTime(
        chittiId: widget.chittiId,
        slotId: widget.slotId,
        handoverId: _handover!.id,
        amount: amount,
        userId: widget.slot.userId,
        userName: widget.slot.userName,
        slotNumber: widget.slot.slotNumber,
      );

      if (mounted) {
        _showSuccessAndClose('Settlement completed successfully!');
      }
    } catch (e) {
      setState(() {
        _error = 'Settlement failed: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _processRevampEMI(double amount) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final service = GoldHandoverService();
      await service.revampAsEMI(
        chittiId: widget.chittiId,
        slotId: widget.slotId,
        handoverId: _handover!.id,
        remainingAmount: amount,
        installmentCount: _revampInstallments,
        userId: widget.slot.userId,
        userName: widget.slot.userName,
        slotNumber: widget.slot.slotNumber,
      );

      if (mounted) {
        _showSuccessAndClose(
          'EMI revamp set: $_currency ${(amount / _revampInstallments).toStringAsFixed(0)} × $_revampInstallments months',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Revamp failed: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _processRefund(double amount) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final service = GoldHandoverService();
      await service.processRefund(
        chittiId: widget.chittiId,
        slotId: widget.slotId,
        handoverId: _handover!.id,
        amount: amount,
        userId: widget.slot.userId,
        userName: widget.slot.userName,
        slotNumber: widget.slot.slotNumber,
      );

      if (mounted) {
        _showSuccessAndClose(
          'Refund of $_currency ${amount.toStringAsFixed(0)} processed!',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Refund failed: $e';
        _isProcessing = false;
      });
    }
  }

  void _showManualTransactionInput({required bool isReceive}) {
    _manualAmountController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isReceive ? 'Receive Amount' : 'Give Amount',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _manualAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '$_currency ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_manualAmountController.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              _processManualTransaction(amount, isReceive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: Text(
              isReceive ? 'Record Received' : 'Record Given',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processManualTransaction(double amount, bool isReceive) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final service = GoldHandoverService();
      await service.recordManualSettlement(
        chittiId: widget.chittiId,
        slotId: widget.slotId,
        handoverId: _handover!.id,
        amount: amount,
        isReceive: isReceive,
        userId: widget.slot.userId,
        userName: widget.slot.userName,
        slotNumber: widget.slot.slotNumber,
        notes: isReceive
            ? 'Received $_currency ${amount.toStringAsFixed(0)}'
            : 'Paid $_currency ${amount.toStringAsFixed(0)} to member',
      );

      if (mounted) {
        _showSuccessAndClose(
          isReceive
              ? 'Received $_currency ${amount.toStringAsFixed(0)} recorded'
              : 'Payment of $_currency ${amount.toStringAsFixed(0)} recorded',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Transaction failed: $e';
        _isProcessing = false;
      });
    }
  }

  void _showSuccessAndClose(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context, true);
  }

  // ============ Shared Widgets ============

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildCalcRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isBold ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
