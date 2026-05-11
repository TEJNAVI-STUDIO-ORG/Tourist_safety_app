import 'package:flutter/material.dart';

class TermsScreen
    extends StatelessWidget {

  const TermsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Terms & Services",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: const Text(

          "Terms & Services\n\n"

          "TouristSafe is intended to assist "
          "users during travel and emergency "
          "situations.\n\n"

          "The app should not be considered "
          "a replacement for official emergency "
          "services.\n\n"

          "Users are responsible for enabling "
          "permissions required for proper "
          "functionality.\n\n"

          "TouristSafe developers are not "
          "liable for failures caused by "
          "network issues, device problems, "
          "or denied permissions.\n\n"

          "By using TouristSafe, you agree "
          "to these terms.",

          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
