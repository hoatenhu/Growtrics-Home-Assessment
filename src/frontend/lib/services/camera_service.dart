import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Take photo from camera
  Future<File?> takePhoto() async {
    // Check camera permission
    PermissionStatus permission = await Permission.camera.request();
    
    if (permission != PermissionStatus.granted) {
      throw CameraException('Camera permission denied');
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      throw CameraException('Failed to take photo: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    // Check photo library permission
    PermissionStatus permission = await Permission.photos.request();
    
    if (permission != PermissionStatus.granted) {
      throw CameraException('Photo library permission denied');
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      throw CameraException('Failed to pick image: $e');
    }
  }

  /// Pick file (PDF or image) using file picker
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      
      return null;
    } catch (e) {
      throw CameraException('Failed to pick file: $e');
    }
  }

  /// Check if the file is a supported format
  bool isSupportedFile(File file) {
    String extension = file.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'pdf'].contains(extension);
  }

  /// Check if the file is an image
  bool isImageFile(File file) {
    String extension = file.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  /// Check if the file is a PDF
  bool isPdfFile(File file) {
    String extension = file.path.toLowerCase().split('.').last;
    return extension == 'pdf';
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    int bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate file size (max 10MB)
  bool validateFileSize(File file, {double maxSizeMB = 10.0}) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }

  /// Get permission status for camera
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// Get permission status for photos
  Future<PermissionStatus> getPhotosPermissionStatus() async {
    return await Permission.photos.status;
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Request photos permission
  Future<PermissionStatus> requestPhotosPermission() async {
    return await Permission.photos.request();
  }
}

class CameraException implements Exception {
  final String message;
  
  CameraException(this.message);
  
  @override
  String toString() => message;
}
