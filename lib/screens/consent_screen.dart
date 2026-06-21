import 'package:flutter/material.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({
    super.key,
    required this.onAccept,
    required this.onExit,
  });

  final Future<void> Function() onAccept;
  final VoidCallback onExit;

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<double> _textFade;
  late Animation<double> _linksFade;
  late Animation<double> _checkboxFade;
  late Animation<double> _buttonsFade;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );

    _linksFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _checkboxFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: FadeTransition(
              opacity: _titleFade,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
                  ),
                ),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        FadeTransition(
                          opacity: _titleFade,
                          child: const Text(
                            'Privacy & Terms',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Main Text
                        FadeTransition(
                          opacity: _textFade,
                          child: const Text(
                            'Before continuing, please review and accept our Privacy Policy and Terms of Service. No data will be collected until you agree.',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Description Text
                        FadeTransition(
                          opacity: _textFade,
                          child: const Text(
                            'We only collect the information required for emergency monitoring and safety services. If you do not agree, the app will close.',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Links Section
                        FadeTransition(
                          opacity: _linksFade,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/privacy');
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: const Text(
                                    'Read Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 15,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/terms');
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: const Text(
                                    'Read Terms of Service',
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 15,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Checkbox
                        FadeTransition(
                          opacity: _checkboxFade,
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreed,
                                onChanged: (value) {
                                  setState(() {
                                    _agreed = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreed = !_agreed;
                                    });
                                  },
                                  child: const Text(
                                    'I agree to the Privacy Policy and Terms of Service',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        FadeTransition(
                          opacity: _buttonsFade,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _agreed
                                        ? const Color.fromARGB(255, 210, 183, 255)
                                        : const Color.fromRGBO(103, 58, 183, 0.35),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _agreed
                                      ? () async {
                                          await widget.onAccept();
                                        }
                                      : null,
                                  child: const Text('Continue'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: widget.onExit,
                                  child: const Text('Exit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
