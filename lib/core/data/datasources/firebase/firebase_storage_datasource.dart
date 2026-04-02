import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chitt/core/domain/repositories/i_storage_repository.dart';

class FirebaseStorageDatasource implements IStorageRepository {
  @override
  Future<void> ensureAuthenticated() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  @override
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
