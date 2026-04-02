import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/database_service.dart';

class DeletedMembersScreen extends StatefulWidget {
  const DeletedMembersScreen({super.key});

  @override
  State<DeletedMembersScreen> createState() => _DeletedMembersScreenState();
}

class _DeletedMembersScreenState extends State<DeletedMembersScreen> {
  List<Map<String, dynamic>> _deletedMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDeletedMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDeletedMembers() async {
    setState(() => _isLoading = true);
    final members = await DatabaseService().getDeletedMembers();
    if (mounted) {
      setState(() {
        _deletedMembers = members;
        _filteredMembers = members;
        _isLoading = false;
      });
    }
  }

  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _deletedMembers.where((member) {
        if (query.isEmpty) return true;
        final name = '${member['firstName'] ?? ''} ${member['lastname'] ?? ''}'
            .toLowerCase();
        final phone = (member['phone'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase()) ||
            phone.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _restoreMember(String userId, String name) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await DatabaseService().restoreMember(userId);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('$name restored successfully')),
      );
      _fetchDeletedMembers();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error restoring member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeletedMemberDetailsSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Deleted Members',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterMembers,
                  decoration: InputDecoration(
                    hintText: 'Search deleted members...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredMembers.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(colorScheme))
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final member = _filteredMembers[index];
                      return _DeletedMemberCard(
                        member: member,
                        onRestore: () => _restoreMember(
                          member['id'],
                          member['name'] ?? 'Member',
                        ),
                        onTap: () => _showMemberDetails(member),
                      );
                    }, childCount: _filteredMembers.length),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Deleted Members',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onRestore;
  final VoidCallback onTap;

  const _DeletedMemberCard({
    required this.member,
    required this.onRestore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = member['name'] ?? 'N/A';
    final phone = member['phone'] ?? 'N/A';
    final deletedAt = member['deletedAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (deletedAt != null)
                      Text(
                        'Deleted on ${_formatDate(deletedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restore_rounded, color: Colors.green),
                onPressed: () {
                  // Confirm restore
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Restore Member'),
                      content: Text('Do you want to restore $name?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onRestore();
                          },
                          child: const Text('Restore'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Restore Member',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) return "${date.day}/${date.month}/${date.year}";
    if (date is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(date);
      return "${dt.day}/${dt.month}/${dt.year}";
    }
    return date.toString();
  }
}

class _DeletedMemberDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> member;

  const _DeletedMemberDetailsSheet({required this.member});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = member['name'] ?? 'N/A';

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Member History',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(name, style: TextStyle(color: colorScheme.outline)),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService().getUserChittis(member['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chittis = snapshot.data!;
                if (chittis.isEmpty) {
                  return const Center(
                    child: Text('No previous chitti history found'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: chittis.length,
                  itemBuilder: (context, index) {
                    final chitti = chittis[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(chitti['name'] ?? 'Chitti'),
                        subtitle: Text(
                          'Status: ${chitti['user_status'] ?? 'N/A'}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
