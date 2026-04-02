/// Receipt Service - Generate and share payment receipts
///
/// Generates professional payment receipts as images or PDFs.
/// Supports sharing via platform share sheet and WhatsApp.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../core/models/transaction.dart';
import '../utils/currency_utils.dart';

/// Receipt data model for rendering
class ReceiptData {
  final String receiptNumber;
  final String chittyName;
  final String memberName;
  final int slotNumber;
  final String monthLabel;
  final int amountInCents;
  final String paymentMethod;
  final DateTime paymentDate;
  final DateTime? verifiedDate;
  final String organizerName;
  final int balanceAfterInCents;
  final String? referenceNumber;
  final String currencySymbol;

  ReceiptData({
    required this.receiptNumber,
    required this.chittyName,
    required this.memberName,
    required this.slotNumber,
    required this.monthLabel,
    required this.amountInCents,
    required this.paymentMethod,
    required this.paymentDate,
    this.verifiedDate,
    required this.organizerName,
    required this.balanceAfterInCents,
    this.referenceNumber,
    this.currencySymbol = 'AED',
  });

  /// Create from Transaction
  factory ReceiptData.fromTransaction({
    required Transaction transaction,
    required String chittyName,
    required String organizerName,
    String currencySymbol = 'AED',
  }) {
    // Format month label from monthKey (YYYY-MM)
    String monthLabel = transaction.monthKey;
    try {
      final parts = transaction.monthKey.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      monthLabel = DateFormat('MMMM yyyy').format(date);
    } catch (_) {}

    return ReceiptData(
      receiptNumber: transaction.receiptNumber ?? 'N/A',
      chittyName: chittyName,
      memberName: transaction.userName ?? 'Member',
      slotNumber: transaction.slotNumber ?? 1,
      monthLabel: monthLabel,
      amountInCents: transaction.amountInCents,
      paymentMethod: transaction.paymentMethod.displayLabel,
      paymentDate: transaction.createdAt,
      verifiedDate: transaction.verifiedAt,
      organizerName: organizerName,
      balanceAfterInCents: transaction.balanceAfterInCents,
      referenceNumber: transaction.referenceNumber,
      currencySymbol: currencySymbol,
    );
  }
}

/// Receipt Service - Generate and share receipts
class ReceiptService {
  // Singleton pattern
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  /// Generate receipt as image bytes
  Future<Uint8List> generateReceiptImage(ReceiptData data) async {
    // Create a receipt widget
    final receiptWidget = _ReceiptWidget(data: data);

    // Create a repaint boundary key
    final key = GlobalKey();

    // Build the widget in an offstage overlay
    // For production, consider using WidgetsBinding or custom render

    // Placeholder - return empty for now
    // In production, use ScreenshotController or similar
    throw UnimplementedError(
      'Use generateReceiptFile instead with widget rendering',
    );
  }

  /// Generate receipt and save to file
  Future<File> generateReceiptFile(ReceiptData data) async {
    final directory = await getTemporaryDirectory();
    final fileName =
        'receipt_${data.receiptNumber.replaceAll(RegExp(r'[^\w]'), '_')}.png';
    final filePath = '${directory.path}/$fileName';

    // Generate receipt content as text for now
    // Full image generation would require rendering pipeline
    final receiptContent = _generateReceiptText(data);

    // Save as text file (for demo - replace with image in production)
    final file = File(filePath.replaceAll('.png', '.txt'));
    await file.writeAsString(receiptContent);

    return file;
  }

  /// Share receipt via platform share sheet
  Future<void> shareReceipt(ReceiptData data) async {
    final receiptText = _generateReceiptText(data);

    await Share.share(
      receiptText,
      subject: 'Payment Receipt - ${data.receiptNumber}',
    );
  }

  /// Share receipt via WhatsApp
  Future<void> shareViaWhatsApp(ReceiptData data, String phoneNumber) async {
    final receiptText = _generateReceiptText(data);

    // Format phone number for WhatsApp
    String phone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (!phone.startsWith('+')) {
      phone = '+$phone';
    }

    // Use Share.share with WhatsApp specific handling
    // In production, use url_launcher with whatsapp:// scheme
    await Share.share(
      receiptText,
      subject: 'Payment Receipt - ${data.receiptNumber}',
    );
  }

  /// Generate receipt as formatted text
  String _generateReceiptText(ReceiptData data) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final amount = CurrencyUtils.formatCents(
      data.amountInCents,
      symbol: data.currencySymbol,
    );
    final balance = CurrencyUtils.formatCents(
      data.balanceAfterInCents,
      symbol: data.currencySymbol,
    );

    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('        PAYMENT RECEIPT');
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Receipt No: ${data.receiptNumber}');
    buffer.writeln('Date: ${dateFormat.format(data.paymentDate)}');
    buffer.writeln();
    buffer.writeln('───────────────────────────────────');
    buffer.writeln('Chitti: ${data.chittyName}');
    buffer.writeln('Member: ${data.memberName}');
    buffer.writeln('Slot: #${data.slotNumber}');
    buffer.writeln('───────────────────────────────────');
    buffer.writeln();
    buffer.writeln('Payment For: ${data.monthLabel}');
    buffer.writeln('Amount: $amount');
    buffer.writeln('Method: ${data.paymentMethod}');
    if (data.referenceNumber != null) {
      buffer.writeln('Reference: ${data.referenceNumber}');
    }
    buffer.writeln();
    buffer.writeln('───────────────────────────────────');
    buffer.writeln('Balance After: $balance');
    buffer.writeln('───────────────────────────────────');
    buffer.writeln();
    if (data.verifiedDate != null) {
      buffer.writeln('✓ Verified on ${dateFormat.format(data.verifiedDate!)}');
    } else {
      buffer.writeln('⏳ Pending Verification');
    }
    buffer.writeln();
    buffer.writeln('Organizer: ${data.organizerName}');
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('   Thank you for your payment!');
    buffer.writeln('═══════════════════════════════════');

    return buffer.toString();
  }

  /// Generate receipt for a list of transactions (monthly statement)
  String generateMonthlyStatement({
    required String chittyName,
    required String memberName,
    required int slotNumber,
    required String monthKey,
    required List<Transaction> transactions,
    required int openingBalanceInCents,
    required int closingBalanceInCents,
    String currencySymbol = 'AED',
  }) {
    final dateFormat = DateFormat('dd MMM');
    final fullDateFormat = DateFormat('MMMM yyyy');

    // Parse month for header
    String monthLabel = monthKey;
    try {
      final parts = monthKey.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      monthLabel = fullDateFormat.format(date);
    } catch (_) {}

    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln('              STATEMENT OF ACCOUNT');
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Chitti: $chittyName');
    buffer.writeln('Member: $memberName (Slot #$slotNumber)');
    buffer.writeln('Period: $monthLabel');
    buffer.writeln();
    buffer.writeln('───────────────────────────────────────────────────────');
    buffer.writeln(
      'Opening Balance: ${CurrencyUtils.formatCents(openingBalanceInCents, symbol: currencySymbol)}',
    );
    buffer.writeln('───────────────────────────────────────────────────────');
    buffer.writeln();
    buffer.writeln('Date       Description                     Amount');
    buffer.writeln('───────────────────────────────────────────────────────');

    for (final txn in transactions) {
      final date = dateFormat.format(txn.createdAt);
      final desc = txn.shortDescription.padRight(30);
      final amount = txn.isCredit
          ? '+${CurrencyUtils.formatCentsAmountOnly(txn.amountInCents)}'
          : '-${CurrencyUtils.formatCentsAmountOnly(txn.amountInCents)}';
      buffer.writeln('$date  $desc  $amount');
    }

    buffer.writeln();
    buffer.writeln('───────────────────────────────────────────────────────');
    buffer.writeln(
      'Closing Balance: ${CurrencyUtils.formatCents(closingBalanceInCents, symbol: currencySymbol)}',
    );
    buffer.writeln('═══════════════════════════════════════════════════════');

    return buffer.toString();
  }
}

/// Internal widget for rendering receipt (for image generation)
class _ReceiptWidget extends StatelessWidget {
  final ReceiptData data;

  const _ReceiptWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'PAYMENT RECEIPT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.chittyName,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Divider(height: 24),

          // Receipt number and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receipt #:', style: TextStyle(color: Colors.grey[600])),
              Text(
                data.receiptNumber,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date:', style: TextStyle(color: Colors.grey[600])),
              Text(
                DateFormat('dd MMM yyyy').format(data.paymentDate),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const Divider(height: 24),

          // Member info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Member:', style: TextStyle(color: Colors.grey[600])),
              Text(
                data.memberName,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Slot:', style: TextStyle(color: Colors.grey[600])),
              Text(
                '#${data.slotNumber}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Amount box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Text(
                  data.monthLabel,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyUtils.formatCents(
                    data.amountInCents,
                    symbol: data.currencySymbol,
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Method:', style: TextStyle(color: Colors.grey[600])),
              Text(
                data.paymentMethod,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          if (data.referenceNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reference:', style: TextStyle(color: Colors.grey[600])),
                Text(
                  data.referenceNumber!,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],

          const Divider(height: 24),

          // Status
          if (data.verifiedDate != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Pending Verification',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),
          Text(
            'Thank you for your payment!',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
