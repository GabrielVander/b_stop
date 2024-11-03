import 'package:flutter/material.dart' show BuildContext, MaterialApp, Scaffold, Stack, StatelessWidget, Widget, runApp;
import 'package:flutter_map/flutter_map.dart' show FlutterMap, MapController, MapOptions, TileLayer;
import 'package:latlong2/latlong.dart' show LatLng;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: MapController(),
              options: const MapOptions(initialCenter: LatLng(-22.012, -47.891)),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
