import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/note.dart';
import '../note_screen.dart';
import '../widgets/empty_state_widget.dart';

class NoteMapView extends StatefulWidget {
  final List<Note> notes;
  final VoidCallback? onRefresh;

  const NoteMapView({super.key, required this.notes, this.onRefresh});

  @override
  State<NoteMapView> createState() => _NoteMapViewState();
}

class _NoteMapViewState extends State<NoteMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createMarkers();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NoteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    if (!mounted) return;

    setState(() {
      _markers.clear();

      for (final note in widget.notes) {
        if (note.latitude != null && note.longitude != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(note.id),
              position: LatLng(note.latitude!, note.longitude!),
              infoWindow: InfoWindow(
                title: note.title.isNotEmpty ? note.title : 'Untitled Note',
                snippet:
                    note.content.length > 50
                        ? '${note.content.substring(0, 50)}...'
                        : note.content,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteScreen(note: note),
                    ),
                  );
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesWithLocation =
        widget.notes
            .where((note) => note.latitude != null && note.longitude != null)
            .toList();

    if (notesWithLocation.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.map,
        title: 'No notes with location',
        description: 'Create notes with location data\nto see them on the map',
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            setState(() {
              _isMapReady = true;
            });
          },
          initialCameraPosition: _getInitialCameraPosition(),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
        ),
      ],
    );
  }

  CameraPosition _getInitialCameraPosition() {
    if (widget.notes.isEmpty) {
      return const CameraPosition(target: LatLng(0, 0), zoom: 2);
    }

    final notesWithLocation =
        widget.notes
            .where((note) => note.latitude != null && note.longitude != null)
            .toList();

    if (notesWithLocation.isEmpty) {
      return const CameraPosition(target: LatLng(0, 0), zoom: 2);
    }

    final firstNote = notesWithLocation.first;
    return CameraPosition(
      target: LatLng(firstNote.latitude!, firstNote.longitude!),
      zoom: 10,
    );
  }
}
