import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../services/location_service.dart';
import '../../services/distance_service.dart'; // Importa o serviço de distância

class GpsPage extends StatefulWidget {
  final String busNumber; // Adiciona o parâmetro para o número do ônibus

  const GpsPage({super.key, required this.busNumber});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  // Agora, o número do ônibus será acessado via widget.busNumber
  late FirebaseService _firebaseService;
  late DistanceService _distanceService;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? _currentLocation;
  LatLng? _busLocation;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(2.8206, -60.6738),
    zoom: 14.4746,
  );

  late StreamSubscription<Position>? locationStreamSubscription;
  String _distance = '';
  String _duration = '';
  BitmapDescriptor? _busIcon; // Variável para armazenar o ícone do ônibus

  @override
  void initState() {
    super.initState();
    _initializeFirebaseService();
    _initializeLocation();
    _fetchBusLocation();
    _loadBusIcon(); // Carregar o ícone do ônibus

    // Inicializa o serviço de distância com a chave da API
    _distanceService =
        DistanceService(apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!);
  }

  Future<void> _initializeFirebaseService() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firebaseService = FirebaseService(user.uid);
    } else {
      print('Nenhum usuário logado.');
    }
  }

  Future<void> _initializeLocation() async {
    bool isGranted = await StreamLocationService.askLocationPermission();
    if (isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (_busLocation != null) _calculateDistanceAndDuration();
      _moveCameraToBounds();
    } else {
      print('Permissão de localização negada.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }

  void _fetchBusLocation() {
    _firebaseService
        .getBusLocationByNumber(widget.busNumber)
        .listen((locations) {
      if (locations.isNotEmpty && locations[0]['location'] != null) {
        final busLatLng = LatLng(
          locations[0]['location']['lat'],
          locations[0]['location']['lng'],
        );
        setState(() {
          _busLocation = busLatLng;
        });
        if (_currentLocation != null) _calculateDistanceAndDuration();
        _moveCameraToBounds();
      } else {
        print('Localização do ônibus não encontrada.');
      }
    });
  }

  Future<void> _calculateDistanceAndDuration() async {
    if (_currentLocation != null && _busLocation != null) {
      try {
        final result = await _distanceService.calculateDistanceAndDuration(
            _currentLocation!, _busLocation!);
        setState(() {
          _distance = result['distance']!;
          _duration = result['duration']!;
        });
      } catch (e) {
        print('Erro ao calcular distância e duração: $e');
      }
    }
  }

  Future<void> _moveCameraToBounds() async {
    if (_currentLocation != null && _busLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _currentLocation!.latitude < _busLocation!.latitude
              ? _currentLocation!.latitude
              : _busLocation!.latitude,
          _currentLocation!.longitude < _busLocation!.longitude
              ? _currentLocation!.longitude
              : _busLocation!.longitude,
        ),
        northeast: LatLng(
          _currentLocation!.latitude > _busLocation!.latitude
              ? _currentLocation!.latitude
              : _busLocation!.latitude,
          _currentLocation!.longitude > _busLocation!.longitude
              ? _currentLocation!.longitude
              : _busLocation!.longitude,
        ),
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  // Função para carregar o ícone do ônibus
  Future<void> _loadBusIcon() async {
    final icon = await getImage('assets/bus_icon.png');
    setState(() {
      _busIcon = icon; // Atualiza o estado com o ícone carregado
    });
  }

  // Função para carregar a imagem do asset e retornar o BitmapDescriptor
  Future<BitmapDescriptor> getImage(String assetPath) async {
    final asset = await DefaultAssetBundle.of(context).load(assetPath);
    final icon = BitmapDescriptor.bytes(asset.buffer.asUint8List());
    return icon;
  }

  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    if (_busLocation != null && _busIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('bus_location'),
          position: _busLocation!,
          icon: _busIcon!, // Use o ícone carregado
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Localização",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _createMarkers(),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distância: $_distance',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text('Tempo estimado: $_duration',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            child: FloatingActionButton(
              onPressed: _moveCameraToBounds,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
