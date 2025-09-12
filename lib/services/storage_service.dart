import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      String filePath = '${AppConstants.profileImagesPath}/$userId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  // Upload course group image
  Future<String> uploadCourseGroupImage(String courseGroupId, File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      String filePath = '${AppConstants.courseGroupImagesPath}/$courseGroupId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload course group image: ${e.toString()}');
    }
  }

  // Upload task attachment
  Future<String> uploadTaskAttachment(String taskId, File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      String filePath = '${AppConstants.taskAttachmentsPath}/$taskId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload task attachment: ${e.toString()}');
    }
  }

  // Upload submission file
  Future<String> uploadSubmissionFile(String submissionId, File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      String filePath = '${AppConstants.submissionFilesPath}/$submissionId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload submission file: ${e.toString()}');
    }
  }

  // Upload multiple files
  Future<List<String>> uploadMultipleFiles(String folderPath, List<File> files) async {
    try {
      List<String> downloadUrls = [];
      
      for (File file in files) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${files.indexOf(file)}${path.extension(file.path)}';
        String filePath = '$folderPath/$fileName';
        
        Reference ref = _storage.ref().child(filePath);
        UploadTask uploadTask = ref.putFile(file);
        
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: ${e.toString()}');
    }
  }

  // Delete file
  Future<void> deleteFile(String downloadUrl) async {
    try {
      Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      Reference ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: ${e.toString()}');
    }
  }

  // Validate file type
  bool isValidFileType(String fileName, List<String> allowedTypes) {
    String extension = path.extension(fileName).toLowerCase().substring(1);
    return allowedTypes.contains(extension);
  }

  // Validate file size
  bool isValidFileSize(int fileSizeBytes) {
    return fileSizeBytes <= AppConstants.maxFileSize;
  }

  // Get file size in MB
  double getFileSizeInMB(int fileSizeBytes) {
    return fileSizeBytes / (1024 * 1024);
  }

  // Get file extension
  String getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase().substring(1);
  }

  // Check if file is image
  bool isImageFile(String fileName) {
    String extension = getFileExtension(fileName);
    return AppConstants.allowedImageTypes.contains(extension);
  }

  // Check if file is document
  bool isDocumentFile(String fileName) {
    String extension = getFileExtension(fileName);
    return AppConstants.allowedDocumentTypes.contains(extension);
  }

  // Check if file is video
  bool isVideoFile(String fileName) {
    String extension = getFileExtension(fileName);
    return AppConstants.allowedVideoTypes.contains(extension);
  }

  // Check if file is audio
  bool isAudioFile(String fileName) {
    String extension = getFileExtension(fileName);
    return AppConstants.allowedAudioTypes.contains(extension);
  }
}
