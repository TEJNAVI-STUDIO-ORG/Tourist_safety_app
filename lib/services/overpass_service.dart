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
  node["name"](around:1000,$lat,$lng);
  way["name"](around:1000,$lat,$lng);
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
              // Update status to show successful connection with specific endpoint
              final endpointName = base.split('/')[2]; // Extracts domain
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              final elements = data['elements'];
              final String suggestion = _buildOverpassSuggestion(elements);
              final String? locationName = _extractNearbyPlaceName(elements);

              statusProvider?.updateOverpass(
                active: true,
                status: "Connected Successfully to $endpointName",
                suggestion: suggestion,
              );
              if (locationName != null) {
                statusProvider?.updateLocationName(locationName);
              }
              statusProvider?.resetRetry();
              
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

  static String _buildOverpassSuggestion(dynamic elements) {
    if (elements is! List || elements.isEmpty) {
      return 'No nearby hazards detected.';
    }

    final first = elements.firstWhere(
      (element) => element is Map<String, dynamic>,
      orElse: () => null,
    );

    if (first is! Map<String, dynamic>) {
      return 'No nearby hazards detected.';
    }

    final tags = first['tags'] as Map<String, dynamic>?;
    final hazardName = tags?['name'] ?? tags?['amenity'] ?? tags?['natural'] ?? tags?['landuse'] ?? first['type']?.toString() ?? 'hazard';

    if (tags != null && tags['amenity'] != null) {
      return 'Nearby ${tags['amenity']} detected. Stay alert.';
    }

    return 'Nearby $hazardName detected. Be cautious.';
  }

  static String? _extractNearbyPlaceName(dynamic elements) {
    if (elements is! List<dynamic>) {
      return null;
    }

    final placeElement = elements.firstWhere(
      (element) {
        if (element is! Map<String, dynamic>) return false;
        final tags = element['tags'] as Map<String, dynamic>?;
        if (tags == null) return false;
        final placeType = tags['place']?.toString().toLowerCase();
        return placeType == 'town' ||
            placeType == 'city' ||
            placeType == 'village' ||
            placeType == 'hamlet';
      },
      orElse: () => null,
    );

    if (placeElement is! Map<String, dynamic>) {
      return null;
    }

    final tags = placeElement['tags'] as Map<String, dynamic>?;
    final name = tags?['name']?.toString();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return null;
  }
}
