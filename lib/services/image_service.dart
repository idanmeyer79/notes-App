import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      ('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImageToSupabase(File imageFile) async {
    try {
      final String fileName = _generateUniqueFileName(imageFile.path);

      final response = await _supabase.storage
          .from('images')
          .upload(fileName, imageFile);
      (response);
      if (response.isNotEmpty) {
        final String publicUrl = _supabase.storage
            .from('images')
            .getPublicUrl(fileName);
        return publicUrl;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String _generateUniqueFileName(String originalPath) {
    final String extension = originalPath.split('.').last;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return 'note_image_${userId}_$timestamp.$extension';
  }

  Future<bool> deleteImageFromSupabase(String imageUrl) async {
    try {
      final Uri uri = Uri.parse(imageUrl);
      final String fileName = uri.pathSegments.last;

      await _supabase.storage.from('images').remove([fileName]);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<File?> selectImageFromGallery(BuildContext context) async {
    try {
      final File? image = await pickImageFromGallery();
      if (image != null) {
        return image;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to select image: $e')));
      }
      return null;
    }
  }

  Future<File?> takePhotoWithCameraAndHandleErrors(BuildContext context) async {
    try {
      final File? photo = await takePhotoWithCamera();
      if (photo != null) {
        return photo;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to take photo: $e')));
      }
      return null;
    }
  }
}
