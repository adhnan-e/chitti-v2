import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/screens/chitti_list_screen.dart';
import 'package:chitt/screens/member_list_screen.dart';
import 'package:chitt/screens/settings_screen.dart';
import 'package:chitt/services/database_service.dart';
import 'package:chitt/services/auth_service.dart';
import 'package:chitt/core/design/components/components.dart';

class OrganizerHomeScreen extends StatefulWidget {
  const OrganizerHomeScreen({super.key});

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _OrganizerDashboardTab(),
      const ChittiListScreen(),
      const MemberListScreen(),
      const SettingsScreen(),
    ];

    return AppScaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          AppBottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Home',
          ),
          AppBottomNavItem(
            icon: Icons.list_alt_outlined,
            activeIcon: Icons.list_alt,
            label: 'Chittis',
          ),
          AppBottomNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Members',
          ),
          AppBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _OrganizerDashboardTab extends StatefulWidget {
  const _OrganizerDashboardTab();

  @override
  State<_OrganizerDashboardTab> createState() => _OrganizerDashboardTabState();
}

class _OrganizerDashboardTabState extends State<_OrganizerDashboardTab> {
  List<Map<String, dynamic>> _chittis = [];
  bool _isLoading = true;
  int _totalChittis = 0;
  int _activeChittis = 0;
  int _pendingChittis = 0;
  int _completedChittis = 0;
  double _totalPortfolioCollected = 0.0;
  double _totalPortfolioTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await DatabaseService().getAppSettings();
    final chittis = await DatabaseService().getAllChittis();

    double totalColl = 0;
    double totalTarget = 0;
    int activeCount = 0;
    int pendingCount = 0;
    int completedCount = 0;

    for (var chitti in chittis) {
      final status = chitti['status'] ?? 'pending';
      if (status == 'active') {
        activeCount++;
        final financials = await DatabaseService().getChittiFinancials(
          chitti['id'],
        );
        totalColl += (financials['totalCollected'] ?? 0).toDouble();
        totalTarget += (financials['totalExpected'] ?? 0).toDouble();
      } else if (status == 'pending') {
        pendingCount++;
      } else if (status == 'completed') {
        completedCount++;
      }
    }

    if (mounted) {
      setState(() {
        _chittis = chittis;
        _totalChittis = chittis.length;
        _activeChittis = activeCount;
        _pendingChittis = pendingCount;
        _completedChittis = completedCount;
        _totalPortfolioCollected = totalColl;
        _totalPortfolioTarget = totalTarget;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = AuthService().currentUser;
    final userName =
        currentUser?['fullName'] ?? currentUser?['username'] ?? 'Organizer';

    final currency = DatabaseService().getCurrencySymbol();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: const Color(0xFF0D9488),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // Premium Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName 👋',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Business Overview',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _buildProfileButton(context, currentUser),
                ],
              ),
              const SizedBox(height: 24),

              // Detailed Stats Grid
              _buildStatsOverviewGrid(context, currency),

              const SizedBox(height: 24),

              // Modern Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline,
                      label: 'New Chitti',
                      color: const Color(0xFF0D9488),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/create_chitti',
                      ).then((_) => _fetchData()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person_add_outlined,
                      label: 'Add Member',
                      color: const Color(0xFF6366F1),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/add_member',
                      ).then((_) => _fetchData()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Active Chittis Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Chittis',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Chitti List tab
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_chittis.isEmpty)
                _buildEmptyState(context, colorScheme)
              else
                ..._chittis
                    .take(5)
                    .map(
                      (chitti) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DetailedChittiCard(
                          chitti: chitti,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/organizer_chitti_details',
                            arguments: chitti,
                          ).then((_) => _fetchData()),
                        ),
                      ),
                    ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, Map<String, dynamic>? user) {
    final initials = (user?['username'] as String?)?.isNotEmpty == true
        ? user!['username'][0].toUpperCase()
        : '?';
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/settings'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            initials,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D9488),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverviewGrid(BuildContext context, String currency) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Chittis',
                value: _totalChittis.toString(),
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF0D9488),
                infoText: 'Total number of chittis created in your portfolio.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Active Now',
                value: _activeChittis.toString(),
                icon: Icons.play_circle_outline,
                color: const Color(0xFF10B981),
                infoText:
                    'Chittis that are currently running and collecting payments.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pending',
                value: _pendingChittis.toString(),
                icon: Icons.timer_outlined,
                color: const Color(0xFFF59E0B),
                infoText:
                    'Chittis that haven\'t started yet or are waiting for members.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Completed',
                value: _completedChittis.toString(),
                icon: Icons.check_circle_outline,
                color: const Color(0xFF6366F1),
                infoText:
                    'Chittis that have finished their full duration successfully.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Total Collection Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF0D9488),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Collections',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _InfoIcon(
                          text:
                              'Combined amount collected vs target across all active chittis.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency ${_totalPortfolioCollected.toStringAsFixed(0)} / $currency ${_totalPortfolioTarget.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0D9488),
                      ),
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

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No Active Chittis',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first investment chitti to see stats here.',
            textAlign: TextAlign.center,
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact Chitti Card with accurate progress
class DetailedChittiCard extends StatelessWidget {
  final Map<String, dynamic> chitti;
  final VoidCallback onTap;

  const DetailedChittiCard({
    super.key,
    required this.chitti,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = DatabaseService().getCurrencySymbol();

    final name = chitti['name'] ?? 'Chitti';
    final status = chitti['status'] ?? 'active';
    final startMonth = chitti['startMonth'] ?? '';
    final duration = chitti['duration'] ?? '';
    final maxSlots = int.tryParse(chitti['maxSlots']?.toString() ?? '0') ?? 1;
    final isActive = status == 'active';

    final membersMap = (chitti['members'] as Map?) ?? {};
    final totalMembers = membersMap.length;

    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseService().getChittiFinancials(chitti['id']),
      builder: (context, snapshot) {
        final financials = snapshot.data ?? {};
        final collected = (financials['totalCollected'] ?? 0).toDouble();
        final expected = (financials['totalExpected'] ?? 0).toDouble();
        final progress = expected > 0
            ? (collected / expected).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF0D9488).withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isActive
                                ? Icons.auto_graph_rounded
                                : Icons.pause_circle_outline,
                            color: isActive
                                ? const Color(0xFF0D9488)
                                : Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$startMonth • $duration Mo',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildBadge(status, isActive),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stats Row - Compact inline
                    Row(
                      children: [
                        _buildCompactStat(
                          context,
                          Icons.people_outline,
                          '$totalMembers/$maxSlots',
                          'Slots',
                        ),
                        const SizedBox(width: 16),
                        _buildCompactStat(
                          context,
                          Icons.account_balance_wallet_outlined,
                          '$currency ${collected.toStringAsFixed(0)}',
                          'Collected',
                        ),
                        const Spacer(),
                        // Progress indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2,
                                  backgroundColor: const Color(
                                    0xFF0D9488,
                                  ).withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF0D9488),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0D9488),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBadge(String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF0D9488).withOpacity(0.1)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isActive ? const Color(0xFF0D9488) : Colors.orange.shade700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String infoText;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
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
                child: Icon(icon, color: color, size: 20),
              ),
              _InfoIcon(text: infoText),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final String text;

  const _InfoIcon({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                const Text('Information'),
              ],
            ),
            content: Text(text, style: GoogleFonts.inter(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
      child: Icon(
        Icons.info_outline,
        size: 14,
        color: Colors.black.withOpacity(0.3),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
