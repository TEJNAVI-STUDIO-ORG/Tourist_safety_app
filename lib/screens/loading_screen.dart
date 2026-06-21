import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/location_provider.dart';
import '../services/startup_manager.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.onFinished});

  final void Function(bool consent, bool setupComplete) onFinished;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  static const Duration _minDisplayTime = Duration(milliseconds: 2500);
  static const Duration _fadeOutDuration = Duration(milliseconds: 650);

  late AnimationController _enterController;
  late AnimationController _pulseController;
  late AnimationController _exitController;

  late Animation<double> _enterFade;
  late Animation<double> _enterSlide;
  late Animation<double> _exitFade;

  String _loadingText = 'Initializing Safety Systems...';
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: _fadeOutDuration,
    );

    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );

    _enterSlide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    _enterController.forward().then((_) {
      if (mounted && !_isExiting) {
        _pulseController.repeat(reverse: true);
      }
    });

    unawaited(_runLoadingSequence());
  }

  Future<void> _runLoadingSequence() async {
    final minimumWait = Future<void>.delayed(_minDisplayTime);
    final preparation = _prepareApp();

    await Future.wait([minimumWait, preparation]);

    if (!mounted) return;

    await _fadeOutAndFinish();
  }

  Future<void> _prepareApp() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _loadingText = 'Restoring your last location...';
    });

    await context.read<LocationProvider>().restoreFromBackground();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _loadingText = 'Preparing your experience...';
    });

    final prefs = await SharedPreferences.getInstance();
    final consent = prefs.getBool('consentAccepted') ?? false;
    final setupComplete = prefs.getBool('app_setup_complete') ?? false;

    if (consent && setupComplete && mounted) {
      await StartupManager.startAppInitialization(
        context,
        requestPermissions: false,
      );
    }

    _consent = consent;
    _setupComplete = setupComplete;
  }

  bool _consent = false;
  bool _setupComplete = false;

  Future<void> _fadeOutAndFinish() async {
    if (_isExiting) return;

    setState(() {
      _isExiting = true;
      _loadingText = 'Ready';
    });

    _pulseController.stop();
    await _exitController.forward();

    if (!mounted) return;
    widget.onFinished(_consent, _setupComplete);
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _enterController,
          _exitController,
          _pulseController,
        ]),
        builder: (context, child) {
          final opacity =
              _isExiting ? _exitFade.value : _enterFade.value;

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _isExiting ? 0 : _enterSlide.value),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 1, end: 1.04).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          height: 250,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    CircularProgressIndicator(
                      color: isDark ? const Color(0xFFF97316) : Colors.red,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            'TouriSafe',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: Text(
                              _loadingText,
                              key: ValueKey<String>(_loadingText),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
