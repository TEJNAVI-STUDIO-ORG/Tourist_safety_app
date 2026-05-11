
class GeofenceModel {

  final String zoneId;

  final String zoneType;

  final String eventType;

  final DateTime timestamp;

  final String severity;

  GeofenceModel({
    required this.zoneId,

    required this.zoneType,

    required this.eventType,

    required this.timestamp,

    required this.severity,
  });
}
