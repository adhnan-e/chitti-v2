import 'package:file_picker/file_picker.dart';

abstract class IStorageRepository {
  Future<void> ensureAuthenticated();
  Future<Map<String, dynamic>> uploadDocument({
    required String userId,
    required PlatformFile file,
  });
  Future<List<Map<String, dynamic>>> uploadDocuments({
    required String userId,
    required List<PlatformFile> files,
  });
}
