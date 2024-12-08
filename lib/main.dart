import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'unidades.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unidades PUC Minas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MyMapWidget(),
      ),
    );
  }
}

class MyMapWidget extends StatefulWidget {
  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  LatLng _userLocation = LatLng(0.0, 0.0);
  LatLng _lastLocation = LatLng(0.0, 0.0);
  bool _locationFetched = false;
  final MapController _mapController = MapController();

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Serviço de localização desabilitado. Ative-o e tente novamente.")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permissão de localização negada.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permissão de localização permanentemente negada.")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });

      if (_calculateDistance(_lastLocation, _userLocation) >= 100) {
        _lastLocation = _userLocation;
        await _sendLocationToGCF(_userLocation);
      }

      _mapController.move(_userLocation, 18);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao obter localização: $e")),
      );
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double R = 6371000;
    final double lat1 = start.latitude * (3.141592653589793 / 180);
    final double lat2 = end.latitude * (3.141592653589793 / 180);
    final double dLat = (end.latitude - start.latitude) * (3.141592653589793 / 180);
    final double dLon = (end.longitude - start.longitude) * (3.141592653589793 / 180);

    final double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(lat1) * math.cos(lat2) *
        (math.sin(dLon / 2) * math.sin(dLon / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  Future<void> _sendLocationToGCF(LatLng location) async {
    final url = Uri.parse("https://us-central1-temporal-storm-444117-e4.cloudfunctions.net/pucminas-check-location");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "latitude": location.latitude,
          "longitude": location.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final message = json.decode(response.body)["message"];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao comunicar com o servidor.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro na conexão com o servidor: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unidades PUC Minas'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _locationFetched
                  ? _userLocation
                  : LatLng(-19.9191, -43.9378),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_locationFetched)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation,
                      width: 30.0,
                      height: 30.0,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Unidades()),
                );
              },
              child: ElevatedButton(
                onPressed: () {},
                child: Text("Ver Unidades"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
