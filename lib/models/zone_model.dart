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

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'latitude': center.latitude,
      'longitude': center.longitude,
      'radius': radius,
      'color': color.value,
      'riskScore': riskScore,
      'severity': severity,
    };
  }

  // =========================
  // FROM JSON
  // =========================
  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'],

      type: json['type'],

      name: json['name'],

      center: LatLng(
        json['latitude'],
        json['longitude'],
      ),

      radius: (json['radius'] as num).toDouble(),

      color: Color(json['color']),

      riskScore: json['riskScore'],

      severity: json['severity'],
    );
  }
}