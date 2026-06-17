import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.onFinished});

  final void Function(bool consent) onFinished;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeIn;
  late Animation<double> slideUp;
  String _loadingText = "Initializing Safety Systems...";

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    slideUp = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    controller.forward();

    // Start pulsing after initial fade in completes
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.repeat(reverse: true);
      }
    });

    startLoading();
  }

  Future<void> startLoading() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _loadingText = "Preparing your experience...";
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final consent = prefs.getBool('consentAccepted') ?? false;
    widget.onFinished(consent);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
            opacity: fadeIn.value,
            child: Transform.translate(
              offset: Offset(0, slideUp.value),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO with pulsing effect and CIRCULAR CLIP
                    ScaleTransition(
                      scale: controller.isAnimating && controller.value > 0.5
                          ? Tween<double>(
                              begin: 1.0,
                              end: 1.05,
                            ).animate(controller)
                          : const AlwaysStoppedAnimation(1.0),
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
                            "TouriSafe",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              _loadingText,
                              key: ValueKey(_loadingText),
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
