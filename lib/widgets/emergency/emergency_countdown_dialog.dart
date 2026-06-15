import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class EmergencyCountdownDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onEmergency;
  final VoidCallback onSafe;
  final VoidCallback? onLeaveZone;
  final int countdownSeconds;

  const EmergencyCountdownDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onEmergency,
    required this.onSafe,
    this.onLeaveZone,
    this.countdownSeconds = 30,
  });

  @override
  State<EmergencyCountdownDialog> createState() => _EmergencyCountdownDialogState();
}

class _EmergencyCountdownDialogState extends State<EmergencyCountdownDialog> {
  late int _countdown;
  Timer? _timer;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _countdown = widget.countdownSeconds;
    _startTimer();
    _startSosVibration();
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
        Navigator.of(context, rootNavigator: true).pop();
        widget.onEmergency();
      }
    });
  }

  void _startSosVibration() async {
    if (await Vibration.hasVibrator()) {
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
        Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 1000]);
      });
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
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.red, width: 3)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 20),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: _countdown / widget.countdownSeconds,
                          strokeWidth: 8,
                          color: Colors.red,
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ),
                      ),
                      Text(
                        '$_countdown',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // MESSAGE PREVIEW
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("MESSAGE PREVIEW:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          settings.sosMessageTemplate.replaceAll("{location}", "Current Location"),
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sending to ${settings.contacts.length} emergency contacts",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            actions: [
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _vibrationTimer?.cancel();
                        Navigator.of(context, rootNavigator: true).pop();
                        widget.onSafe();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("I'M SAFE (CANCEL SOS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _vibrationTimer?.cancel();
                            Navigator.of(context, rootNavigator: true).pop();
                            if (widget.onLeaveZone != null) widget.onLeaveZone!();
                            widget.onSafe();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('LEAVE ZONE', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
