import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/settings_service.dart';
import 'package:chitt/core/models/gold_option.dart';

/// Masters Screen - Manage gold types, purities, and options
class MastersScreen extends StatefulWidget {
  const MastersScreen({super.key});

  @override
  State<MastersScreen> createState() => _MastersScreenState();
}

class _MastersScreenState extends State<MastersScreen> {
  bool _isLoading = true;
  List<String> _goldTypes = [];
  List<String> _goldPurities = [];
  List<GoldOption> _goldOptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final types = await SettingsService().getGoldTypes();
      final purities = await SettingsService().getGoldPurities();
      final options = await SettingsService().getGoldOptionsV2();
      setState(() {
        _goldTypes = types;
        _goldPurities = purities;
        _goldOptions = options;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading masters data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============ Gold Types ============

  void _showAddTypeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Gold Type',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g., Ring, Chain',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await SettingsService().addGoldType(value);
                await _loadData();
                if (mounted) Navigator.pop(context);
                _showSnackBar('Gold type added');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveType(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Type?'),
        content: Text('Are you sure you want to remove "$type"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SettingsService().removeGoldType(type);
              await _loadData();
              if (mounted) Navigator.pop(context);
              _showSnackBar('Gold type removed');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ============ Gold Purities ============

  void _showAddPurityDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Gold Purity',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g., 21 Karat',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await SettingsService().addGoldPurity(value);
                await _loadData();
                if (mounted) Navigator.pop(context);
                _showSnackBar('Gold purity added');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmRemovePurity(String purity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Purity?'),
        content: Text('Are you sure you want to remove "$purity"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SettingsService().removeGoldPurity(purity);
              await _loadData();
              if (mounted) Navigator.pop(context);
              _showSnackBar('Gold purity removed');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ============ Gold Options ============

  void _showAddOptionDialog() {
    String? selectedType = _goldTypes.isNotEmpty ? _goldTypes.first : null;
    String? selectedPurity = _goldPurities.isNotEmpty
        ? _goldPurities.first
        : null;
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Gold Option',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Dropdown
              Text(
                'Gold Type',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: _goldTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Purity Dropdown
              Text(
                'Purity',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPurity,
                    isExpanded: true,
                    items: _goldPurities.map((purity) {
                      return DropdownMenuItem(
                        value: purity,
                        child: Text(purity),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedPurity = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weight Input
              Text(
                'Weight (grams)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., 10 or 0.5',
                  suffixText: 'grams',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final weight = double.tryParse(weightController.text);
                if (selectedType != null &&
                    selectedPurity != null &&
                    weight != null &&
                    weight > 0) {
                  final option = GoldOption(
                    id: GoldOption.generateId(),
                    type: selectedType!,
                    purity: selectedPurity!,
                    weight: weight,
                  );
                  await SettingsService().addGoldOptionV2(option);
                  await _loadData();
                  if (mounted) Navigator.pop(context);
                  _showSnackBar('Gold option added');
                } else {
                  _showSnackBar('Please fill all fields', isError: true);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveOption(GoldOption option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Option?'),
        content: Text(
          'Are you sure you want to remove "${option.displayLabel}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SettingsService().removeGoldOptionV2(option.id);
              await _loadData();
              if (mounted) Navigator.pop(context);
              _showSnackBar('Gold option removed');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'coin':
        return '🪙';
      case 'biscuit':
        return '🧱';
      case 'bar':
        return '📦';
      case 'jewelry':
        return '💍';
      default:
        return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Masters',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Masters',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gold Types Section
          _buildSectionHeader('Gold Types', _showAddTypeDialog),
          const SizedBox(height: 12),
          _buildChipList(
            items: _goldTypes,
            icon: (item) => _getTypeIcon(item),
            onRemove: _confirmRemoveType,
          ),

          const SizedBox(height: 24),

          // Gold Purities Section
          _buildSectionHeader('Gold Purities', _showAddPurityDialog),
          const SizedBox(height: 12),
          _buildChipList(items: _goldPurities, onRemove: _confirmRemovePurity),

          const SizedBox(height: 24),

          // Gold Options Section
          _buildSectionHeader('Gold Options', _showAddOptionDialog),
          const SizedBox(height: 12),
          if (_goldOptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No gold options added yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...(_goldOptions.map((option) => _buildOptionCard(option))),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6366F1),
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1)),
          tooltip: 'Add',
        ),
      ],
    );
  }

  Widget _buildChipList({
    required List<String> items,
    String Function(String)? icon,
    required void Function(String) onRemove,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No items yet. Tap + to add.',
            style: GoogleFonts.inter(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Chip(
          avatar: icon != null
              ? Text(icon(item), style: const TextStyle(fontSize: 16))
              : null,
          label: Text(
            item,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => onRemove(item),
          backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildOptionCard(GoldOption option) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Type Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                option.typeIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${option.type} • ${option.weight}g',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    option.purity,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Remove Button
          IconButton(
            onPressed: () => _confirmRemoveOption(option),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
