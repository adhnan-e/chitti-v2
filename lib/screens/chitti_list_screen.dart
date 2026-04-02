import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/database_service.dart';
import 'package:chitt/screens/organizer_home_screen.dart';

class ChittiListScreen extends StatefulWidget {
  const ChittiListScreen({super.key});

  @override
  State<ChittiListScreen> createState() => _ChittiListScreenState();
}

class _ChittiListScreenState extends State<ChittiListScreen> {
  List<Map<String, dynamic>> _allChittis = [];
  List<Map<String, dynamic>> _filteredChittis = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchChittis();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChittis() async {
    final chittis = await DatabaseService().getAllChittis();
    if (mounted) {
      setState(() {
        _allChittis = chittis;
        _filterChittis();
        _isLoading = false;
      });
    }
  }

  void _filterChittis() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChittis = _allChittis.where((chitti) {
        final name = (chitti['name'] ?? '').toString().toLowerCase();
        final startMonth = (chitti['startMonth'] ?? '')
            .toString()
            .toLowerCase();
        final status = chitti['status'] ?? 'active';

        if (_selectedFilter == 'Active' && status != 'active') return false;
        if (_selectedFilter == 'Completed' && status != 'completed') {
          return false;
        }

        return name.contains(query) || startMonth.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeCount = _allChittis
        .where((c) => c['status'] == 'active')
        .length;
    final completedCount = _allChittis
        .where((c) => c['status'] == 'completed')
        .length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Premium Header with Gradient
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 24,
              left: 24,
              right: 24,
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Chittis',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Manage your investment chittis',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _buildAddButton(context),
                  ],
                ),
                const SizedBox(height: 24),
                // Premium Search Bar
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterChittis(),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name or month...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0D9488),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.cancel_rounded,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterChittis();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Refined Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All Chittis',
                    count: _allChittis.length,
                    isSelected: _selectedFilter == 'All',
                    onTap: () {
                      setState(() => _selectedFilter = 'All');
                      _filterChittis();
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Active',
                    count: activeCount,
                    isSelected: _selectedFilter == 'Active',
                    onTap: () {
                      setState(() => _selectedFilter = 'Active');
                      _filterChittis();
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Completed',
                    count: completedCount,
                    isSelected: _selectedFilter == 'Completed',
                    onTap: () {
                      setState(() => _selectedFilter = 'Completed');
                      _filterChittis();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // List Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                  )
                : _filteredChittis.isEmpty
                ? _buildEmptyState(context, colorScheme)
                : RefreshIndicator(
                    onRefresh: _fetchChittis,
                    color: const Color(0xFF0D9488),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _filteredChittis.length,
                      itemBuilder: (context, index) {
                        return DetailedChittiCard(
                          chitti: _filteredChittis[index],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/organizer_chitti_details',
                            arguments: _filteredChittis[index],
                          ).then((_) => _fetchChittis()),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/create_chitti',
        ).then((_) => _fetchChittis()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colorScheme.outline.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No chittis found',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms.'
                : 'Start by creating your first chitti.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D9488)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
