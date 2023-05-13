import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  LatLng? latLng = LatLng(45.5231, -122.6765);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            child: FlutterMap(
              options: MapOptions(
                center: latLng,
                zoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1IjoiZGJlbmNhayIsImEiOiJjbGhtYXBhY2gxYTJ3M2NueHg2cDdiNDFrIn0.ZhEWmoS3j-tS230DXRrNlQ',
                    'id': 'mapbox.satellite',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                        point: LatLng(45.5231, -122.6765),
                        builder: (context) => Container(
                              child: FlutterLogo(),
                            )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
