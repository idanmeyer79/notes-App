import 'dart:io';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import 'base_viewmodel.dart';

class NoteViewModel extends BaseViewModel {
  final NoteRepository _noteRepository = NoteRepository();
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();

  Note? _note;
  String _title = '';
  String _content = '';
  String _userId = 'User';
  double? _latitude;
  double? _longitude;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String? _uploadedImageUrl;

  Note? get note => _note;
  String get title => _title;
  String get content => _content;
  bool get isEditing => _note != null;
  bool get canSave => _title.trim().isNotEmpty && _content.trim().isNotEmpty;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  DateTime get selectedDate => _selectedDate;
  File? get selectedImage => _selectedImage;
  String? get uploadedImageUrl => _uploadedImageUrl;

  void initialize(Note? note, String userId) {
    _note = note;
    _userId = userId;

    if (note != null) {
      _title = note.title;
      _content = note.content;
      _latitude = note.latitude;
      _longitude = note.longitude;
      _selectedDate = note.createdAt;
      _uploadedImageUrl = note.imageUrl;
      _selectedImage = null; // Clear any previously selected image
    } else {
      // For new notes, clear everything
      _title = '';
      _content = '';
      _latitude = null;
      _longitude = null;
      _selectedDate = DateTime.now();
      _uploadedImageUrl = null;
      _selectedImage = null;
    }

    notifyListeners();
  }

  void updateTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void updateContent(String content) {
    _content = content;
    notifyListeners();
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    if (image == null) {
      // If clearing selected image, also clear uploaded URL for new notes
      if (!isEditing) {
        _uploadedImageUrl = null;
      }
    } else {
      // Reset uploaded URL when new image is selected
      _uploadedImageUrl = null;
    }
    notifyListeners();
  }

  /// Clear both selected image and uploaded image URL
  void clearImage() {
    _selectedImage = null;
    _uploadedImageUrl =
        null; // This will be saved as null when updating existing notes
    notifyListeners();
  }

  /// Upload the selected image to Supabase storage
  Future<bool> uploadSelectedImage() async {
    if (_selectedImage == null) return true;

    return await executeAsync(() async {
      try {
        final String? imageUrl = await _imageService.uploadImageToSupabase(
          _selectedImage!,
        );
        if (imageUrl != null) {
          _uploadedImageUrl = imageUrl;
          notifyListeners();
          return true;
        } else {
          setError('Failed to upload image');
          return false;
        }
      } catch (e) {
        setError('Error uploading image: $e');
        return false;
      }
    });
  }

  Future<void> captureLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        notifyListeners();
      }
    } catch (e) {
      _latitude = null;
      _longitude = null;
    }
  }

  Future<bool> saveNote() async {
    if (!canSave) {
      setError('Title and content are required');
      return false;
    }

    return await executeAsync(() async {
      // Upload image first if there's a selected image
      if (_selectedImage != null) {
        final uploadSuccess = await uploadSelectedImage();
        if (!uploadSuccess) {
          return false;
        }
      }

      if (isEditing) {
        return await _updateNote();
      } else {
        return await _createNote();
      }
    });
  }

  Future<bool> _createNote() async {
    await captureLocation();

    _note = await _noteRepository.createNote(
      title: _title.trim(),
      content: _content.trim(),
      userId: _userId,
      latitude: _latitude,
      longitude: _longitude,
      createdAt: _selectedDate,
      imageUrl: _uploadedImageUrl,
    );

    // Clear the selected image after successful creation
    _selectedImage = null;
    notifyListeners();

    return true;
  }

  Future<bool> _updateNote() async {
    if (_note == null) return false;

    // If we had an image before but now we don't, delete it from Supabase
    if (_note!.imageUrl != null &&
        _note!.imageUrl!.isNotEmpty &&
        _uploadedImageUrl == null) {
      print('Deleting old image from Supabase: ${_note!.imageUrl}');
      await _imageService.deleteImageFromSupabase(_note!.imageUrl!);
    }

    // Determine the final imageUrl value
    // At this point, if there was a selected image, it has been uploaded and _uploadedImageUrl is set
    String? finalImageUrl =
        _uploadedImageUrl; // This will be null if no image or image was removed
    print('Final imageUrl: $finalImageUrl');

    // Check if the date has changed
    DateTime? updatedCreatedAt;
    if (_selectedDate != _note!.createdAt) {
      updatedCreatedAt = _selectedDate;
      print('Date changed from ${_note!.createdAt} to $updatedCreatedAt');
    }

    await _noteRepository.updateNote(
      noteId: _note!.id,
      title: _title.trim(),
      content: _content.trim(),
      userId: _userId,
      latitude: _latitude ?? _note!.latitude,
      longitude: _longitude ?? _note!.longitude,
      imageUrl: finalImageUrl,
      createdAt: updatedCreatedAt,
    );

    _note = _note!.copyWith(
      title: _title.trim(),
      content: _content.trim(),
      updatedAt: DateTime.now(),
      latitude: _latitude ?? _note!.latitude,
      longitude: _longitude ?? _note!.longitude,
      imageUrl: finalImageUrl,
      createdAt: updatedCreatedAt ?? _note!.createdAt,
    );

    // Clear the selected image after successful update
    _selectedImage = null;
    notifyListeners();

    return true;
  }

  Future<bool> deleteNote() async {
    if (_note == null) return false;

    return await executeAsync(() async {
      // Delete the image from Supabase if it exists
      if (_note!.imageUrl != null && _note!.imageUrl!.isNotEmpty) {
        await _imageService.deleteImageFromSupabase(_note!.imageUrl!);
      }

      await _noteRepository.deleteNote(_note!.id, _userId);
      return true;
    });
  }

  void reset() {
    _title = '';
    _content = '';
    _note = null;
    _latitude = null;
    _longitude = null;
    _selectedDate = DateTime.now();
    _selectedImage = null;
    _uploadedImageUrl = null;
    clearError();
    setState(ViewState.idle);
  }
}
