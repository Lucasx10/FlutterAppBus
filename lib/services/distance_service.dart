import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceService {
  final String apiKey;

  DistanceService({required this.apiKey});

  Future<Map<String, String>> calculateDistanceAndDuration(
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
          return {
            'distance': route['distance']['text'],
            'duration': route['duration']['text'],
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
}
