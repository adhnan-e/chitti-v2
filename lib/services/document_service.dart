import 'package:file_picker/file_picker.dart';
import 'package:chitt/core/di/service_locator.dart';
import 'package:chitt/core/domain/repositories/i_storage_repository.dart';
import 'package:chitt/services/database_service.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  IStorageRepository get _repo => getIt<IStorageRepository>();

  Future<List<PlatformFile>> pickDocuments({bool allowMultiple = true}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) return [];
      return result.files.where((f) => f.path != null).toList();
    } catch (e) {
      print('Error picking documents: $e');
      return [];
    }
  }

  Future<void> ensureAuthenticated() => _repo.ensureAuthenticated();

  Future<Map<String, dynamic>> uploadDocument({
    required String userId,
    required PlatformFile file,
  }) => _repo.uploadDocument(userId: userId, file: file);

  Future<List<Map<String, dynamic>>> uploadDocuments({
    required String userId,
    required List<PlatformFile> files,
  }) => _repo.uploadDocuments(userId: userId, files: files);

  Future<Map<String, dynamic>?> addDocumentToMember({
    required String userId,
    required List<Map<String, dynamic>> existingDocuments,
    required Map<String, dynamic> memberData,
  }) async {
    final files = await pickDocuments(allowMultiple: false);
    if (files.isEmpty) return null;

    final file = files.first;
    final docData = await uploadDocument(userId: userId, file: file);
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

  List<Map<String, dynamic>> getDocumentsList(dynamic documents) {
    if (documents == null || documents is! List) return [];
    return documents.map((doc) => Map<String, dynamic>.from(doc as Map)).toList();
  }
}
