import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload health report (PDF, image, etc.)
  Future<String> uploadHealthReport({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final File file = File(filePath);
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      final Reference ref = _storage
          .ref()
          .child('health_reports')
          .child(userId)
          .child(uniqueFileName);

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture({
    required String userId,
    required String filePath,
  }) async {
    try {
      final File file = File(filePath);
      final Reference ref = _storage
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Pick file from device
  Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        dialogTitle: dialogTitle ?? 'Select Health Report',
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get list of user's health reports
  Future<List<Map<String, dynamic>>> getUserHealthReports(String userId) async {
    try {
      final ListResult result = await _storage
          .ref()
          .child('health_reports')
          .child(userId)
          .list();

      final List<Map<String, dynamic>> reports = [];

      for (final Reference ref in result.items) {
        final String downloadUrl = await ref.getDownloadURL();
        final FullMetadata metadata = await ref.getMetadata();

        reports.add({
          'name': ref.name,
          'url': downloadUrl,
          'size': metadata.size,
          'updated': metadata.updated,
          'contentType': metadata.contentType,
        });
      }

      return reports;
    } catch (e) {
      throw Exception('Failed to get health reports: $e');
    }
  }

  // Get file size in readable format
  String getFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
  }

  // Check if file type is supported
  bool isSupportedFileType(String fileName) {
    final List<String> supportedTypes = [
      'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'
    ];
    final String extension = fileName.split('.').last.toLowerCase();
    return supportedTypes.contains(extension);
  }

  // Get file icon based on type
  String getFileIcon(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'doc':
      case 'docx':
        return '📝';
      default:
        return '📎';
    }
  }
}