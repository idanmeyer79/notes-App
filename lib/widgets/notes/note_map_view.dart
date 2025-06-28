import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/note.dart';
import '../../note_screen.dart';

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
      if (_isMapReady) {
        _fitBounds();
      }
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
      return _buildEmptyState();
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            setState(() {
              _isMapReady = true;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _fitBounds();
              }
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
        if (_isMapReady)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _fitBounds,
              mini: true,
              heroTag: 'map_fab',
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notes with location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create notes with location data\nto see them on the map',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  void _fitBounds() {
    if (_mapController == null || _markers.isEmpty || !_isMapReady) return;

    try {
      final notesWithLocation =
          widget.notes
              .where((note) => note.latitude != null && note.longitude != null)
              .toList();

      if (notesWithLocation.length == 1) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              notesWithLocation.first.latitude!,
              notesWithLocation.first.longitude!,
            ),
            10,
          ),
        );
      } else if (notesWithLocation.length > 1) {
        final bounds = _calculateBounds(notesWithLocation);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } catch (e) {
      ('Error fitting bounds: $e');
    }
  }

  LatLngBounds _calculateBounds(List<Note> notes) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final note in notes) {
      if (note.latitude != null && note.longitude != null) {
        minLat = min(minLat, note.latitude!);
        maxLat = max(maxLat, note.latitude!);
        minLng = min(minLng, note.longitude!);
        maxLng = max(maxLng, note.longitude!);
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
