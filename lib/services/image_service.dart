import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

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
      debugPrint('Error taking photo with camera: $e');
      return null;
    }
  }

  /// Upload image to Supabase storage and return the public URL
  Future<String?> uploadImageToSupabase(File imageFile) async {
    try {
      // Generate a unique filename
      final String fileName = _generateUniqueFileName(imageFile.path);

      // Upload the file to Supabase storage
      final response = await _supabase.storage
          .from('images') // Replace with your bucket name
          .upload(fileName, imageFile);

      if (response.isNotEmpty) {
        // Get the public URL
        final String publicUrl = _supabase.storage
            .from('images') // Replace with your bucket name
            .getPublicUrl(fileName);

        debugPrint('Image uploaded successfully: $publicUrl');
        return publicUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading image to Supabase: $e');
      return null;
    }
  }

  /// Generate a unique filename for the uploaded image
  String _generateUniqueFileName(String originalPath) {
    final String extension = originalPath.split('.').last;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String randomString = _generateRandomString(8);
    return 'note_image_${timestamp}_$randomString.$extension';
  }

  /// Generate a random string of specified length
  String _generateRandomString(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Delete image from Supabase storage
  Future<bool> deleteImageFromSupabase(String imageUrl) async {
    try {
      // Extract filename from URL
      final Uri uri = Uri.parse(imageUrl);
      final String fileName = uri.pathSegments.last;

      await _supabase.storage
          .from('images') // Replace with your bucket name
          .remove([fileName]);

      debugPrint('Image deleted successfully: $fileName');
      return true;
    } catch (e) {
      debugPrint('Error deleting image from Supabase: $e');
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
