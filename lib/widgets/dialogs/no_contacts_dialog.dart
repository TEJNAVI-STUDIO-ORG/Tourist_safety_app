import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class NoContactsDialog extends StatefulWidget {
  const NoContactsDialog({super.key});

  @override
  State<NoContactsDialog> createState() => _NoContactsDialogState();
}

class _NoContactsDialogState extends State<NoContactsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔝 HEADER WITH TITLE AND CLOSE BUTTON
            Stack(
              children: [
                // Title - centered and bigger
                Center(
                  child: Text(
                    "❌ No Emergency Contacts",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Close button - top right
                Positioned(
                  top: -12,
                  right: -12,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📝 MESSAGE
            Text(
              "There are no contacts in the contact list. Please add them before sending a SOS",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ➕ ADD CONTACTS BUTTON
            SizedBox(
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.withOpacity(0.15),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.deepPurple.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onPressed: () {
                        final appProvider =
                            Provider.of<AppProvider>(context, listen: false);
                        Navigator.of(context, rootNavigator: true).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          appProvider.updateNavigationIndex(3);
                          appProvider.triggerAddContactBlink();
                        });
                      },
                      child: const Text(
                        "Add Contacts",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Optional: Dismiss by tapping outside hint (subtle text)
            Text(
              "Tap outside to dismiss",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
