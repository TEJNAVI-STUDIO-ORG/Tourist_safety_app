import 'dart:convert';

import 'package:http/http.dart' as http;
import '../providers/system_status_provider.dart';

/// Fetches OSM hazard data via Overpass. Several public mirrors are tried
/// because some endpoints return HTTP 406 on mobile if headers or routing differ.
class OverpassService {
  static DateTime? _lastFetchTime;

  static const _endpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.fr/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  /// Mirrors sometimes reject clients without Accept / browser-like User-Agent.
  static const _headers = <String, String>{
    'Content-Type': 'text/plain; charset=utf-8',
    'Accept': 'application/json, text/plain, */*',
    'User-Agent':
        'Mozilla/5.0 (compatible; TouriSafe/1.0; +https://openstreetmap.org)',
  };

  static Future<List<dynamic>> fetchNearbyHazards({
    required double lat,
    required double lng,
    SystemStatusProvider? statusProvider,
  }) async {
    try {
      final now = DateTime.now();

      if (_lastFetchTime != null) {
        final difference = now.difference(_lastFetchTime!);

        if (difference.inSeconds < 30) {
          return [];
        }
      }

      _lastFetchTime = now;

      final query = '''
[out:json];
(
  node["natural"="cliff"](around:1200,$lat,$lng);
  way["landuse"="forest"](around:1200,$lat,$lng);
  node["natural"="water"](around:1200,$lat,$lng);
  node["natural"="peak"](around:1200,$lat,$lng);
  way["military"](around:1200,$lat,$lng);
  way["hazard"](around:1200,$lat,$lng);
  way["boundary"="protected_area"](around:1200,$lat,$lng);
  node["amenity"="hospital"](around:1200,$lat,$lng);
  node["amenity"="police"](around:1200,$lat,$lng);
  node["amenity"="fire_station"](around:1200,$lat,$lng);
  node["tourism"](around:1200,$lat,$lng);
  node["place"="town"](around:1500,$lat,$lng);
);
out center;
''';

      final client = http.Client();
      try {
        bool connectionAttempted = false;
        for (final base in _endpoints) {
          try {
            connectionAttempted = true;
            final uri = Uri.parse(base);
            
            // Update status to show connection attempt
            statusProvider?.updateOverpass(
              active: false, 
              status: "Connecting to $base..."
            );
            
            final response = await client
                .post(
                  uri,
                  headers: _headers,
                  body: query,
                )
                .timeout(const Duration(seconds: 55));

            if (response.statusCode == 200) {
              // Update status to show successful connection
              statusProvider?.updateOverpass(
                active: true, 
                status: "Connected successfully"
              );
              statusProvider?.resetRetry();
              
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              final elements = data['elements'];
              if (elements is List<dynamic>) {
                return elements;
              }
              return [];
            } else {
              // Update status to show failed response
              statusProvider?.updateOverpass(
                active: false, 
                status: "HTTP ${response.statusCode} - Failed"
              );
              statusProvider?.incrementRetry();
            }
          } catch (e) {
            // Update status to show connection error
            statusProvider?.updateOverpass(
              active: false, 
              status: "Connection failed to $base"
            );
            statusProvider?.incrementRetry();
            // Try next mirror.
            continue;
          }
        }
        
        // If all endpoints failed
        if (connectionAttempted) {
          statusProvider?.updateOverpass(
            active: false, 
            status: "All endpoints failed"
          );
        }
      } finally {
        client.close();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
