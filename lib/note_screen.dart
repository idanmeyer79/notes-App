import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'models/note.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'services/image_service.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;

  const NoteScreen({super.key, this.note});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    // Initialize the NoteViewModel with the note data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = context.read<HomeViewModel>();
      final noteViewModel = context.read<NoteViewModel>();
      noteViewModel.initialize(widget.note, homeViewModel.userName);

      // Pre-fill the form if editing an existing note
      if (widget.note != null) {
        _titleController.text = widget.note!.title;
        _contentController.text = widget.note!.content;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(noteViewModel.isEditing ? 'Edit Note' : 'New Note'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              if (noteViewModel.isEditing)
                IconButton(
                  onPressed:
                      noteViewModel.isLoading
                          ? null
                          : () => _showDeleteDialog(context, noteViewModel),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete note',
                ),
            ],
          ),
          body: _buildBody(noteViewModel),
        );
      },
    );
  }

  Widget _buildBody(NoteViewModel noteViewModel) {
    if (noteViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              onChanged: noteViewModel.updateTitle,
            ),

            // Content field with fixed height
            SizedBox(
              height: 200,
              child: TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter note content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
                onChanged: noteViewModel.updateContent,
              ),
            ),

            // Date picker
            InkWell(
              onTap: () => _selectDate(context, noteViewModel),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy - HH:mm',
                            ).format(noteViewModel.selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),

            // Image upload section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.image, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Image',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (noteViewModel.selectedImage != null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          noteViewModel.selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              noteViewModel.isLoading
                                  ? null
                                  : () => _pickImage(context, noteViewModel),
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: const Text('Gallery'),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              noteViewModel.isLoading
                                  ? null
                                  : () => _takePhoto(context, noteViewModel),
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                  if (noteViewModel.selectedImage != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed:
                            noteViewModel.isLoading
                                ? null
                                : () {
                                  noteViewModel.setSelectedImage(null);
                                },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Remove Image'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (noteViewModel.hasError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  noteViewModel.errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    noteViewModel.canSave && !noteViewModel.isLoading
                        ? _saveNote
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    noteViewModel.isLoading
                        ? const Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            Text('Saving...'),
                          ],
                        )
                        : Text(
                          noteViewModel.isEditing
                              ? 'Update Note'
                              : 'Create Note',
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    NoteViewModel noteViewModel,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: noteViewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(noteViewModel.selectedDate),
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        noteViewModel.updateSelectedDate(combinedDateTime);
      }
    }
  }

  Future<void> _pickImage(
    BuildContext context,
    NoteViewModel noteViewModel,
  ) async {
    final File? image = await _imageService.pickImageFromGallery();
    if (image != null) {
      noteViewModel.setSelectedImage(image);
    }
  }

  Future<void> _takePhoto(
    BuildContext context,
    NoteViewModel noteViewModel,
  ) async {
    final File? photo = await _imageService.takePhotoWithCamera();
    if (photo != null) {
      noteViewModel.setSelectedImage(photo);
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final noteViewModel = context.read<NoteViewModel>();
    final success = await noteViewModel.saveNote();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            noteViewModel.isEditing ? 'Note updated!' : 'Note created!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the home screen notes
      context.read<HomeViewModel>().refreshNotes();
      Navigator.of(context).pop();
    }
  }

  void _showDeleteDialog(BuildContext context, NoteViewModel noteViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await noteViewModel.deleteNote();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<HomeViewModel>().refreshNotes();
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
