import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/note_viewmodel.dart';

class NoteReadingScreen extends StatelessWidget {
  final VoidCallback onEditPressed;

  const NoteReadingScreen({super.key, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteViewModel, child) {
        if (noteViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy - HH:mm',
                    ).format(noteViewModel.selectedDate),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                noteViewModel.title.isNotEmpty
                    ? noteViewModel.title
                    : 'Untitled Note',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                noteViewModel.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),

              if (noteViewModel.uploadedImageUrl != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: noteViewModel.uploadedImageUrl!,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
