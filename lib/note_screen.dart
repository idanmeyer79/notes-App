import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/note.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'pages/note_reading_screen.dart';
import 'pages/note_editing_screen.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;

  const NoteScreen({super.key, this.note});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool _isReadingMode = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final noteViewModel = context.read<NoteViewModel>();
      final currentUserId = authViewModel.currentUser?.uid ?? '';
      noteViewModel.initialize(widget.note, currentUserId);

      _isReadingMode = widget.note != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(noteViewModel)),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading:
                _isReadingMode && noteViewModel.isEditing
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                    : null,
            actions: _buildAppBarActions(noteViewModel),
          ),
          body:
              _isReadingMode
                  ? NoteReadingScreen(onEditPressed: _switchToEditMode)
                  : NoteEditingScreen(
                    onSavePressed: _saveNote,
                    onDeletePressed:
                        noteViewModel.isEditing
                            ? () => _showDeleteDialog(context, noteViewModel)
                            : null,
                  ),
        );
      },
    );
  }

  String _getAppBarTitle(NoteViewModel noteViewModel) {
    if (noteViewModel.isEditing) {
      return _isReadingMode ? 'View Note' : 'Edit Note';
    } else {
      return 'New Note';
    }
  }

  List<Widget> _buildAppBarActions(NoteViewModel noteViewModel) {
    if (noteViewModel.isEditing) {
      if (_isReadingMode) {
        return [
          IconButton(
            onPressed: () => _switchToEditMode(),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit note',
          ),
        ];
      } else {
        return [
          IconButton(
            onPressed:
                noteViewModel.isLoading
                    ? null
                    : () => _showDeleteDialog(context, noteViewModel),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete note',
          ),
        ];
      }
    }
    return [];
  }

  void _switchToEditMode() {
    setState(() {
      _isReadingMode = false;
    });
  }

  void _switchToReadingMode() {
    setState(() {
      _isReadingMode = true;
    });
  }

  Future<void> _saveNote() async {
    final noteViewModel = context.read<NoteViewModel>();
    final success = await noteViewModel.saveNote();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully saved note!'),
          backgroundColor: Colors.green,
        ),
      );

      context.read<HomeViewModel>().refreshNotes();

      if (noteViewModel.isEditing) {
        _switchToReadingMode();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _showDeleteDialog(
    BuildContext screenContext,
    NoteViewModel noteViewModel,
  ) {
    showDialog(
      context: screenContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final success = await noteViewModel.deleteNote();

                if (!screenContext.mounted) return;

                if (success) {
                  screenContext.read<HomeViewModel>().refreshNotes();
                  Navigator.of(screenContext).pop();
                } else {
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        noteViewModel.errorMessage ?? 'Failed to delete note',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
