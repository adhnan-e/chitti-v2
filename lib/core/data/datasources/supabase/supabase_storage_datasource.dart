import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chitt/core/domain/repositories/i_storage_repository.dart';

class SupabaseStorageDatasource implements IStorageRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> ensureAuthenticated() async {
  }

  @override
  Future<Map<String, dynamic>> uploadDocument({
    required String userId,
    required PlatformFile file,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'documents/$userId/$fileName';

    await _client.storage.from('app_documents').upload(
          path,
          File(file.path!),
        );

    final String url = _client.storage.from('app_documents').getPublicUrl(path);

    return {
      'name': file.name,
      'url': url,
      'type': file.extension ?? '',
      'uploadedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> uploadDocuments({
    required String userId,
    required List<PlatformFile> files,
  }) async {
    final List<Map<String, dynamic>> uploadedDocs = [];
    for (var file in files) {
      if (file.path != null) {
        final docData = await uploadDocument(userId: userId, file: file);
        uploadedDocs.add(docData);
      }
    }
    return uploadedDocs;
  }
}
