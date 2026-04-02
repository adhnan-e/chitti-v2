import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../utils/currency_utils.dart';

class WinnerSelectionScreen extends StatefulWidget {
  final String chittiId;
  final String chittiName;
  final int duration;
  final String startMonth;
  final Color primaryColor;

  const WinnerSelectionScreen({
    super.key,
    required this.chittiId,
    required this.chittiName,
    required this.duration,
    required this.startMonth,
    required this.primaryColor,
  });

  @override
  State<WinnerSelectionScreen> createState() => _WinnerSelectionScreenState();
}

class _WinnerSelectionScreenState extends State<WinnerSelectionScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _members = [];
  Map<String, Map<String, dynamic>> _winners = {}; // keyed by monthKey
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final members = await _db.getChittiMembersDetails(widget.chittiId);
      final winnersList = await _db.getChittiWinners(widget.chittiId);

      final winnersMap = <String, Map<String, dynamic>>{};
      for (var w in winnersList) {
        if (w['monthKey'] != null) {
          winnersMap[w['monthKey']] = w;
        } else if (w['month'] != null) {
          // Fallback for legacy data that might use label as key
          // We'll try to reconstruct the key if possible
          final date = CurrencyUtils.parseMonth(w['month']);
          if (date != null) {
            final key = DateFormat('yyyy-MM').format(date);
            winnersMap[key] = w;
          }
        }
      }

      setState(() {
        _members = members;
        _winners = winnersMap;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColorPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textColorSecondary = isDark
        ? Colors.grey[400]!
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Winner Timeline',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTimeline(textColorPrimary, textColorSecondary),
    );
  }

  Widget _buildTimeline(Color textColorPrimary, Color textColorSecondary) {
    final startDate = CurrencyUtils.parseMonth(widget.startMonth);
    if (startDate == null) {
      return const Center(child: Text('Invalid start month'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: widget.duration,
      itemBuilder: (context, index) {
        final monthDate = DateTime(startDate.year, startDate.month + index, 1);
        final monthKey = DateFormat('yyyy-MM').format(monthDate);
        final monthLabel = DateFormat('MMMM yyyy').format(monthDate);
        final winner = _winners[monthKey];
        final isLast = index == widget.duration - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: winner != null
                        ? Colors.amber
                        : widget.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: winner != null
                          ? Colors.amber
                          : widget.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: winner != null
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 100, // Adjust height based on content
                    color: widget.primaryColor.withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            // Month Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthLabel,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColorPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  winner != null
                      ? _buildWinnerCard(
                          winner,
                          textColorPrimary,
                          textColorSecondary,
                        )
                      : _buildSelectWinnerButton(monthKey, monthLabel),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWinnerCard(
    Map<String, dynamic> winner,
    Color textColorPrimary,
    Color textColorSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  winner['userName'] ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColorPrimary,
                  ),
                ),
                Text(
                  'Slot #${winner['slotNumber']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textColorSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'WINNER',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectWinnerButton(String monthKey, String monthLabel) {
    return InkWell(
      onTap: () => _showPicker(monthKey, monthLabel),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.primaryColor.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
          color: widget.primaryColor.withOpacity(0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: widget.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Assign Winner',
              style: GoogleFonts.inter(
                color: widget.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(String monthKey, String monthLabel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WinnerPickerSheet(
        members: _members,
        existingWinners: _winners,
        primaryColor: widget.primaryColor,
        onSelected: (member) {
          _confirmWinner(monthKey, monthLabel, member);
        },
      ),
    );
  }

  Future<void> _confirmWinner(
    String monthKey,
    String monthLabel,
    Map<String, dynamic> member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Winner'),
        content: Text(
          'Assign ${member['name']} (Slot #${member['slotNumber']}) as the winner for $monthLabel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _db.addWinner(
          chittiId: widget.chittiId,
          chittiName: widget.chittiName,
          monthKey: monthKey,
          monthLabel: monthLabel,
          userId: member['userId'],
          userName: member['name'],
          slotId: member['slotId'],
          slotNumber: member['slotNumber'],
          prize: 'Gold', // Default for now
        );
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign winner: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _WinnerPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final Map<String, Map<String, dynamic>> existingWinners;
  final Color primaryColor;
  final Function(Map<String, dynamic>) onSelected;

  const _WinnerPickerSheet({
    required this.members,
    required this.existingWinners,
    required this.primaryColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final wonSlotIds = existingWinners.values.map((w) => w['slotId']).toSet();
    final availableMembers = members
        .where((m) => !wonSlotIds.contains(m['slotId']))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final textColorPrimary = isDark ? Colors.white : const Color(0xFF1F2937);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Select a Winner',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColorPrimary,
              ),
            ),
          ),
          Expanded(
            child: availableMembers.isEmpty
                ? const Center(child: Text('No more members available to win'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: availableMembers.length,
                    itemBuilder: (context, index) {
                      final member = availableMembers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            member['slotNumber'].toString(),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member['name'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Slot #${member['slotNumber']}'),
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(member);
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
