import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoService {
  static const String _photoKey = 'local_profile_photo_path';
  static final ValueNotifier<String?> photoNotifier = ValueNotifier<String?>(null);

  /// Initializes and loads the persisted profile photo path
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_photoKey);
    if (path != null && File(path).existsSync()) {
      photoNotifier.value = path;
    } else {
      photoNotifier.value = null;
    }
  }

  /// Opens gallery, lets user pick an image, copies it to local app directory, and saves path
  static Future<String?> pickAndSavePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      // Delete old photo file if it exists to avoid accumulating files
      final prefs = await SharedPreferences.getInstance();
      final oldPath = prefs.getString(_photoKey);
      if (oldPath != null && oldPath != savedImage.path) {
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          try {
            await oldFile.delete();
          } catch (_) {}
        }
      }

      await prefs.setString(_photoKey, savedImage.path);
      photoNotifier.value = savedImage.path;
      return savedImage.path;
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
      return null;
    }
  }

  /// Removes the stored local profile photo
  static Future<void> removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_photoKey);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      await prefs.remove(_photoKey);
    }
    photoNotifier.value = null;
  }
}
