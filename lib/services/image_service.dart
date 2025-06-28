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
      debugPrint('Error picking image from gallery: $e');
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
      debugPrint(response);
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

  Future<File?> showImageSourceDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await takePhotoWithCamera();
                  if (context.mounted) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
