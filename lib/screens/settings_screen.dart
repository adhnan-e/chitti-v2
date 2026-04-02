import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chitt/services/auth_service.dart';
import 'package:chitt/services/database_service.dart';
import 'package:chitt/services/chitti_name_generator.dart';
import 'package:chitt/core/design/theme/theme_provider.dart';
import 'package:chitt/screens/masters_screen.dart';
import 'package:chitt/utils/currency_data.dart';
import 'package:chitt/utils/currency_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currency = 'AED';
  Map<String, dynamic>? _userProfile;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isEditing = false;
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _nameFormat = 'numeric';
  String _nameTemplate = '{prefix} {number}';
  final _namePrefixController = TextEditingController(text: 'Chitti');
  final _nameTemplateController = TextEditingController();
  int _lastChittiNumber = 0;
  String _previewName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool get _isOrganizer => AuthService().currentUser?['role'] == 'organiser';

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      final profile =
          await DatabaseService().getUserProfile(currentUser['id']) ?? {};
      final appSettings = await DatabaseService().getAppSettings();
      setState(() {
        _userProfile = {...currentUser, ...profile};
        _firstNameController.text = _userProfile?['firstName'] ?? '';
        _lastNameController.text = _userProfile?['lastName'] ?? '';
        _phoneController.text = _userProfile?['phone'] ?? '';
        _currency = appSettings['currency'] ?? 'AED';
        _nameFormat = appSettings['chittiNameFormat'] ?? 'numeric';
        _nameTemplate =
            appSettings['chittiNameTemplate'] ?? '{prefix} {number}';
        _namePrefixController.text =
            appSettings['chittiNamePrefix'] ?? 'Chitti';
        _nameTemplateController.text = _nameTemplate;
        _lastChittiNumber = appSettings['lastChittiNumber'] ?? 0;
        _isLoading = false;
        CurrencyUtils.setCurrencySymbol(CurrencyData.getSymbol(_currency));
      });
      _updatePreview();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = AuthService().currentUser!['id'];
      await DatabaseService().updateUserProfile(userId, {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      setState(() {
        _isEditing = false;
        _userProfile?['firstName'] = _firstNameController.text.trim();
        _userProfile?['lastName'] = _lastNameController.text.trim();
        _userProfile?['phone'] = _phoneController.text.trim();
      });
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAppSettings() async {
    try {
      await DatabaseService().updateAppSettings({
        'currency': _currency,
        'chittiNameFormat': _nameFormat,
        'chittiNameTemplate': _nameTemplate,
        'chittiNamePrefix': _namePrefixController.text.trim(),
      });
      CurrencyUtils.setCurrencySymbol(CurrencyData.getSymbol(_currency));
      _showSnackBar('Settings saved!');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _updateDefaultTemplate(String format) {
    switch (format) {
      case 'numeric':
        _nameTemplate = '{prefix} {number}';
        break;
      case 'alphanumeric':
        _nameTemplate = '{prefix} {letter}{number}';
        break;
      case 'alphabetic':
        _nameTemplate = '{prefix} {letter}';
        break;
      case 'custom':
        break;
    }
    _nameTemplateController.text = _nameTemplate;
  }

  void _updatePreview() {
    final generator = ChittiNameGenerator();
    final nextNum = _lastChittiNumber + 1;
    final variables = {
      '{number}': '$nextNum',
      '{letter}': generator.numberToLetter(nextNum),
      '{month}': 'Jan',
      '{year}': '2025',
      '{duration}': '12',
      '{prefix}': _namePrefixController.text.trim().isEmpty
          ? 'Chitti'
          : _namePrefixController.text.trim(),
    };
    setState(
      () => _previewName = generator.parseTemplate(
        template: _nameTemplate,
        variables: variables,
      ),
    );
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

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Currency',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search by code or name...',
                              hintStyle: GoogleFonts.inter(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.4),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: const Color(0xFF0D9488),
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (query) => setModalState(() {}),
                            controller:
                                _searchController, // Use a controller from the class to maintain state
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: CurrencyData.allCodes.where((c) {
                              final query = _searchController.text
                                  .toLowerCase();
                              return c.toLowerCase().contains(query) ||
                                  CurrencyData.getName(
                                    c,
                                  ).toLowerCase().contains(query);
                            }).length,
                            itemBuilder: (context, index) {
                              final filteredCodes = CurrencyData.allCodes.where(
                                (c) {
                                  final query = _searchController.text
                                      .toLowerCase();
                                  return c.toLowerCase().contains(query) ||
                                      CurrencyData.getName(
                                        c,
                                      ).toLowerCase().contains(query);
                                },
                              ).toList();

                              final code = filteredCodes[index];
                              final isSelected = _currency == code;

                              return ListTile(
                                onTap: () {
                                  setState(() => _currency = code);
                                  _saveAppSettings();
                                  Navigator.pop(context);
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: isSelected
                                    ? const Color(0xFF0D9488).withOpacity(0.05)
                                    : null,
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0D9488)
                                        : const Color(
                                            0xFF0D9488,
                                          ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      code,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF0D9488),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  CurrencyData.getName(code),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF0D9488),
                                      )
                                    : const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetCounterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Counter?'),
        content: const Text('This will reset the chitti counter to 0.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _lastChittiNumber = 0);
              _saveAppSettings();
              Navigator.pop(context);
              _updatePreview();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _namePrefixController.dispose();
    _nameTemplateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );
    }

    final initials = (_userProfile?['username'] as String?)?.isNotEmpty == true
        ? (_userProfile!['username'] as String)[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Premium Header with Profile
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 32,
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
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      if (_isOrganizer && !_isEditing)
                        Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => setState(() => _isEditing = true),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Premium Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userProfile?['username'] ?? 'John Doe',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  (_userProfile?['role'] ?? 'MEMBER')
                                      .toString()
                                      .toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Settings Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (_isEditing) ...[
                    _buildSectionTitle('Edit Profile', Icons.person_rounded),
                    const SizedBox(height: 16),
                    _buildCard([
                      _buildInputField(
                        _firstNameController,
                        'First Name',
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        _lastNameController,
                        'Last Name',
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        _phoneController,
                        'Phone Number',
                        Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ] else ...[
                    _buildSectionTitle('Appearance', Icons.palette_rounded),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildSettingTile(
                        icon: themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: 'Dark Mode',
                        subtitle: 'Optimize for night viewing',
                        trailing: Switch.adaptive(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          ),
                          activeColor: const Color(0xFF0D9488),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      'Global Settings',
                      Icons.settings_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildSettingTile(
                        icon: Icons.notifications_rounded,
                        title: 'Push Notifications',
                        subtitle: 'Stay updated on cycles',
                        trailing: Switch.adaptive(
                          value: _notificationsEnabled,
                          onChanged: (val) =>
                              setState(() => _notificationsEnabled = val),
                          activeColor: const Color(0xFF0D9488),
                        ),
                      ),
                      if (_isOrganizer) ...[
                        const Divider(height: 32),
                        _buildSettingTile(
                          icon: Icons.currency_exchange_rounded,
                          title: 'Default Currency',
                          subtitle: 'Transactional currency used',
                          trailing: InkWell(
                            onTap: _showCurrencyPicker,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0D9488,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currency,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0D9488),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: Color(0xFF0D9488),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),

                    if (_isOrganizer) ...[
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Admin Masters',
                        Icons.admin_panel_settings_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildCard([
                        _buildSettingTile(
                          icon: Icons.diamond_rounded,
                          title: 'Gold Asset Classes',
                          subtitle: 'Manage weights and types',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MastersScreen(),
                            ),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Configuration',
                        Icons.auto_awesome_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildCard([
                        _buildDropdownTile(
                          'Automation Pattern',
                          _nameFormat,
                          {
                            'numeric': 'Sequence (1, 2, 3...)',
                            'alphanumeric': 'Hybrid (A1, A2...)',
                            'alphabetic': 'Alphabet (A, B, C...)',
                            'custom': 'Custom Formula',
                          },
                          (val) {
                            setState(() {
                              _nameFormat = val!;
                              _updateDefaultTemplate(val);
                              _updatePreview();
                            });
                            _saveAppSettings();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          _namePrefixController,
                          'Identification Prefix',
                          Icons.label_rounded,
                          onChanged: (_) => _updatePreview(),
                        ),
                        if (_nameFormat == 'custom') ...[
                          const SizedBox(height: 16),
                          _buildInputField(
                            _nameTemplateController,
                            'Custom Formula',
                            Icons.code_rounded,
                            helperText:
                                'Variables: {number}, {letter}, {prefix}',
                            onChanged: (val) {
                              setState(() => _nameTemplate = val);
                              _updatePreview();
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF0D9488).withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preview Output',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _previewName.isEmpty
                                        ? 'Chitti 1'
                                        : _previewName,
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0D9488),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Seq Index',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_lastChittiNumber',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _showResetCounterDialog,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reset Sequence Counter'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ]),
                    ],

                    const SizedBox(height: 48),
                    // Action Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        onTap: () {
                          AuthService().logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: Text(
                          'Securely exit your account',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.red.withOpacity(0.6),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0D9488)),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D9488),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.outline.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    Function(String)? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        helperText: helperText,
        helperStyle: GoogleFonts.inter(fontSize: 11),
        prefixIcon: Icon(icon, color: const Color(0xFF0D9488), size: 20),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String label,
    String value,
    Map<String, String> options,
    Function(String?) onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF0D9488),
            ),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            items: options.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
