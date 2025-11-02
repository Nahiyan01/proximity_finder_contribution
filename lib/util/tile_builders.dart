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
  final url =
      'https://barikoi.xyz/v2/api/route/$currentLongitude,$currentLatitude;$destinationLongitude,$destinationLatitude?api_key=$apiKey&geometries=polyline';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final polyline = data['routes'][0]['geometry'];
    final decodedPolyline = decodePolyline(polyline);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          currentLatitude: 23.916949916543917,
          currentLongitude: 90.23196677236218,
          destinationLatitude: destinationLatitude,
          destinationLongitude: destinationLongitude,
          polyline: decodedPolyline,
        ),
      ),
    );
  } else {
    throw Exception('Failed to load route overview');
  }
}

List<LatLng> decodePolyline(String encoded) {
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng> points = polylinePoints.decodePolyline(encoded);
  return points
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();
}

Future<void> fetchPlaceDetails(
    String placeCode,
    String apiKey,
    String sessionId,
    BuildContext context,
    double currentLatitude,
    double currentLongitude) async {
  final url =
      'https://barikoi.xyz/api/v2/places?place_code=$placeCode&api_key=$apiKey&session_id=$sessionId';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final destinationLatitude =
        double.parse(data['place']['latitude'].toString());
    final destinationLongitude =
        double.parse(data['place']['longitude'].toString());

    fetchRouteOverview(currentLatitude, currentLongitude, destinationLatitude,
        destinationLongitude, apiKey, context);
  } else {
    print('Failed to load place details: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to load place details');
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
