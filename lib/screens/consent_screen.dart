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

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF050816)
          : const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    const Text(
                      'Privacy & Terms',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Before continuing, please review and accept our Privacy Policy and Terms of Service. No data will be collected until you agree.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'We only collect the information required for emergency monitoring and safety services. If you do not agree, the app will close.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        // open privacy policy screen or external link
                        Navigator.pushNamed(context, '/privacy');
                      },
                      child: const Text(
                        'Read Privacy Policy',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: const Text(
                        'Read Terms of Service',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
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
                    const SizedBox(height: 24),
                    Row(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
