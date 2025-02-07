import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceService {
  final String apiKey;

  DistanceService({required this.apiKey});

  Future<Map<String, dynamic>> calculateDistanceAndDuration(
      LatLng origin, LatLng destination) async {
    final originStr = '${origin.latitude},${origin.longitude}';
    final destinationStr = '${destination.latitude},${destination.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originStr&destination=$destinationStr&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0]['legs'][0];

          // Extrai os pontos da rota
          final points =
              _decodePolyline(data['routes'][0]['overview_polyline']['points']);

          return {
            'distance': route['distance']['text'],
            'duration': route['duration']['text'],
            'route': points, // Adiciona os pontos da rota
          };
        } else {
          throw Exception('Nenhuma rota encontrada');
        }
      } else {
        throw Exception('Erro ao buscar rota: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

// Decodifica a polyline da API para uma lista de LatLng
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }
}
