import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/note_viewmodel.dart';

class NoteEditingScreen extends StatefulWidget {
  final VoidCallback onSavePressed;
  final VoidCallback? onDeletePressed;

  const NoteEditingScreen({
    super.key,
    required this.onSavePressed,
    this.onDeletePressed,
  });

  @override
  State<NoteEditingScreen> createState() => _NoteEditingScreenState();
}

class _NoteEditingScreenState extends State<NoteEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteViewModel = context.read<NoteViewModel>();
      _titleController.text = noteViewModel.title;
      _contentController.text = noteViewModel.content;
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
                  validator:
                      (value) =>
                          value?.trim().isEmpty == true
                              ? 'Please enter a title'
                              : null,
                  textInputAction: TextInputAction.next,
                  onChanged: noteViewModel.updateTitle,
                ),
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
                    validator:
                        (value) =>
                            value?.trim().isEmpty == true
                                ? 'Please enter some content'
                                : null,
                    onChanged: noteViewModel.updateContent,
                  ),
                ),
                InkWell(
                  onTap: () => noteViewModel.selectDateTime(context),
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
                      if (noteViewModel.selectedImage != null ||
                          noteViewModel.uploadedImageUrl != null) ...[
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                noteViewModel.selectedImage != null
                                    ? Image.file(
                                      noteViewModel.selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                    : noteViewModel.uploadedImageUrl != null
                                    ? CachedNetworkImage(
                                      imageUrl: noteViewModel.uploadedImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) => const Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 50,
                                            ),
                                          ),
                                    )
                                    : const SizedBox.shrink(),
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
                                      : () => noteViewModel
                                          .selectImageFromGallery(context),
                              icon: const Icon(Icons.photo_library, size: 16),
                              label: const Text('Gallery'),
                            ),
                          ),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  noteViewModel.isLoading
                                      ? null
                                      : () => noteViewModel.takePhotoWithCamera(
                                        context,
                                      ),
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text('Camera'),
                            ),
                          ),
                        ],
                      ),
                      if (noteViewModel.selectedImage != null ||
                          noteViewModel.uploadedImageUrl != null)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed:
                                noteViewModel.isLoading
                                    ? null
                                    : () => noteViewModel.clearImage(),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Remove Image'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (noteViewModel.hasError)
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        noteViewModel.canSave && !noteViewModel.isLoading
                            ? widget.onSavePressed
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
      },
    );
  }
}
