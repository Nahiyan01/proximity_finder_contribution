import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapPage extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final List<LatLng> polyline;

  const MapPage({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.polyline,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? mController;

  static const styleId = 'osm-liberty'; // barikoi map style id
  static const apiKey =
      'bkoi_b1a2920d9f9013418b492dd13482b83e3b70777e024f6724a747a6e5b8a1a0b4'; // Replace with your Barikoi API key
  static const mapUrl =
      'https://map.barikoi.com/styles/$styleId/style.json?key=$apiKey';

  @override
  Widget build(BuildContext context) {
    // Use fixed starting location for all routes
    const double fixedStartLat = 23.9170737;
    const double fixedStartLng = 90.2321362;

    return Scaffold(
      appBar: AppBar(
        title: Text('Route to Destination'),
        elevation: 0,
      ),
      body: MapLibreMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(fixedStartLat, fixedStartLng),
          zoom: 13,
        ),
        onMapCreated: (MapLibreMapController controller) {
          mController = controller;
          _addRouteToMap();
        },
        styleString: mapUrl,
        onStyleLoadedCallback: () {
          // Re-add route when style loads
          _addRouteToMap();
        },
      ),
    );
  }

  void _addRouteToMap() {
    if (mController == null || widget.polyline.isEmpty) {
      print('Controller null or polyline empty');
      return;
    }

    try {
      print('Adding ${widget.polyline.length} points to map');
      print(
          'Start: (${widget.currentLatitude}, ${widget.currentLongitude}) -> End: (${widget.destinationLatitude}, ${widget.destinationLongitude})');

      // Add the route line with strong styling for visibility
      mController!.addLine(
        LineOptions(
          geometry: widget.polyline,
          lineColor: "#FF0000", // Bright red color
          lineWidth: 12.0, // Very thick line
          lineOpacity: 0.95, // Nearly opaque
        ),
      );

      print('Route line added with ${widget.polyline.length} points');

      // Add a second line with slightly offset position for better visibility (shadow effect)
      try {
        mController!.addLine(
          LineOptions(
            geometry: widget.polyline,
            lineColor: "#FFFF00", // Yellow outline for contrast
            lineWidth: 14.0,
            lineOpacity: 0.3,
          ),
        );
        print('Outline line added');
      } catch (e) {
        print('Could not add outline: $e');
      }

      // Calculate bounds to fit entire route
      if (widget.polyline.isNotEmpty) {
        double minLat = widget.polyline.first.latitude;
        double maxLat = widget.polyline.first.latitude;
        double minLng = widget.polyline.first.longitude;
        double maxLng = widget.polyline.first.longitude;

        for (var point in widget.polyline) {
          minLat = point.latitude < minLat ? point.latitude : minLat;
          maxLat = point.latitude > maxLat ? point.latitude : maxLat;
          minLng = point.longitude < minLng ? point.longitude : minLng;
          maxLng = point.longitude > maxLng ? point.longitude : maxLng;
        }

        final centerLat = (minLat + maxLat) / 2;
        final centerLng = (minLng + maxLng) / 2;

        // Add some padding to the bounds
        final latDiff = maxLat - minLat;
        final lngDiff = maxLng - minLng;
        final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

        // Update camera to show the entire route with padding
        try {
          mController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(centerLat, centerLng),
              // Calculate zoom level to fit bounds with padding
              maxDiff < 0.01
                  ? 15.0
                  : maxDiff < 0.05
                      ? 13.0
                      : 12.0,
            ),
          );
          print('Camera animated to fit route bounds');
        } catch (e) {
          print('Error animating camera: $e');
        }
      }

      // Try to add visual markers
      try {
        // Start marker - blue circle
        mController!.addCircle(
          CircleOptions(
            geometry: LatLng(widget.currentLatitude, widget.currentLongitude),
            circleRadius: 20.0, // 20 pixels
            circleColor: "#0000FF", // Blue
            circleOpacity: 0.8,
            circleStrokeColor: "#FFFFFF", // White outline
            circleStrokeWidth: 2.0,
          ),
        );

        // Destination marker - green circle
        mController!.addCircle(
          CircleOptions(
            geometry:
                LatLng(widget.destinationLatitude, widget.destinationLongitude),
            circleRadius: 20.0,
            circleColor: "#00FF00", // Green
            circleOpacity: 0.8,
            circleStrokeColor: "#FFFFFF", // White outline
            circleStrokeWidth: 2.0,
          ),
        );

        print('Start and destination circles added');
      } catch (markerError) {
        print(
            'Could not add circles: $markerError (map may not be fully loaded)');
      }

      print('Route and markers added successfully');
    } catch (e) {
      print('Error adding route to map: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
}
