import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../services/date_time_service.dart';
import 'base_viewmodel.dart';

class NoteViewModel extends BaseViewModel {
  final NoteService _noteService = NoteService();
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();
  final DateTimeService _dateTimeService = DateTimeService();

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
      _selectedImage = null;
    } else {
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
      if (!isEditing) {
        _uploadedImageUrl = null;
      }
    } else {
      _uploadedImageUrl = null;
    }
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _uploadedImageUrl = null;
    notifyListeners();
  }

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

    _note = await _noteService.createNote(
      title: _title.trim(),
      content: _content.trim(),
      userId: _userId,
      latitude: _latitude,
      longitude: _longitude,
      createdAt: _selectedDate,
      imageUrl: _uploadedImageUrl,
    );

    _selectedImage = null;
    notifyListeners();

    return true;
  }

  Future<bool> _updateNote() async {
    if (_note == null) return false;

    if (_note!.imageUrl != null &&
        _note!.imageUrl!.isNotEmpty &&
        _uploadedImageUrl == null) {
      ('Deleting old image from Supabase: ${_note!.imageUrl}');
      await _imageService.deleteImageFromSupabase(_note!.imageUrl!);
    }

    String? finalImageUrl = _uploadedImageUrl;
    ('Final imageUrl: $finalImageUrl');

    DateTime? updatedCreatedAt;
    if (_selectedDate != _note!.createdAt) {
      updatedCreatedAt = _selectedDate;
      ('Date changed from ${_note!.createdAt} to $updatedCreatedAt');
    }

    await _noteService.updateNote(
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

    _selectedImage = null;
    notifyListeners();

    return true;
  }

  Future<bool> deleteNote() async {
    if (_note == null) return false;

    return await executeAsync(() async {
      if (_note!.imageUrl != null && _note!.imageUrl!.isNotEmpty) {
        await _imageService.deleteImageFromSupabase(_note!.imageUrl!);
      }

      await _noteService.deleteNote(_note!.id, _userId);
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

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? selectedDateTime = await _dateTimeService.selectDateTime(
      context,
      initialDate: _selectedDate,
    );

    if (selectedDateTime != null) {
      updateSelectedDate(selectedDateTime);
    }
  }

  Future<void> selectImageFromGallery(BuildContext context) async {
    final File? image = await _imageService.selectImageFromGallery(context);
    if (image != null) {
      setSelectedImage(image);
    }
  }

  Future<void> takePhotoWithCamera(BuildContext context) async {
    final File? photo = await _imageService.takePhotoWithCameraAndHandleErrors(
      context,
    );
    if (photo != null) {
      setSelectedImage(photo);
    }
  }
}
