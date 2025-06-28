import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/note.dart';
import '../note_screen.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.yellow[100],
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteScreen(note: note)),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title.isNotEmpty ? note.title : 'Untitled Note',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (note.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: note.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Row(
                    children: [
                      if (note.latitude != null && note.longitude != null) ...[
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (note.imageUrl != null) ...[
                        Icon(Icons.image, size: 16, color: Colors.grey[600]),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
