import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _locationFetched = false;
  final MapController _mapController = MapController();

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se os serviços de localização estão habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Serviço de localização desabilitado. Ative-o e tente novamente.")),
      );
      return;
    }

    // Verifica e solicita permissões de localização
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

    // Obtém a localização atual com maior precisão possível
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });

      _mapController.move(_userLocation, 18);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao obter localização: $e")),
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
        title: Text('Flutter Map Example'),
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
              onTap: () async {
                final url = Uri.parse('https://openstreetmap.org/copyright');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Aqui está o ElevatedButtonExample
          Positioned(
            bottom: 80,
            right: 10,
            child: ElevatedButtonExample(),
          ),
        ],
      ),
    );
  }

}

class ElevatedButtonExample extends StatefulWidget {
  const ElevatedButtonExample({super.key});

  @override
  State<ElevatedButtonExample> createState() => _ElevatedButtonExampleState();
}

class _ElevatedButtonExampleState extends State<ElevatedButtonExample> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
    ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Unidades()),
            );},
            child: const Text('Ver unidades'),
          ),
        ],
      ),
    );
  }
}
