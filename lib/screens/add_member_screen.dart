import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/services/database_service.dart';
import 'package:chitt/services/document_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime _joinedDate = DateTime.now();
  bool _giveAppAccess = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Map<String, dynamic>? _editingMember;
  bool get _isEditing => _editingMember != null;

  // File Upload State
  XFile? _newProfileImage;
  String? _currentPhotoUrl;

  // Documents State
  List<Map<String, dynamic>> _existingDocuments = [];
  final List<PlatformFile> _newDocuments = [];
  bool _isUploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null &&
        args is Map<String, dynamic> &&
        _editingMember == null) {
      _editingMember = args;
      _initializeFields();
    }
  }

  void _initializeFields() {
    if (_editingMember == null) return;
    final firstName = _editingMember!['firstName'] ?? '';
    final lastName = _editingMember!['lastname'] ?? '';
    _nameController.text = '$firstName $lastName'.trim();
    _phoneController.text = _editingMember!['phone'] ?? '';
    _emailController.text = _editingMember!['email'] ?? '';
    _addressController.text = _editingMember!['address'] ?? '';
    _currentPhotoUrl = _editingMember!['photoUrl'];
    if (_editingMember!['documents'] != null) {
      final rawDocs = _editingMember!['documents'] as List;
      _existingDocuments = rawDocs.map((doc) {
        return Map<String, dynamic>.from(doc as Map);
      }).toList();
    }
    _giveAppAccess = _editingMember!['hasAppAccess'] == true;
    if (_giveAppAccess) {
      _usernameController.text = _editingMember!['username'] ?? '';
      _passwordController.text = _editingMember!['password'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _newProfileImage = image);
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final files = await DocumentService().pickDocuments(allowMultiple: true);
      if (files.isNotEmpty) {
        setState(() {
          _newDocuments.addAll(files);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking documents: $e', isError: true);
    }
  }

  Future<Map<String, dynamic>> _uploadFiles(String userId) async {
    // Ensure we are authenticated for Storage access
    await DocumentService().ensureAuthenticated();

    String? photoUrl = _currentPhotoUrl;
    List<Map<String, dynamic>> finalDocs = [..._existingDocuments];

    try {
      // Upload Profile Photo
      if (_newProfileImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(File(_newProfileImage!.path));
        photoUrl = await ref.getDownloadURL();
      }

      // Upload New Documents using DocumentService
      if (_newDocuments.isNotEmpty) {
        final uploadedDocs = await DocumentService().uploadDocuments(
          userId: userId,
          files: _newDocuments,
        );
        finalDocs.addAll(uploadedDocs);
      }
    } catch (e) {
      print('Error uploading files: $e');
      rethrow;
    }

    return {'photoUrl': photoUrl, 'documents': finalDocs};
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_giveAppAccess &&
        (_usernameController.text.isEmpty ||
            _passwordController.text.isEmpty)) {
      _showSnackBar(
        'Username and Password required for App Access',
        isError: true,
      );
      return;
    }

    final phone = _phoneController.text.trim();

    // Check for duplicates if NOT editing
    if (!_isEditing) {
      setState(() => _isLoading = true);
      final existingMember = await DatabaseService().findMemberByPhone(phone);
      setState(() => _isLoading = false);

      if (existingMember != null) {
        final isDeleted = existingMember['isDeleted'] == true;
        if (isDeleted) {
          final shouldRestore = await _showRestoreComparisonDialog(
            existingMember,
          );
          if (shouldRestore == null) return; // Cancelled

          if (shouldRestore) {
            // Restore and Update
            setState(() => _isLoading = true);
            try {
              await DatabaseService().restoreMember(existingMember['id']);
              // Proceed to update with new info
              _editingMember = existingMember; // Treat as editing now
            } catch (e) {
              _showSnackBar('Error restoring member: $e', isError: true);
              setState(() => _isLoading = false);
              return;
            }
          } else {
            // User chose to create new anyway.
            // NOTE: This might cause issues if phone number is supposed to be unique.
            // But we will follow user request to "create new".
          }
        } else {
          _showSnackBar(
            'A member with this phone number already exists.',
            isError: true,
          );
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
    });

    try {
      final userId = _isEditing
          ? _editingMember!['id']
          : 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final uploadData = await _uploadFiles(userId);
      final photoUrl = uploadData['photoUrl'];
      final documents = uploadData['documents'] as List<Map<String, dynamic>>;

      if (_isEditing) {
        await DatabaseService().updateUser(
          userId: _editingMember!['id'],
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          needsAppAccess: _giveAppAccess,
          username: _giveAppAccess ? _usernameController.text.trim() : null,
          password: _giveAppAccess ? _passwordController.text.trim() : null,
          photoUrl: photoUrl,
          documents: documents,
        );
        _showSnackBar('Member updated and restored successfully!');
      } else {
        await DatabaseService().createUser(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          username: _giveAppAccess ? _usernameController.text.trim() : null,
          password: _giveAppAccess ? _passwordController.text.trim() : null,
          needsAppAccess: _giveAppAccess,
          photoUrl: photoUrl,
          documents: documents,
        );
        _showSnackBar('Member added successfully!');
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  Future<bool?> _showRestoreComparisonDialog(
    Map<String, dynamic> existing,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final existingName =
        '${existing['firstName'] ?? ''} ${existing['lastname'] ?? ''}'.trim();
    final newName = _nameController.text.trim();

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Existing Member Found',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A deleted member with the same phone number was found. Would you like to restore them or create a new entry?',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildComparisonTable(existingName, newName, existing),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel', style: TextStyle(color: colorScheme.outline)),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
            child: const Text('Create New'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore & Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
    String existingName,
    String newName,
    Map<String, dynamic> existing,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildComparisonRow(
            'Field',
            'Existing (Deleted)',
            'New Entry',
            isHeader: true,
          ),
          const Divider(height: 1),
          _buildComparisonRow('Name', existingName, newName),
          const Divider(height: 1),
          _buildComparisonRow(
            'Email',
            existing['email'] ?? 'N/A',
            _emailController.text.isEmpty ? 'N/A' : _emailController.text,
          ),
          const Divider(height: 1),
          _buildComparisonRow(
            'Address',
            existing['address'] ?? 'N/A',
            _addressController.text.isEmpty ? 'N/A' : _addressController.text,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String field,
    String oldVal,
    String newVal, {
    bool isHeader = false,
  }) {
    final style = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(field, style: style)),
          Expanded(
            flex: 3,
            child: Text(oldVal, style: style, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Text(
              newVal,
              style: style.copyWith(color: isHeader ? null : Colors.blue),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isEditing ? 'Edit Member' : 'Add New Member',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile Photo Section
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: _newProfileImage != null
                                ? FileImage(File(_newProfileImage!.path))
                                : (_currentPhotoUrl != null
                                          ? NetworkImage(_currentPhotoUrl!)
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_newProfileImage == null &&
                                    _currentPhotoUrl == null)
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey.shade400,
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload photo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Required Section
                      _buildSectionHeader(
                        'Required Information',
                        Icons.info_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Phone is required' : null,
                      ),

                      const SizedBox(height: 32),

                      // Optional Section
                      _buildSectionHeader(
                        'Optional Information',
                        Icons.add_circle_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _joinedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _joinedDate = date);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: const Color(0xFF0D9488),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Joined Date',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_joinedDate.day}/${_joinedDate.month}/${_joinedDate.year}',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Documents Section
                      _buildSectionHeader('Documents', Icons.folder_open),
                      const SizedBox(height: 16),
                      // Existing Docs
                      ..._existingDocuments.map(
                        (doc) => _buildDocItem(
                          name: doc['name'] ?? 'Document',
                          isExisting: true,
                          onDelete: () {
                            setState(() {
                              _existingDocuments.remove(doc);
                            });
                          },
                        ),
                      ),
                      // New Docs
                      ..._newDocuments.map(
                        (doc) => _buildDocItem(
                          name: doc.name,
                          isExisting: false,
                          onDelete: () {
                            setState(() {
                              _newDocuments.remove(doc);
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickDocuments,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Document'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D9488),
                          side: const BorderSide(color: Color(0xFF0D9488)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Access Section
                      _buildSectionHeader('App Access', Icons.lock_outline),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0D9488).withOpacity(0.08),
                              const Color(0xFF10B981).withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF0D9488).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0D9488,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.smartphone,
                                    color: Color(0xFF0D9488),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Allow Login',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Member can access app with credentials',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _giveAppAccess,
                                  onChanged: (val) =>
                                      setState(() => _giveAppAccess = val),
                                  activeColor: const Color(0xFF0D9488),
                                ),
                              ],
                            ),
                            if (_giveAppAccess) ...[
                              const SizedBox(height: 20),
                              Divider(
                                color: const Color(0xFF0D9488).withOpacity(0.2),
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                controller: _usernameController,
                                label: 'Username',
                                icon: Icons.alternate_email,
                                validator: (v) =>
                                    _giveAppAccess && (v?.isEmpty == true)
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: colorScheme.outline,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (v) =>
                                    _giveAppAccess && (v?.isEmpty == true)
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF0D9488,
                    ).withOpacity(0.5),
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
                            Icon(
                              _isEditing ? Icons.save : Icons.person_add,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isEditing ? 'Update Member' : 'Save Member',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D9488),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDocItem({
    required String name,
    required bool isExisting,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
          if (isExisting)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Saved',
                style: TextStyle(fontSize: 10, color: Color(0xFF10B981)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
