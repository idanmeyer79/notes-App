import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/home_viewmodel.dart';
import 'widgets/note_list_view.dart';
import 'widgets/note_map_view.dart';
import 'note_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                onPressed: () => _showLogoutDialog(context, viewModel),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: _buildBody(viewModel),
          bottomNavigationBar: _buildBottomNavigationBar(viewModel),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _createNewNote(context),
            tooltip: 'Create new note',
            heroTag: 'home_fab',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(HomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshNotes(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildWelcomeSection(viewModel),
        Expanded(child: _buildNotesView(viewModel)),
      ],
    );
  }

  Widget _buildWelcomeSection(HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${viewModel.userName}!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.hasNotes
                ? 'You have ${viewModel.notes.length} note${viewModel.notes.length == 1 ? '' : 's'}'
                : 'Start creating your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesView(HomeViewModel viewModel) {
    switch (viewModel.currentViewMode) {
      case ViewMode.list:
        return NoteListView(
          notes: viewModel.notes,
          onRefresh: () => viewModel.refreshNotes(),
        );
      case ViewMode.map:
        return NoteMapView(
          notes: viewModel.notes,
          onRefresh: () => viewModel.refreshNotes(),
        );
    }
  }

  Widget _buildBottomNavigationBar(HomeViewModel viewModel) {
    return BottomNavigationBar(
      currentIndex: viewModel.currentViewMode.index,
      onTap: (index) {
        viewModel.setViewMode(ViewMode.values[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
      ],
    );
  }

  void _createNewNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteScreen()),
    );
  }

  void _showLogoutDialog(BuildContext context, HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.logout();
                // TODO: Navigate to login screen
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
