import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/database_service.dart';
import 'package:chitt/services/document_service.dart';

class MemberDetailsScreen extends StatefulWidget {
  const MemberDetailsScreen({super.key});

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _memberData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _memberData = args;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addDocument(BuildContext context) async {
    final userId = _memberData?['id'];
    if (userId == null) return;
    try {
      final files = await DocumentService().pickDocuments(allowMultiple: false);
      if (files.isEmpty) return;

      if (!mounted) return;
      setState(() => _isLoading = true);

      final file = files.first;
      final docData = await DocumentService().uploadDocument(
        userId: userId,
        file: file,
      );

      final existingDocs = DocumentService().getDocumentsList(
        _memberData?['documents'],
      );
      final newDocsList = [...existingDocs, docData];

      final name = _memberData?['name'] ?? '';
      await DatabaseService().updateUser(
        userId: userId,
        name: name,
        phone: _memberData?['phone'] ?? '',
        email: _memberData?['email'],
        address: _memberData?['address'],
        documents: newDocsList,
      );

      if (mounted) {
        setState(() {
          _memberData?['documents'] = newDocsList;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteMember() async {
    final userId = _memberData?['id'];
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Member',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure? Members with active chitti slots cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await DatabaseService().deleteMember(userId);
      if (mounted) {
        Navigator.pop(context); // Go back
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Member deleted')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_memberData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final name = _memberData!['name'] ?? 'N/A';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _memberData!['phone'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/add_member',
                      arguments: _memberData,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _deleteMember,
                  ),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: colorScheme.primary,
                    tabs: const [
                      Tab(text: 'CHITTIS'),
                      Tab(text: 'HISTORY'),
                      Tab(text: 'INFO'),
                    ],
                  ),
                  colorScheme.surface,
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChittisTab(colorScheme),
                    _buildHistoryTab(colorScheme),
                    _buildInfoTab(colorScheme),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildChittisTab(ColorScheme colorScheme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService().getUserChittis(_memberData!['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final chittis = snapshot.data!;
        if (chittis.isEmpty) {
          return const Center(child: Text('No active chittis'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chittis.length,
          itemBuilder: (context, index) {
            final chitti = chittis[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  chitti['name'] ?? 'Chitti',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Slots: ${(chitti['user_slots'] as List? ?? []).length}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab(ColorScheme colorScheme) =>
      const Center(child: Text('No history available'));

  Widget _buildInfoTab(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoTile(Icons.phone, 'Phone', _memberData!['phone'] ?? 'N/A'),
        _buildInfoTile(Icons.email, 'Email', _memberData!['email'] ?? 'N/A'),
        _buildInfoTile(
          Icons.location_on,
          'Address',
          _memberData!['address'] ?? 'N/A',
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Add Document'),
          subtitle: const Text('Upload identification or other files'),
          trailing: const Icon(Icons.add_a_photo),
          onTap: () => _addDocument(context),
        ),
        if (_memberData!['documents'] != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Uploaded Documents',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          ...(_memberData!['documents'] as List).map((doc) {
            final data = Map<String, dynamic>.from(doc as Map);
            return ListTile(
              leading: const Icon(Icons.file_present),
              title: Text(data['name'] ?? 'Document'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/document_viewer',
                  arguments: doc,
                );
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
