import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/database_service.dart';

class AddMemberToChittiScreen extends StatefulWidget {
  final String chittiId;
  const AddMemberToChittiScreen({super.key, this.chittiId = 'chitti_123'});

  @override
  State<AddMemberToChittiScreen> createState() =>
      _AddMemberToChittiScreenState();
}

class _AddMemberToChittiScreenState extends State<AddMemberToChittiScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _selectedMembers = []; // List of member data
  // Track userId -> { goldOptionIndex: count }
  final Map<String, Map<int, int>> _memberSelections = {};
  String _lateChittiId = '';
  Map<String, dynamic>? _chittiDetails;
  bool _isFetchingDetails = true;
  List<Map<String, dynamic>> _allUsers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _lateChittiId = args;
    } else {
      _lateChittiId = widget.chittiId;
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!_isFetchingDetails && _allUsers.isNotEmpty) return;

    setState(() => _isFetchingDetails = true);

    final users = await DatabaseService().getAllUsers();
    final chitti = await DatabaseService().getChitti(_lateChittiId);

    if (mounted) {
      setState(() {
        _allUsers = users
            .where((u) => (u['role'] ?? 'user') == 'user')
            .toList();
        _chittiDetails = chitti;
        _isFetchingDetails = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchResults = _allUsers.where((user) {
        final name = '${user['firstName']} ${user['lastname']}'.toLowerCase();
        final phone = (user['phone'] ?? '').toLowerCase();
        return name.contains(lowerQuery) || phone.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _handleAddMember() async {
    if (_memberSelections.isEmpty) {
      _showSnackBar(
        'Please select at least one member and option',
        isError: true,
      );
      return;
    }

    if (_chittiDetails == null) {
      _showSnackBar('Chitti details not loaded', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final goldOptions = (_chittiDetails!['goldOptions'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final durationStr = _chittiDetails!['duration'].toString();
    final durationInt =
        int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;

    final members = (_chittiDetails!['members'] as Map?) ?? {};
    final maxSlots = int.tryParse(_chittiDetails!['maxSlots'].toString()) ?? 20;

    // Calculate total slots being added across all members and options
    int totalSlotsToAdd = 0;
    _memberSelections.forEach((userId, selections) {
      selections.forEach((optionIdx, count) {
        totalSlotsToAdd += count;
      });
    });

    if (members.length + totalSlotsToAdd > maxSlots) {
      _showSnackBar(
        'Not enough slots available! (${maxSlots - members.length} left)',
        isError: true,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      int addedCount = 0;
      for (var member in _selectedMembers) {
        final userId = member['id'];
        final fullName = '${member['firstName']} ${member['lastname']}'.trim();
        final selections = _memberSelections[userId];

        if (selections == null) continue;

        for (var entry in selections.entries) {
          final optionIdx = entry.key;
          final count = entry.value;
          final selectedOption = goldOptions[optionIdx];

          final totalAmount =
              (selectedOption['total_value'] ??
                      ((int.tryParse(selectedOption['price'].toString()) ?? 0) *
                          durationInt))
                  .toDouble();

          for (int i = 0; i < count; i++) {
            final nextSlotNumber = await DatabaseService().getNextSlotNumber(
              _lateChittiId,
            );
            await DatabaseService().addMemberToChitti(
              chittiId: _lateChittiId,
              userId: userId,
              userName: fullName,
              slotNumber: nextSlotNumber,
              selectedGoldOption: selectedOption,
              totalAmount: totalAmount,
            );
            addedCount++;
          }
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        _showSnackBar('Successfully added $addedCount slots!');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = DatabaseService().getCurrencySymbol();

    if (_isFetchingDetails) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_chittiDetails == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load Chitti details',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final goldOptions = (_chittiDetails!['goldOptions'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final durationStr = _chittiDetails!['duration'].toString();
    final durationInt =
        int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final members = (_chittiDetails!['members'] as Map?) ?? {};
    final maxSlots = int.tryParse(_chittiDetails!['maxSlots'].toString()) ?? 70;

    int totalSlotsInBatch = 0;
    double batchTotalAmount = 0;
    double batchFirstMonthAmount = 0;
    double batchMonthlyAmount = 0;

    _memberSelections.forEach((userId, selections) {
      selections.forEach((optionIdx, count) {
        if (optionIdx >= 0 && optionIdx < goldOptions.length) {
          final opt = goldOptions[optionIdx];
          final price = int.tryParse(opt['price'].toString()) ?? 0;
          final totalVal = (opt['total_value'] ?? (price * durationInt))
              .toDouble();
          final firstEMI = (opt['firstMonthEMI'] ?? price).toDouble();

          totalSlotsInBatch += count;
          batchTotalAmount += totalVal * count;
          batchFirstMonthAmount += firstEMI * count;
          batchMonthlyAmount += price * count;
        }
      });
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Premium Teal-Emerald Header
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: const Color(0xFF0D9488),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Member',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${_chittiDetails!['name']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Capacity: ${members.length}/$maxSlots',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Select Member
                  _buildSectionTitle(
                    context,
                    '1',
                    'Select Members',
                    Icons.person_search,
                  ),
                  const SizedBox(height: 12),

                  // Selected Members Matrix
                  if (_selectedMembers.isNotEmpty) ...[
                    ..._selectedMembers.map((member) {
                      final userId = member['id'];
                      final name =
                          '${member['firstName']} ${member['lastname']}'.trim();
                      final selections = _memberSelections[userId] ?? {};

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF0D9488),
                                      child: Text(
                                        name[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedMembers.removeWhere(
                                        (m) => m['id'] == userId,
                                      );
                                      _memberSelections.remove(userId);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: goldOptions.asMap().entries.map((
                                  entry,
                                ) {
                                  final idx = entry.key;
                                  final opt = entry.value;
                                  final weight = opt['weight'] ?? '';
                                  final price = opt['price'] ?? 0;
                                  final count = selections[idx] ?? 0;

                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: count > 0
                                          ? const Color(
                                              0xFF0D9488,
                                            ).withOpacity(0.05)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: count > 0
                                            ? const Color(
                                                0xFF0D9488,
                                              ).withOpacity(0.3)
                                            : colorScheme.outline.withOpacity(
                                                0.1,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              weight,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '$currency$price',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: const Color(0xFF0D9488),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (count > 0) {
                                                    _memberSelections[userId]![idx] =
                                                        count - 1;
                                                    if (_memberSelections[userId]![idx] ==
                                                        0) {
                                                      _memberSelections[userId]!
                                                          .remove(idx);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                              child: Text(
                                                '$count',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                size: 20,
                                                color: Color(0xFF0D9488),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _memberSelections.putIfAbsent(
                                                    userId,
                                                    () => {},
                                                  )[idx] = count + 1;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Search Input & Action
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF0D9488).withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search members...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: Color(0xFF0D9488),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/add_member',
                          );
                          if (result == true) _fetchData();
                        },
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          size: 20,
                          color: Color(0xFF0D9488),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF0D9488,
                          ).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Results (Floating-like overlay)
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _searchResults.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No results',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: colorScheme.outline.withOpacity(0.1),
                              ),
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                final name =
                                    '${user['firstName']} ${user['lastname']}'
                                        .trim();
                                if (name.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final isAlreadyAdded = _selectedMembers.any(
                                  (m) => m['id'] == user['id'],
                                );

                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(
                                      0xFF0D9488,
                                    ).withOpacity(0.1),
                                    child: Text(
                                      name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    user['phone'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: isAlreadyAdded
                                      ? const Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Color(0xFF0D9488),
                                        )
                                      : const Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                          color: Color(0xFF0D9488),
                                        ),
                                  onTap: () {
                                    if (!isAlreadyAdded) {
                                      setState(() {
                                        _selectedMembers.add(
                                          Map<String, dynamic>.from(user),
                                        );
                                        // Default to 1 slot of the first gold option if available
                                        if (goldOptions.isNotEmpty) {
                                          _memberSelections[user['id']] = {
                                            0: 1,
                                          };
                                        } else {
                                          _memberSelections[user['id']] =
                                              {}; // No options, so no slots
                                        }
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Batch Summary
                  _buildSectionTitle(
                    context,
                    '2',
                    'Batch Summary',
                    Icons.receipt_long,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D9488).withOpacity(0.15),
                          const Color(0xFF10B981).withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0D9488).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Slots',
                          '$totalSlotsInBatch',
                          colorScheme,
                          isLarge: true,
                        ),
                        Divider(
                          height: 16,
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                        _buildSummaryRow(
                          'Batch First Month',
                          '$currency$batchFirstMonthAmount',
                          colorScheme,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Batch Monthly (M2-$durationInt)',
                          '$currency$batchMonthlyAmount',
                          colorScheme,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Batch Total',
                          '$currency$batchTotalAmount',
                          colorScheme,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading || _memberSelections.isEmpty
                  ? null
                  : _handleAddMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                disabledBackgroundColor: colorScheme.outline.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group_add, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          totalSlotsInBatch > 0
                              ? 'Add $totalSlotsInBatch Slots'
                              : 'Add Members',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String step,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF0D9488),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isLarge = false,
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isLarge ? 24 : (isPrimary ? 18 : 15),
            fontWeight: isLarge || isPrimary
                ? FontWeight.bold
                : FontWeight.w500,
            color: isPrimary ? const Color(0xFF0D9488) : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
