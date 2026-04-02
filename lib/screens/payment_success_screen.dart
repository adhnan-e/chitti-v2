import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/models/models.dart';
import '../utils/currency_utils.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Transaction transaction;
  final String chittiName;
  final String memberName;
  final String installmentInfo; // e.g. "3 / 12"
  final Color primaryColor;
  final VoidCallback onRecordAnother;
  final String? winnerMonth;
  final int? discountInCents;
  final int? originalAmountInCents;

  // Gold handover details
  final String? goldType;
  final String? goldPurity;
  final double? goldWeight;
  final double? lockedPrice;
  final double? marketRate;
  final double? settlementAmount;

  const PaymentSuccessScreen({
    super.key,
    required this.transaction,
    required this.chittiName,
    required this.memberName,
    required this.installmentInfo,
    required this.primaryColor,
    required this.onRecordAnother,
    this.winnerMonth,
    this.discountInCents,
    this.originalAmountInCents,
    this.goldType,
    this.goldPurity,
    this.goldWeight,
    this.lockedPrice,
    this.marketRate,
    this.settlementAmount,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isGoldTransaction =>
      widget.transaction.type == TransactionType.goldHandover ||
      widget.transaction.type == TransactionType.settlementPayment ||
      widget.transaction.type == TransactionType.settlementRefund;

  String get _successTitle {
    switch (widget.transaction.type) {
      case TransactionType.goldHandover:
        return 'Gold Handover Recorded!';
      case TransactionType.settlementPayment:
        return 'Settlement Payment!';
      case TransactionType.settlementRefund:
        return 'Settlement Refund!';
      default:
        return 'Payment Received!';
    }
  }

  String get _successSubtitle {
    switch (widget.transaction.type) {
      case TransactionType.goldHandover:
        return 'Gold handover has been recorded successfully.';
      case TransactionType.settlementPayment:
        return 'Settlement payment has been recorded.';
      case TransactionType.settlementRefund:
        return 'Refund has been processed successfully.';
      default:
        return 'Transaction has been recorded successfully.';
    }
  }

  void _shareReceipt() {
    final dateStr = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(widget.transaction.createdAt);
    final amountStr = CurrencyUtils.formatCents(
      widget.transaction.amountInCents,
    );

    String discountText = "";
    if (widget.discountInCents != null && widget.discountInCents! > 0) {
      final originalStr = CurrencyUtils.formatCents(
        widget.originalAmountInCents ??
            (widget.transaction.amountInCents + widget.discountInCents!),
      );
      final discountStr = CurrencyUtils.formatCents(widget.discountInCents!);
      discountText = "\n*Original:* $originalStr\n*Discount:* - $discountStr";
    }

    final text =
        '''
🧾 *Payment Receipt*
--------------------------
*Chitti:* ${widget.chittiName}
*Member:* ${widget.memberName}
*Amount Paid:* $amountStr$discountText
*Month:* ${widget.transaction.monthKey}${widget.winnerMonth != null ? " (Winning Month: ${widget.winnerMonth})" : ""}
*Installment:* ${widget.installmentInfo}
*Method:* ${widget.transaction.paymentMethod.displayLabel}
*Date/Time:* $dateStr
*Receipt #:* ${widget.transaction.receiptNumber ?? 'N/A'}
--------------------------
Thank you for your payment!
''';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Success Icon Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isGoldTransaction
                        ? Colors.amber.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isGoldTransaction
                        ? Icons.diamond_rounded
                        : Icons.check_circle_rounded,
                    color: _isGoldTransaction ? Colors.amber : Colors.green,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      _successTitle,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _successSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: textColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Receipt Card
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildReceiptRow(
                                'Member',
                                widget.memberName,
                                textColorSecondary,
                                textColorPrimary,
                              ),
                              _buildReceiptRow(
                                'Chitti',
                                widget.chittiName,
                                textColorSecondary,
                                textColorPrimary,
                              ),
                              const Divider(height: 32),
                              if (widget.discountInCents != null &&
                                  widget.discountInCents! > 0) ...[
                                _buildReceiptRow(
                                  'Original Amount',
                                  CurrencyUtils.formatCents(
                                    widget.originalAmountInCents ??
                                        (widget.transaction.amountInCents +
                                            widget.discountInCents!),
                                  ),
                                  textColorSecondary,
                                  textColorPrimary,
                                  isSmall: true,
                                ),
                                _buildReceiptRow(
                                  'Winner Discount',
                                  '- ${CurrencyUtils.formatCents(widget.discountInCents!)}',
                                  textColorSecondary,
                                  Colors.orange,
                                  isSmall: true,
                                  isBold: true,
                                ),
                                const SizedBox(height: 8),
                              ],
                              _buildReceiptRow(
                                _isGoldTransaction ? 'Amount' : 'Net Paid',
                                CurrencyUtils.formatCents(
                                  widget.transaction.amountInCents,
                                ),
                                textColorSecondary,
                                _isGoldTransaction
                                    ? Colors.amber
                                    : widget.primaryColor,
                                isBold: true,
                                isLarge: true,
                              ),
                              const Divider(height: 32),
                              if (_isGoldTransaction) ...[
                                _buildReceiptRow(
                                  'Type',
                                  widget.transaction.type.displayLabel,
                                  textColorSecondary,
                                  textColorPrimary,
                                ),
                                if (widget.goldType != null)
                                  _buildReceiptRow(
                                    'Gold Type',
                                    widget.goldType!,
                                    textColorSecondary,
                                    Colors.amber.shade700,
                                    isBold: true,
                                  ),
                                if (widget.goldPurity != null)
                                  _buildReceiptRow(
                                    'Purity',
                                    widget.goldPurity!,
                                    textColorSecondary,
                                    textColorPrimary,
                                  ),
                                if (widget.goldWeight != null)
                                  _buildReceiptRow(
                                    'Weight',
                                    '${widget.goldWeight!.toStringAsFixed(2)} g',
                                    textColorSecondary,
                                    textColorPrimary,
                                  ),
                                if (widget.lockedPrice != null)
                                  _buildReceiptRow(
                                    'Locked Price',
                                    CurrencyUtils.format(widget.lockedPrice!),
                                    textColorSecondary,
                                    textColorPrimary,
                                    isSmall: true,
                                  ),
                                if (widget.marketRate != null)
                                  _buildReceiptRow(
                                    'Market Rate',
                                    CurrencyUtils.format(widget.marketRate!),
                                    textColorSecondary,
                                    textColorPrimary,
                                    isSmall: true,
                                  ),
                                if (widget.settlementAmount != null &&
                                    widget.settlementAmount != 0)
                                  _buildReceiptRow(
                                    widget.settlementAmount! > 0
                                        ? 'Settlement Due'
                                        : 'Refund Due',
                                    CurrencyUtils.format(
                                      widget.settlementAmount!.abs(),
                                    ),
                                    textColorSecondary,
                                    widget.settlementAmount! > 0
                                        ? Colors.orange
                                        : const Color(0xFF10B981),
                                    isBold: true,
                                  ),
                              ] else ...[
                                _buildReceiptRow(
                                  'Month',
                                  widget.transaction.monthKey,
                                  textColorSecondary,
                                  textColorPrimary,
                                ),
                                if (widget.winnerMonth != null)
                                  _buildReceiptRow(
                                    'Winner Month',
                                    widget.winnerMonth!,
                                    textColorSecondary,
                                    Colors.amber,
                                    isSmall: true,
                                    isBold: true,
                                  ),
                                _buildReceiptRow(
                                  'Installment',
                                  widget.installmentInfo,
                                  textColorSecondary,
                                  textColorPrimary,
                                ),
                              ],
                              _buildReceiptRow(
                                'Method',
                                widget.transaction.paymentMethod.displayLabel,
                                textColorSecondary,
                                textColorPrimary,
                              ),
                              _buildReceiptRow(
                                'Date & Time',
                                DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(widget.transaction.createdAt),
                                textColorSecondary,
                                textColorPrimary,
                                isSmall: true,
                              ),
                            ],
                          ),
                        ),
                        // Tear-off effect
                        const _DashedLineSeparator(),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildReceiptRow(
                            'Receipt #',
                            widget.transaction.receiptNumber ?? 'N/A',
                            textColorSecondary,
                            textColorPrimary,
                            isSmall: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Actions
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareReceipt,
                        icon: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Share Receipt',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onRecordAnother();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: widget.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Add Another',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: widget.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Done',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColorSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool isBold = false,
    bool isLarge = false,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 12 : 14,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isLarge ? 20 : (isSmall ? 12 : 14),
              fontWeight: (isBold || isLarge)
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLineSeparator extends StatelessWidget {
  const _DashedLineSeparator();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
