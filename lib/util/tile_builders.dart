import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proximity_finder/pages/map_page.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

Future<void> fetchRouteOverview(
    double currentLatitude,
    double currentLongitude,
    double destinationLatitude,
    double destinationLongitude,
    String apiKey,
    BuildContext context) async {
  try {
    final url =
        'https://barikoi.xyz/v2/api/route/$currentLongitude,$currentLatitude;$destinationLongitude,$destinationLatitude?api_key=$apiKey&geometries=polyline';
    print('Fetching route from: $url');
    print(
        'From: ($currentLatitude, $currentLongitude) To: ($destinationLatitude, $destinationLongitude)');

    final response = await http.get(Uri.parse(url));
    print('Route response: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('Full route response: $data');

        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          throw Exception('No routes found in response');
        }

        final polylineData = data['routes'][0]['geometry'];
        print('Polyline data: $polylineData');
        print('Polyline type: ${polylineData.runtimeType}');

        final decodedPolyline = decodePolyline(polylineData.toString());

        print('Decoded ${decodedPolyline.length} points from polyline');
        if (decodedPolyline.isNotEmpty) {
          print('First point: ${decodedPolyline.first}');
          print('Last point: ${decodedPolyline.last}');
        }

        if (decodedPolyline.isEmpty) {
          throw Exception('Decoded polyline is empty');
        }

        if (context.mounted) {
          print(
              'Navigating to map with ${decodedPolyline.length} polyline points');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                currentLatitude: currentLatitude,
                currentLongitude: currentLongitude,
                destinationLatitude: destinationLatitude,
                destinationLongitude: destinationLongitude,
                polyline: decodedPolyline,
              ),
            ),
          );
        }
      } catch (parseError) {
        print('Error parsing route data: $parseError');
        print('Stack trace: ${StackTrace.current}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing route: $parseError')),
          );
        }
      }
    } else {
      print('Failed to load route: ${response.statusCode}');
      print('Response: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load route: ${response.statusCode}')),
        );
      }
    }
  } catch (e) {
    print('Exception in fetchRouteOverview: $e');
    print('Stack trace: ${StackTrace.current}');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route error: $e')),
      );
    }
  }
}

List<LatLng> decodePolyline(String encoded) {
  try {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> points = polylinePoints.decodePolyline(encoded);

    if (points.isEmpty) {
      print('Polyline decoder returned empty list, trying alternative method');
      // If standard decoder fails, try parsing as LatLng array
      return _decodePolylineAlternative(encoded);
    }

    final result =
        points.map((point) => LatLng(point.latitude, point.longitude)).toList();

    print('Decoded ${result.length} points using standard decoder');
    return result;
  } catch (e) {
    print('Error in standard polyline decoding: $e, trying alternative');
    return _decodePolylineAlternative(encoded);
  }
}

List<LatLng> _decodePolylineAlternative(String encoded) {
  // This is a fallback method in case the polyline format is different
  try {
    List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      double latitude = lat / 1e5;
      double longitude = lng / 1e5;

      points.add(LatLng(latitude, longitude));
    }

    print('Decoded ${points.length} points using alternative method');
    return points;
  } catch (e) {
    print('Error in alternative polyline decoding: $e');
    return [];
  }
}

Future<void> fetchPlaceDetails(
    String placeCode,
    String apiKey,
    String sessionId,
    BuildContext context,
    double currentLatitude,
    double currentLongitude) async {
  try {
    final url =
        'https://barikoi.xyz/api/v2/places?place_code=$placeCode&api_key=$apiKey&session_id=$sessionId';
    print('Fetching place details from: $url');

    final response = await http.get(Uri.parse(url));
    print('Place details response: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('Place data: $data');

        if (data['place'] == null) {
          throw Exception('Place data is null in response');
        }

        final destinationLatitude =
            double.parse(data['place']['latitude'].toString());
        final destinationLongitude =
            double.parse(data['place']['longitude'].toString());

        print('Destination: $destinationLatitude, $destinationLongitude');

        await fetchRouteOverview(currentLatitude, currentLongitude,
            destinationLatitude, destinationLongitude, apiKey, context);
      } catch (parseError) {
        print('Error parsing place data: $parseError');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing location data: $parseError')),
          );
        }
      }
    } else {
      print('Failed to load place details: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load location details')),
        );
      }
    }
  } catch (e) {
    print('Exception in fetchPlaceDetails: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

Widget buildNearbyServiceTile(
    Map<String, dynamic> service,
    BuildContext context,
    double currentLatitude,
    double currentLongitude,
    String apiKey,
    String sessionId) {
  final name = service['name'] ?? 'No name available';
  final address = service['Address'] ?? 'No address available';
  final subType = service['subType'] ?? '';
  final addressWithoutFirstPart = address.contains(',')
      ? address.substring(address.indexOf(',') + 1).trim()
      : address;
  final placeCode = service['place_code']; // Extract place_code from service

  return Card(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    child: ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subType.isNotEmpty)
            Text(
              subType,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          Text(
            addressWithoutFirstPart,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
      onTap: () {
        if (placeCode != null && apiKey.isNotEmpty) {
          fetchPlaceDetails(
              placeCode,
              apiKey,
              sessionId,
              context,
              currentLatitude,
              currentLongitude); // Use place_code and sessionId to fetch place details
        } else {
          // Handle the case where placeCode or apiKey is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid place code or API key')),
          );
        }
      },
    ),
  );
}

Widget buildSearchResultTile(
    Map<String, dynamic> service,
    BuildContext context,
    double currentLatitude,
    double currentLongitude,
    String apiKey,
    String sessionId) {
  final address = service['address'] ?? 'No address available';
  final name = address.split(',')[0];
  final addressWithoutName = address.contains(',')
      ? address.substring(address.indexOf(',') + 1).trim()
      : address;
  final placeCode = service['place_code'];

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (placeCode != null && apiKey.isNotEmpty) {
          fetchPlaceDetails(placeCode, apiKey, sessionId, context,
              currentLatitude, currentLongitude);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid place code or API key')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white54, Colors.blueGrey],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListTile(
          leading: Icon(Icons.place),
          title: Text(name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(addressWithoutName, style: TextStyle(fontSize: 14)),
        ),
      ),
    ),
  );
}
