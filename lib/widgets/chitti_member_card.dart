import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChittiMemberCard extends StatelessWidget {
  final int slotNumber;
  final String fullName;
  final String phone;
  final String joinedDate;
  final String status; // 'Active', 'Inactive'
  final double goldWeight;
  final double monthlyAmount;
  final double totalAmount;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChittiMemberCard({
    super.key,
    required this.slotNumber,
    required this.fullName,
    required this.phone,
    required this.joinedDate,
    required this.status,
    required this.goldWeight,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.currencySymbol,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = status.toLowerCase() == 'active';
    final statusColor = isActive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced bottom margin
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced padding 16 -> 12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Slot + Name + Status
                Row(
                  children: [
                    // Slot Number
                    Container(
                      width: 32, // Reduced size 40 -> 32
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4, // Reduced blur
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '#$slotNumber',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13, // Reduced font 16 -> 13
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Reduced spacing
                    // Name & Phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Reduced font 16 -> 14
                              color: colorScheme.onSurface,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (phone.isNotEmpty)
                            Text(
                              phone,
                              style: GoogleFonts.inter(
                                fontSize: 11, // Reduced font 12 -> 11
                                color: colorScheme.onSurface.withOpacity(0.6),
                                height: 1.2,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, // Reduced horizontal
                        vertical: 2, // Reduced vertical
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Smaller radius
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5, // Reduced size 6 -> 5
                            height: 5,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: GoogleFonts.inter(
                              fontSize: 10, // Reduced font 11 -> 10
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Details Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                  children: [
                    // Gold Option
                    Flexible(
                      fit: FlexFit.tight,
                      child: _buildDetailItem(
                        context,
                        icon: Icons.diamond_outlined,
                        iconColor: Colors.amber,
                        label: 'Gold Scheme',
                        value: '${goldWeight}g',
                        compact: true,
                      ),
                    ),
                    _buildDivider(colorScheme),
                    // Monthly Amount
                    Flexible(
                      fit: FlexFit.tight,
                      child: _buildDetailItem(
                        context,
                        icon: Icons.calendar_month_outlined,
                        iconColor: Colors.blue,
                        label: 'Monthly Due',
                        value:
                            '$currencySymbol${monthlyAmount.toStringAsFixed(0)}',
                        compact: true,
                      ),
                    ),
                    _buildDivider(colorScheme),
                    // Total Amount
                    Flexible(
                      fit: FlexFit.tight,
                      child: _buildDetailItem(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: Colors.purple,
                        label: 'Total Paid',
                        value:
                            '$currencySymbol${totalAmount.toStringAsFixed(0)}',
                        compact: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10), // Reduced footer spacing
                // Footer: Joined Date
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 10, // Reduced icon size
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Joined $joinedDate', // Shortened text
                        style: GoogleFonts.inter(
                          fontSize: 10, // Reduced font 11 -> 10
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool compact = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min, // Wrap content
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor), // Reduced icon
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12, // Keep value readable but small
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9, // Smaller label
            color: colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 24, // Reduced height
      color: colorScheme.outline.withOpacity(0.15),
    );
  }
}
