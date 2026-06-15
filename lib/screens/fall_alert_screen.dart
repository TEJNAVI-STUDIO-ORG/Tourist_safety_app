import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/settings_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/location_provider.dart';
import '../services/sos_service.dart';

class EmergencyBreakthroughScreen extends StatefulWidget {
  final String reason;
  final int countdownSeconds;

  const EmergencyBreakthroughScreen({
    super.key,
    required this.reason,
    this.countdownSeconds = 30,
  });

  @override
  State<EmergencyBreakthroughScreen> createState() => _EmergencyBreakthroughScreenState();
}

class _EmergencyBreakthroughScreenState extends State<EmergencyBreakthroughScreen> {
  late int _countdown;
  Timer? _timer;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _countdown = widget.countdownSeconds;
    _startTimer();
    _startUrgentVibration();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _vibrationTimer?.cancel();
        _triggerSOS();
      }
    });
  }

  void _startUrgentVibration() async {
    if (await Vibration.hasVibrator() ) {
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        // SOS Pattern
        Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500, 200, 1000, 200, 1000, 200, 1000]);
      });
    }
  }

  Future<void> _triggerSOS() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final status = Provider.of<SystemStatusProvider>(context, listen: false);
    final location = Provider.of<LocationProvider>(context, listen: false);

    await location.getCurrentLocation();
    await SosService.triggerSOS(
      statusProvider: status,
      settingsProvider: settings,
      customMessage: "🚨 AUTOMATIC SOS: ${widget.reason.toUpperCase()}\n\nI am unresponsive and may need help.",
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "EMERGENCY DETECTED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.reason.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: _countdown / widget.countdownSeconds,
                        strokeWidth: 12,
                        color: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                const Text(
                  "AUTO-SOS INITIATING IN...",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 50),
                
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      _vibrationTimer?.cancel();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "I AM SAFE",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _triggerSOS,
                  child: const Text(
                    "SEND SOS NOW",
                    style: TextStyle(color: Colors.white60, fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
