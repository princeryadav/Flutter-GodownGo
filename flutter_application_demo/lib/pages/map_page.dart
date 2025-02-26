import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> routePoints = [];
  List<dynamic> searchResults = [];
  TextEditingController searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
    _moveCamera(currentLocation!);
  }

  void _setDestination(double lat, double lng, String name) {
    setState(() {
      destination = LatLng(lat, lng);
      _drawPolyline();
    });
    _moveCamera(destination!);
  }

  Future<void> _drawPolyline() async {
    if (currentLocation == null || destination == null) return;
    final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${destination!.longitude},${destination!.latitude}?overview=full&geometries=geojson");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
    }
  }

  Future<void> _moveCamera(LatLng pos) async {
    _mapController.move(pos, 13);
  }

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse("https://nominatim.openstreetmap.org/search?format=json&q=$query");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? LatLng(18.943888, 72.835991),
              initialZoom: 18,
            ),
            children: [
              TileLayer(
                tileProvider: CancellableNetworkTileProvider(), // ✅ Using cancellable tile provider
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                
              ),
               RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    "© OpenStreetMap contributors",
                    onTap: () => launchUrl(
                        Uri.parse("https://www.openstreetmap.org/copyright")),
                  ),
                ],
              ),
              if (currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                    if (destination != null)
                      Marker(
                        point: destination!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.black, size: 40),
                      ),
                  ],
                ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search destination",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchLocation(searchController.text),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    height: 200,
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return ListTile(
                          title: Text(result['display_name']),
                          onTap: () {
                            double lat = double.parse(result['lat']);
                            double lng = double.parse(result['lon']);
                            _setDestination(lat, lng, result['display_name']);
                            setState(() {
                              searchResults = [];
                              searchController.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
