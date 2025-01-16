import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login/services/location_service.dart';
import '../../services/firebase_service.dart';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  late FirebaseService _firebaseService;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target:
        LatLng(2.8206, -60.6738), // Boa vista rr
    zoom: 14.4746,
  );

  late StreamSubscription<Position>? locationStreamSubscription;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(
        'itBiEvHga4SIMMkTrTr9pSzuIR02'); // Inicialize com o ID de usuário apropriado

    locationStreamSubscription =
        StreamLocationService.onLocationChanged?.listen(
      (position) async {
        await _firebaseService.updateUserLocation(
          'itBiEvHga4SIMMkTrTr9pSzuIR02', // Hardcoded UID
          LatLng(position.latitude, position.longitude),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              "Localização",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firebaseService.getBusLocationsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final Set<Marker> markers = {};
            for (var i = 0; i < snapshot.data!.length; i++) {
              final busData = snapshot.data![i];
              if (busData['location'] != null) {
                markers.add(
                  Marker(
                    markerId: MarkerId('Bus $i'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    position: LatLng(
                      busData['location']['lat'],
                      busData['location']['lng'],
                    ),
                    onTap: () =>
                        {}, // Pode adicionar uma ação ao tocar no marcador
                  ),
                );
              }
            }

            return GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            );
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }
}
