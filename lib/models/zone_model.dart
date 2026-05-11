import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ZoneModel {
  final String id;

  final String type;

  final String name;

  final LatLng center;

  final double radius;

  final Color color;

  final int riskScore;

  final String severity;

  ZoneModel({
    required this.id,
    required this.type,
    required this.name,
    required this.center,
    required this.radius,
    required this.color,
    required this.riskScore,
    required this.severity,
  });
}
