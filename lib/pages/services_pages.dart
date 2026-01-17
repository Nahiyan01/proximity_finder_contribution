import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proximity_finder/services/barikoi_services.dart';
import 'package:proximity_finder/util/tile_builders.dart';

class ServicesPage extends StatefulWidget {
  final String category;

  const ServicesPage({super.key, required this.category});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final BarikoiService barikoiService = BarikoiService(
      apiKey:
          "bkoi_b1a2920d9f9013418b492dd13482b83e3b70777e024f6724a747a6e5b8a1a0b4");
  List<Map<String, dynamic>> services = [];

  // Fixed starting location for all routes
  static const double FIXED_START_LAT = 23.9170737;
  static const double FIXED_START_LNG = 90.2321362;

  void _navigateToRoute(String placeCode) {
    if (sessionId != null) {
      fetchPlaceDetails(
        placeCode,
        barikoiService.apiKey,
        sessionId!,
        context,
        FIXED_START_LAT,
        FIXED_START_LNG,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session not available')),
      );
    }
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
            _navigateToRoute(placeCode);
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
            trailing: Icon(Icons.directions, color: Colors.blue),
          ),
        ),
      ),
    );
  }

  bool isLoading = false;
  String area = '';
  String errorMessage = '';
  bool isSearching = false;
  Position? currentPosition;
  String? sessionId;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          errorMessage = 'Location services are disabled.';
        });
      }
      return;
    }

    // Request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            errorMessage = 'Location permissions are denied.';
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          errorMessage = 'Location permissions are permanently denied.';
        });
      }
      return;
    }

    // Get the current location
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _searchInitialPlaces();
  }

  Future<void> _searchInitialPlaces() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
        isSearching = false;
      });
    }

    try {
      final results = await barikoiService.getPlaces(
          'kohinurgate,Savar,Dhaka', widget.category.toLowerCase());
      if (mounted) {
        setState(() {
          services = List<Map<String, dynamic>>.from(results['places']);
          sessionId =
              results['session_id'].toString(); // Ensure session_id is a String
          isLoading = false;
          if (services.isEmpty) {
            errorMessage = 'No results found for kohinurgate, Savar, Dhaka';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load places';
        });
      }
    }
  }

  Future<void> _fetchNearbyServices(double latitude, double longitude) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
        isSearching = false;
      });
    }

    try {
      final results = await barikoiService.getNearbyPlaces(
          latitude, longitude, widget.category.toLowerCase(), 2.0);
      if (mounted) {
        setState(() {
          services = List<Map<String, dynamic>>.from(results['places']);
          sessionId =
              results['session_id'].toString(); // Ensure session_id is a String
          isLoading = false;
          if (services.isEmpty) {
            errorMessage = 'No nearby services found.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load nearby services.';
        });
      }
    }
  }

  Future<void> fetchServices() async {
    if (area.isEmpty) return;

    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
        isSearching = true;
      });
    }

    try {
      final results =
          await barikoiService.getPlaces(area, widget.category.toLowerCase());
      if (mounted) {
        setState(() {
          services = List<Map<String, dynamic>>.from(results['places']);
          sessionId =
              results['session_id'].toString(); // Ensure session_id is a String
          isLoading = false;
          if (services.isEmpty) {
            errorMessage = 'No results found for $area';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load places';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text('${widget.category} in your area'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter area',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                area = value;
              },
              onSubmitted: (value) {
                fetchServices();
              },
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return isSearching
                              ? buildSearchResultTile(
                                  service,
                                  context,
                                  currentPosition!.latitude,
                                  currentPosition!.longitude,
                                  barikoiService.apiKey,
                                  sessionId!)
                              : buildSearchResultTile(
                                  service,
                                  context,
                                  currentPosition!.latitude,
                                  currentPosition!.longitude,
                                  barikoiService.apiKey,
                                  sessionId!);
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
