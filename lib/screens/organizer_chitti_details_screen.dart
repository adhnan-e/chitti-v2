import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:chitt/services/database_service.dart';
import 'package:chitt/core/domain/enums.dart';
import 'package:chitt/screens/lucky_draw_results_screen.dart';

class OrganizerChittiDetailsScreen extends StatefulWidget {
  const OrganizerChittiDetailsScreen({super.key});

  @override
  State<OrganizerChittiDetailsScreen> createState() =>
      _OrganizerChittiDetailsScreenState();
}

class _OrganizerChittiDetailsScreenState
    extends State<OrganizerChittiDetailsScreen> {
  Map<String, dynamic>? _chitti;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _chitti = args;
    }
  }

  Future<void> _startChitti(String chittiId) async {
    try {
      await DatabaseService().startChitti(chittiId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chitti Started Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    if (_chitti == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: DatabaseService().getChittiStream(_chitti!['id'] as String),
      initialData: _chitti,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Chitti not found')),
          );
        }

        final membersMap = data['members'] as Map? ?? {};
        final membersCount = membersMap.keys.length;
        final maxSlots = data['maxSlots'] ?? 70;
        final slotProgress = maxSlots > 0 ? membersCount / maxSlots : 0.0;
        final currency = DatabaseService().getCurrencySymbol();
        final isActive = data['status'] == 'active';

        return Scaffold(
          backgroundColor: backgroundColor,
          body: CustomScrollView(
            slivers: [
              // Hero App Bar
              _buildHeroAppBar(context, data, slotProgress),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Metrics Cards
                      _buildKeyMetrics(context, data, currency),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(context, data, isActive),
                      const SizedBox(height: 24),

                      // Member Distribution
                      _buildMemberDistribution(
                        context,
                        data,
                        membersCount,
                        maxSlots,
                      ),
                      const SizedBox(height: 24),

                      // Gold Options Summary
                      if (data['goldOptions'] != null &&
                          (data['goldOptions'] as List).isNotEmpty)
                        _buildGoldOptionsSummary(context, data, currency),
                      const SizedBox(height: 24),

                      // Important Dates
                      _buildImportantDates(context, data),
                      const SizedBox(height: 24),

                      // Members List
                      _buildMembersList(context, data, membersMap),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(
              context,
              '/add_member_to_chitti',
              arguments: data['id'],
            ),
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add),
            label: Text(
              'Add Member',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // ==================== HERO APP BAR ====================
  Widget _buildHeroAppBar(
    BuildContext context,
    Map<String, dynamic> data,
    double progress,
  ) {
    const primaryColor = Color(0xFF0D9488); // Teal 600
    const accentColor = Color(0xFF10B981); // Emerald 500

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () =>
              Navigator.pushNamed(context, '/edit_chitti', arguments: data),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed =
              top <= (MediaQuery.of(context).padding.top + kToolbarHeight + 20);

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsetsDirectional.only(
              start: 56,
              bottom: 16,
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text(
                data['name'] ?? 'Chitti',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isCollapsed ? 0.0 : 1.0,
                                  child: Text(
                                    data['name'] ?? 'Chitti',
                                    style: GoogleFonts.inter(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.2,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    _buildStatusBadge(
                                      data['status'] ?? 'pending',
                                    ),
                                    _buildInfoChip(
                                      Icons.calendar_month,
                                      data['startMonth'] ?? 'N/A',
                                    ),
                                    _buildInfoChip(
                                      Icons.timer_outlined,
                                      '${data['duration'] ?? 20} Months',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildGlassProgress(progress),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassProgress(double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: Colors.white,
                  strokeWidth: 5,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Capacity',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'active';
    final bgColor = isActive
        ? const Color(0xFF0D9488).withOpacity(0.1)
        : Colors.orange.shade50;
    final textColor = isActive
        ? const Color(0xFF0D9488)
        : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== KEY METRICS ====================
  Widget _buildKeyMetrics(
    BuildContext context,
    Map<String, dynamic> data,
    String currency,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseService().getChittiFinancials(data['id']),
      builder: (context, snapshot) {
        final financials = snapshot.data ?? {};
        final expected = (financials['totalExpected'] ?? 0).toDouble();
        final collected = (financials['totalCollected'] ?? 0).toDouble();
        final rate = expected > 0 ? (collected / expected * 100) : 0.0;
        final outstanding = (expected - collected).clamp(0.0, double.infinity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Overview', style: _sectionTitleStyle(context)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.account_balance_wallet,
                    label: 'Total Collection',
                    value: '$currency${collected.toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.trending_up,
                    label: 'Target (to date)',
                    value: '$currency${expected.toStringAsFixed(0)}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.pie_chart,
                    label: 'Collection Rate',
                    value: '${rate.toStringAsFixed(1)}%',
                    color: rate >= 80
                        ? Colors.green
                        : (rate >= 50 ? Colors.orange : Colors.red),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.warning_amber,
                    label: 'Outstanding',
                    value: '$currency${outstanding.toStringAsFixed(0)}',
                    color: outstanding > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Icon(Icons.trending_up, size: 14, color: color.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColorPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== COLLECTION CHART ====================
  // Widget _buildCollectionChart(
  //   BuildContext context,
  //   Map<String, dynamic> data,
  //   String currency,
  // ) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   final duration = data['duration'] ?? 12;

  //   // Generate mock data for chart (in real app, fetch from database)
  //   final List<FlSpot> expectedSpots = [];
  //   final List<FlSpot> collectedSpots = [];

  //   for (int i = 0; i < duration && i < 12; i++) {
  //     expectedSpots.add(FlSpot(i.toDouble(), (i + 1) * 10000));
  //     collectedSpots.add(FlSpot(i.toDouble(), (i + 1) * 8500 + (i * 500)));
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Collection Trends', style: _sectionTitleStyle(context)),
  //       const SizedBox(height: 12),
  //       Container(
  //         height: 200,
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: colorScheme.surface,
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
  //         ),
  //         child: LineChart(
  //           LineChartData(
  //             gridData: FlGridData(
  //               show: true,
  //               drawVerticalLine: false,
  //               horizontalInterval: 25000,
  //               getDrawingHorizontalLine: (value) => FlLine(
  //                 color: colorScheme.outline.withOpacity(0.2),
  //                 strokeWidth: 1,
  //               ),
  //             ),
  //             titlesData: FlTitlesData(
  //               leftTitles: AxisTitles(
  //                 sideTitles: SideTitles(
  //                   showTitles: true,
  //                   reservedSize: 45,
  //                   getTitlesWidget: (value, meta) => Text(
  //                     '${(value / 1000).toInt()}K',
  //                     style: GoogleFonts.inter(
  //                       fontSize: 10,
  //                       color: colorScheme.onSurface.withOpacity(0.5),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               bottomTitles: AxisTitles(
  //                 sideTitles: SideTitles(
  //                   showTitles: true,
  //                   getTitlesWidget: (value, meta) => Text(
  //                     'M${value.toInt() + 1}',
  //                     style: GoogleFonts.inter(
  //                       fontSize: 10,
  //                       color: colorScheme.onSurface.withOpacity(0.5),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               topTitles: const AxisTitles(
  //                 sideTitles: SideTitles(showTitles: false),
  //               ),
  //               rightTitles: const AxisTitles(
  //                 sideTitles: SideTitles(showTitles: false),
  //               ),
  //             ),
  //             borderData: FlBorderData(show: false),
  //             lineBarsData: [
  //               LineChartBarData(
  //                 spots: expectedSpots,
  //                 isCurved: true,
  //                 color: Colors.blue.withOpacity(0.3),
  //                 barWidth: 2,
  //                 dotData: const FlDotData(show: false),
  //                 belowBarData: BarAreaData(
  //                   show: true,
  //                   color: Colors.blue.withOpacity(0.1),
  //                 ),
  //               ),
  //               LineChartBarData(
  //                 spots: collectedSpots,
  //                 isCurved: true,
  //                 color: colorScheme.primary,
  //                 barWidth: 3,
  //                 dotData: const FlDotData(show: false),
  //                 belowBarData: BarAreaData(
  //                   show: true,
  //                   color: colorScheme.primary.withOpacity(0.2),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           _buildLegendItem('Expected', Colors.blue.withOpacity(0.5)),
  //           const SizedBox(width: 24),
  //           _buildLegendItem('Collected', colorScheme.primary),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildLegendItem(String label, Color color) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 12,
  //         height: 12,
  //         decoration: BoxDecoration(
  //           color: color,
  //           borderRadius: BorderRadius.circular(3),
  //         ),
  //       ),
  //       const SizedBox(width: 6),
  //       Text(
  //         label,
  //         style: GoogleFonts.inter(
  //           fontSize: 11,
  //           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions(
    BuildContext context,
    Map<String, dynamic> data,
    bool isActive,
  ) {
    if (!isActive) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _startChitti(data['id']),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 24),
          label: Text(
            'Start Chitti Collection',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quick Actions', style: _sectionTitleStyle(context)),
            Text(
              'Management',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.payments_outlined,
                label: 'Payments',
                subLabel: 'Collection View',
                color: const Color(0xFF0D9488),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/chitti_payments',
                  arguments: data,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.emoji_events_outlined,
                label: 'Winners',
                subLabel: 'Lucky Draw',
                color: Colors.amber[700]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LuckyDrawResultsScreen(
                      chittiId: data['id'],
                      chittiName: data['name'],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: contentColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColorPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColorSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MEMBER DISTRIBUTION ====================
  Widget _buildMemberDistribution(
    BuildContext context,
    Map<String, dynamic> data,
    int membersCount,
    int maxSlots,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final primaryColor = isDark
        ? const Color(0xFF0891B2)
        : const Color(0xFF0891B2);

    final emptySlots = maxSlots - membersCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Member Distribution', style: _sectionTitleStyle(context)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: contentColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        value: membersCount.toDouble(),
                        color: primaryColor,
                        title: '',
                        radius: 20,
                      ),
                      PieChartSectionData(
                        value: emptySlots.toDouble(),
                        color: borderColor,
                        title: '',
                        radius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDistributionRow(
                      context,
                      'Active Members',
                      membersCount,
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildDistributionRow(
                      context,
                      'Available Slots',
                      emptySlots,
                      textColorSecondary.withOpacity(0.5),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Capacity',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textColorSecondary,
                          ),
                        ),
                        Text(
                          '$maxSlots',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColorPrimary,
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
      ],
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: textColorSecondary),
        ),
        const Spacer(),
        Text(
          '$value',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColorPrimary,
          ),
        ),
      ],
    );
  }

  // ==================== GOLD OPTIONS ====================
  Widget _buildGoldOptionsSummary(
    BuildContext context,
    Map<String, dynamic> data,
    String currency,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final primaryColor = const Color(0xFF0891B2);

    final goldOptions = data['goldOptions'] as List;
    final goldOptionRewards = data['goldOptionRewards'] as Map? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Installment Options', style: _sectionTitleStyle(context)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: contentColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: goldOptions.asMap().entries.map((entry) {
              final option = entry.value as Map;
              final isLast = entry.key == goldOptions.length - 1;
              final weight = option['weight'] ?? '';
              final price = option['price'] ?? 0;
              final purity = option['purity'] ?? '';
              final type = option['type'] ?? 'Gold';

              // Find reward for this option by checking all rewards
              Map? rewardConfig;
              for (var rewardEntry in goldOptionRewards.entries) {
                final reward = rewardEntry.value as Map?;
                if (reward != null && reward['enabled'] == true) {
                  rewardConfig = reward;
                  break;
                }
              }

              // Try to find reward by matching the option index
              final rewardKeys = goldOptionRewards.keys.toList();
              if (entry.key < rewardKeys.length) {
                final matchingReward =
                    goldOptionRewards[rewardKeys[entry.key]] as Map?;
                if (matchingReward != null &&
                    matchingReward['enabled'] == true) {
                  rewardConfig = matchingReward;
                }
              }

              final hasReward =
                  rewardConfig != null && rewardConfig['enabled'] == true;
              final rewardAmount = hasReward
                  ? (rewardConfig['calculatedAmount'] ??
                        rewardConfig['value'] ??
                        0)
                  : 0;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          size: 24,
                          color: Colors.amber,
                        ),
                      ),
                      title: Text(
                        '$type • $purity',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: textColorPrimary,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(
                              weight,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: textColorSecondary,
                              ),
                            ),
                            if (hasReward) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Reward: $currency${rewardAmount.toString()}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: Text(
                        '$currency$price/mo',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: borderColor,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==================== IMPORTANT DATES ====================
  Widget _buildImportantDates(BuildContext context, Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Important Dates', style: _sectionTitleStyle(context)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: contentColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildDateItem(
                context,
                Icons.calendar_month_outlined,
                'Start Month',
                data['startMonth'] ?? 'N/A',
                const Color(0xFF10B981),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDateItem(
                context,
                Icons.payments_outlined,
                'Payment Day',
                'Day ${data['paymentDay'] ?? 5}',
                const Color(0xFF0891B2),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDateItem(
                context,
                Icons.emoji_events_outlined,
                'Winners selection',
                'Day ${data['luckyDrawDay'] ?? 10}',
                const Color(0xFFF59E0B),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDateItem(
                context,
                Icons.timer_outlined,
                'Duration',
                '${data['duration'] ?? 0} months',
                const Color(0xFF6366F1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColorSecondary,
            ),
          ),
        ),
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

  // ==================== MEMBERS LIST (Slot-based) ====================
  Widget _buildMembersList(
    BuildContext context,
    Map<String, dynamic> data,
    Map membersMap,
  ) {
    final currency = DatabaseService().getCurrencySymbol();
    final duration = data['duration'] ?? 20;

    // 1. Convert to list
    final allSlots = membersMap.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      map['slotId'] = e.key;
      return map;
    }).toList();

    // 2. Group by userId
    final groupedMembers = <String, List<Map<String, dynamic>>>{};
    for (final slot in allSlots) {
      final userId = slot['userId'] as String? ?? 'unknown';
      if (!groupedMembers.containsKey(userId)) {
        groupedMembers[userId] = [];
      }
      groupedMembers[userId]!.add(slot);
    }

    // 3. Sort by first slot number
    final sortedUserIds = groupedMembers.keys.toList()
      ..sort((a, b) {
        final slotsA = groupedMembers[a]!;
        final slotsB = groupedMembers[b]!;
        final minSlotA = slotsA
            .map((s) => s['slotNumber'] as int)
            .reduce((min, val) => min < val ? min : val);
        final minSlotB = slotsB
            .map((s) => s['slotNumber'] as int)
            .reduce((min, val) => min < val ? min : val);
        return minSlotA.compareTo(minSlotB);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members (${groupedMembers.length}) • Slots (${allSlots.length})',
              style: _sectionTitleStyle(context),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/add_member_to_chitti',
                arguments: data['id'],
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0891B2),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Add Member',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (allSlots.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 40,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF94A3B8).withOpacity(0.5)
                      : const Color(0xFF475569).withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No members joined yet',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedUserIds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final userId = sortedUserIds[index];
              final userSlots = groupedMembers[userId]!;

              // Sort slots for this user
              userSlots.sort(
                (a, b) =>
                    (a['slotNumber'] as int).compareTo(b['slotNumber'] as int),
              );

              // Fetch User Profile ONCE for the group
              return FutureBuilder<Map<String, dynamic>?>(
                future: DatabaseService().getUserProfile(userId),
                builder: (context, userSnapshot) {
                  final userName =
                      userSnapshot.data?['firstName'] ?? 'Loading...';
                  final lastName = userSnapshot.data?['lastname'] ?? '';
                  final fullName = '$userName $lastName'.trim();
                  final phone = userSnapshot.data?['phone'] ?? '';
                  final joinedAt = userSlots.first['joinedAt'];

                  // Calculate totals for the group
                  double totalMonthly = 0;
                  double totalPayable = 0;

                  for (var s in userSlots) {
                    totalPayable += (s['totalAmount'] ?? 0);
                    totalMonthly += (s['totalAmount'] ?? 0) / duration;
                  }

                  // Date
                  String joinedDateStr = 'N/A';
                  if (joinedAt != null) {
                    final date = joinedAt is int
                        ? DateTime.fromMillisecondsSinceEpoch(joinedAt)
                        : DateTime.tryParse(joinedAt.toString());
                    if (date != null) {
                      joinedDateStr = '${date.day}/${date.month}/${date.year}';
                    }
                  }

                  return _buildGroupedMemberCard(
                    context,
                    userId: userId,
                    fullName: fullName,
                    phone: phone,
                    joinedDate: joinedDateStr,
                    userSlots: userSlots,
                    totalMonthly: totalMonthly,
                    totalPayable: totalPayable,
                    currencySymbol: currency,
                    onSlotTap: (slotData) {
                      // Navigation to history will happen here
                      print("Tapped slot ${slotData['slotNumber']}");
                      // For now, show menu or direct nav
                      _showSlotHistory(context, slotData, fullName, data['id']);
                    },
                    onOptions: (slotData) {
                      // _showOptionsMenu(context, {
                      //   ...slotData,
                      //   'userId': userId,
                      //   'chittiId': data['id'], // Also useful for options
                      // });
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildGroupedMemberCard(
    BuildContext context, {
    required String userId,
    required String fullName,
    required String phone,
    required String joinedDate,
    required List<Map<String, dynamic>> userSlots,
    required double totalMonthly,
    required double totalPayable,
    required String currencySymbol,
    required Function(Map<String, dynamic>) onSlotTap,
    required Function(Map<String, dynamic>) onOptions,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = const Color(0xFF0891B2);
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textColorSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final contentColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: contentColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. User Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColorPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textColorSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${userSlots.length} ${userSlots.length == 1 ? 'Slot' : 'Slots'}",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          // 2. Summary Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactStat(
                context,
                "Monthly Total",
                "$currencySymbol${totalMonthly.toStringAsFixed(0)}",
              ),
              _buildCompactStat(
                context,
                "Total Payable",
                "$currencySymbol${totalPayable.toStringAsFixed(0)}",
              ),
              _buildCompactStat(context, "Joined", joinedDate),
            ],
          ),
          const SizedBox(height: 16),
          // 3. User Slots
          Column(
            children: userSlots.map((slot) {
              final selectedOption = slot['goldOption'] as Map?;
              final weight = selectedOption?['weight'] ?? 'N/A';
              final monthlyPrice = selectedOption?['price'] ?? 0;

              // Settlement status
              final settlementStr =
                  slot['settlementStatus'] as String? ?? 'none';
              final settlementStatus = SlotSettlementStatusX.fromString(
                settlementStr,
              );
              final hasSettlement =
                  settlementStatus != SlotSettlementStatus.none;
              final isSettled =
                  settlementStatus == SlotSettlementStatus.settledUp ||
                  settlementStatus == SlotSettlementStatus.refundCompleted;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onSlotTap(slot),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.03)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasSettlement
                            ? (isSettled
                                  ? const Color(0xFF10B981).withOpacity(0.3)
                                  : Colors.amber.withOpacity(0.3))
                            : borderColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Slot Number
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: hasSettlement
                                ? (isSettled
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : Colors.amber.withOpacity(0.1))
                                : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: hasSettlement && isSettled
                              ? const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Color(0xFF10B981),
                                )
                              : Text(
                                  slot['slotNumber']?.toString() ?? '?',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Slot ${slot['slotNumber']}",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColorPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0D9488,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.diamond,
                                          size: 10,
                                          color: Color(0xFF0D9488),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          weight,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0D9488),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasSettlement) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSettled
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1)
                                            : Colors.amber.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${settlementStatus.emoji} ${settlementStatus.displayLabel}',
                                        style: GoogleFonts.inter(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: isSettled
                                              ? const Color(0xFF10B981)
                                              : Colors.amber.shade700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "$currencySymbol$monthlyPrice / month",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: textColorSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: textColorSecondary,
                          ),
                          onPressed: () => onOptions(slot),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showSlotHistory(
    BuildContext context,
    Map<String, dynamic> slotData,
    String userName,
    String chittiId,
  ) {
    // Navigate to Payment History with Slot Context
    // Passing arguments to PaymentHistoryScreen (we need to update it to accept these)
    Navigator.pushNamed(
      context,
      '/payment_history', // Ensure route exists or push MaterialPageRoute
      arguments: {
        'chittiId': chittiId,
        'slotId': slotData['slotId'],
        'slotNumber': slotData['slotNumber'],
        'userName': userName,
      },
    );
  }

  // ==================== HELPERS ====================
  TextStyle _sectionTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textColorPrimary,
      letterSpacing: -0.5,
    );
  }

  void _showOptionsMenu(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Chitti'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export Report'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Chitti',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
