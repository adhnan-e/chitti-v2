import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/database_service.dart';

class LuckyDrawResultsScreen extends StatefulWidget {
  final String? chittiId;
  final String? chittiName;
  final int? totalSlots;

  const LuckyDrawResultsScreen({
    super.key,
    this.chittiId,
    this.chittiName,
    this.totalSlots,
  });

  @override
  State<LuckyDrawResultsScreen> createState() => _LuckyDrawResultsScreenState();
}

class _LuckyDrawResultsScreenState extends State<LuckyDrawResultsScreen> {
  List<Map<String, dynamic>> _allResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  List<Map<String, dynamic>> _remainingSlots = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _totalSlots = 0;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    List<Map<String, dynamic>> results;

    if (widget.chittiId != null) {
      // Fetch winners for specific chitti
      results = await DatabaseService().getChittiWinners(widget.chittiId!);

      // Fetch all members to calculate remaining slots
      final members = await DatabaseService().getChittiMembersDetails(
        widget.chittiId!,
      );
      _totalSlots = members.length;

      // Find slots that haven't won yet
      final wonSlotIds = results.map((w) => w['slotId']).toSet();
      _remainingSlots = members
          .where((m) => !wonSlotIds.contains(m['slotId']))
          .toList();
    } else {
      // Fetch all lucky draw history
      results = await DatabaseService().getLuckyDrawHistory();
    }

    if (mounted) {
      setState(() {
        _allResults = results;
        _filteredResults = results;
        _isLoading = false;
      });
    }
  }

  void _filterResults(String query) {
    if (query.isEmpty) {
      setState(() => _filteredResults = _allResults);
      return;
    }
    setState(() {
      _filteredResults = _allResults.where((r) {
        final name = (r['userName'] ?? '').toString().toLowerCase();
        final month = (r['month'] ?? '').toString().toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || month.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColorPrimary = isDark
        ? const Color(0xFFF7F9FC)
        : const Color(0xFF333333);
    final textColorSecondary = isDark
        ? const Color(0xFF98A2B3)
        : const Color(0xFF666666);
    const accentColor = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back,
                        color: textColorPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chittiName != null
                              ? 'Lucky Draw Winners'
                              : 'All Winners',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColorPrimary,
                          ),
                        ),
                        if (widget.chittiName != null)
                          Text(
                            widget.chittiName!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textColorSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      slivers: [
                        // Stats Header (only for specific chitti)
                        if (widget.chittiId != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade400,
                                      Colors.orange.shade500,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                          icon: Icons.emoji_events,
                                          value: '${_allResults.length}',
                                          label: 'Winners',
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white24,
                                        ),
                                        _buildStatItem(
                                          icon: Icons.hourglass_empty,
                                          value: '${_remainingSlots.length}',
                                          label: 'Remaining',
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white24,
                                        ),
                                        _buildStatItem(
                                          icon: Icons.people,
                                          value: '$_totalSlots',
                                          label: 'Total Slots',
                                        ),
                                      ],
                                    ),
                                    if (_remainingSlots.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: _totalSlots > 0
                                              ? _allResults.length / _totalSlots
                                              : 0,
                                          minHeight: 8,
                                          backgroundColor: Colors.white24,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.white),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Search Bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterResults,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: textColorSecondary,
                                  ),
                                  hintText: 'Search winners...',
                                  hintStyle: GoogleFonts.inter(
                                    color: textColorSecondary,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                style: GoogleFonts.inter(
                                  color: textColorPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // Winners Section Header
                        if (_filteredResults.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Winners (${_filteredResults.length})',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 8)),

                        // Winners List
                        _filteredResults.isEmpty
                            ? SliverFillRemaining(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.emoji_events_outlined,
                                        size: 64,
                                        color: textColorSecondary.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No winners yet',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: textColorSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final result = _filteredResults[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: _buildWinnerCard(
                                      result,
                                      index + 1,
                                      cardColor,
                                      textColorPrimary,
                                      textColorSecondary,
                                    ),
                                  );
                                }, childCount: _filteredResults.length),
                              ),

                        // Remaining Slots Section (only for specific chitti)
                        if (widget.chittiId != null &&
                            _remainingSlots.isNotEmpty) ...[
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remaining Slots (${_remainingSlots.length})',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final slot = _remainingSlots[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: _buildRemainingSlotCard(
                                  slot,
                                  cardColor,
                                  textColorPrimary,
                                  textColorSecondary,
                                  colorScheme,
                                ),
                              );
                            }, childCount: _remainingSlots.length),
                          ),
                        ],

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildWinnerCard(
    Map<String, dynamic> result,
    int rank,
    Color cardColor,
    Color textColorPrimary,
    Color textColorSecondary,
  ) {
    final slotNumber = result['slotNumber'];
    final name = result['userName'] ?? 'Unknown';
    final month = result['month'] ?? 'N/A';
    // final prize = result['prize'] ?? 'Prize'; // Unused
    final chittiName = result['chittiName'];

    // Get gold option weight
    String goldWeight = '';
    final goldOption = result['goldOption'];
    if (goldOption != null && goldOption['weight'] != null) {
      goldWeight = '${goldOption['weight']}g';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy with rank
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade300, Colors.orange.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              if (slotNumber != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '#$slotNumber',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColorPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: textColorSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      month,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textColorSecondary,
                      ),
                    ),
                    if (chittiName != null && widget.chittiId == null) ...[
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: textColorSecondary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chittiName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textColorSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Prize
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.diamond_outlined,
                  size: 18,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(height: 2),
                Text(
                  goldWeight.isNotEmpty ? goldWeight : 'Gold',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingSlotCard(
    Map<String, dynamic> slot,
    Color cardColor,
    Color textColorPrimary,
    Color textColorSecondary,
    ColorScheme colorScheme,
  ) {
    final slotNumber = slot['slotNumber'] ?? 0;
    final name = slot['name'] ?? 'Unknown';
    final phone = slot['phone'] ?? '';

    // Get gold option
    String goldWeight = '';
    final goldOption = slot['goldOption'];
    if (goldOption != null && goldOption['weight'] != null) {
      goldWeight = '${goldOption['weight']}g';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Slot number
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$slotNumber',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColorPrimary,
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
          // Gold option
          if (goldWeight.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond_outlined, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    goldWeight,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColorPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          // Pending badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Pending',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
