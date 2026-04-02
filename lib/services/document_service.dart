import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chitt/services/database_service.dart';

/// Shared service for document management (upload, delete, etc.)
class DocumentService {
  // Singleton
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  /// Pick documents using file picker
  /// Returns list of picked files or empty list if cancelled
  Future<List<PlatformFile>> pickDocuments({bool allowMultiple = true}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      return result.files.where((f) => f.path != null).toList();
    } catch (e) {
      print('Error picking documents: $e');
      return [];
    }
  }

  /// Ensure user is authenticated for Firebase Storage access
  Future<void> ensureAuthenticated() async {
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        print('Signed in anonymously for document upload');
      } catch (e) {
        print('Error signing in anonymously: $e');
        rethrow;
      }
    }
  }

  /// Upload a single document to Firebase Storage
  /// Returns document metadata map with url, name, type, uploadedAt
  Future<Map<String, dynamic>> uploadDocument({
    required String userId,
    required PlatformFile file,
  }) async {
    await ensureAuthenticated();

    final ref = FirebaseStorage.instance.ref().child(
      'documents/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );

    await ref.putFile(File(file.path!));
    final url = await ref.getDownloadURL();

    return {
      'name': file.name,
      'url': url,
      'type': file.extension ?? '',
      'uploadedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Upload multiple documents
  /// Returns list of document metadata maps
  Future<List<Map<String, dynamic>>> uploadDocuments({
    required String userId,
    required List<PlatformFile> files,
  }) async {
    final List<Map<String, dynamic>> uploadedDocs = [];

    await ensureAuthenticated();

    for (var file in files) {
      if (file.path != null) {
        final docData = await uploadDocument(userId: userId, file: file);
        uploadedDocs.add(docData);
      }
    }

    return uploadedDocs;
  }

  /// Add a document to an existing member
  /// Handles the full flow: pick, upload, update database
  Future<Map<String, dynamic>?> addDocumentToMember({
    required String userId,
    required List<Map<String, dynamic>> existingDocuments,
    required Map<String, dynamic> memberData,
  }) async {
    // Pick file
    final files = await pickDocuments(allowMultiple: false);
    if (files.isEmpty) return null;

    final file = files.first;

    // Upload
    final docData = await uploadDocument(userId: userId, file: file);

    // Update member in database
    final newDocsList = [...existingDocuments, docData];

    final firstName = memberData['firstName'] ?? '';
    final lastName = memberData['lastname'] ?? '';

    await DatabaseService().updateUser(
      userId: userId,
      name: '$firstName $lastName'.trim(),
      phone: memberData['phone'] ?? '',
      email: memberData['email'],
      address: memberData['address'],
      documents: newDocsList,
    );

    return docData;
  }

  /// Get properly typed documents list from member data
  List<Map<String, dynamic>> getDocumentsList(dynamic documents) {
    if (documents == null) return [];
    if (documents is! List) return [];

    return documents.map((doc) {
      return Map<String, dynamic>.from(doc as Map);
    }).toList();
  }
}
