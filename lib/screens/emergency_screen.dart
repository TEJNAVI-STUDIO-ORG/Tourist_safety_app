import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/notification_provider.dart';

import '../services/sms_service.dart';
import '../services/sos_service.dart';

class EmergencyScreen
    extends StatefulWidget {

  const EmergencyScreen({
    super.key,
  });

  @override
  State<EmergencyScreen>
      createState() =>
          _EmergencyScreenState();
}

class _EmergencyScreenState
    extends State<EmergencyScreen> with SingleTickerProviderStateMixin {

  late TextEditingController
      messageController;
  
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {

    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final settingsProvider =
        Provider.of<SettingsProvider>(

      context,
      listen: false,
    );

    messageController =
        TextEditingController(

      text:
          settingsProvider
              .sosMessageTemplate,
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final settingsProvider =
        Provider.of<SettingsProvider>(
      context,
    );

    final locationProvider =
        Provider.of<LocationProvider>(
      context,
    );

    final statusProvider =
        Provider.of<SystemStatusProvider>(
      context,
    );

    final contacts =
        settingsProvider.contacts;

    final notificationProvider = Provider.of<NotificationProvider>(context);
    final emergencyAlerts = notificationProvider.allNotifications
        .where((n) => n.type == 'emergency' || n.type == 'fall')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTemplateSheet(context, settingsProvider),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🚨 BIG SOS
            const SizedBox(height: 20),
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await locationProvider.getCurrentLocation();
                      await SosService.triggerSOS(
                        statusProvider: statusProvider,
                        settingsProvider: settingsProvider,
                        customMessage: messageController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(70),
                      elevation: 8,
                      shadowColor: Colors.redAccent,
                    ),
                    child: const Text(
                      "SOS",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // 📞 CONTACTS
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency Contacts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "These contacts will receive your SOS message and location.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
              ],
            ),

            const SizedBox(height: 10),

            contacts.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(30),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No contacts found. Please add them in Settings to enable SOS.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            child: const Icon(Icons.person, color: Colors.red),
                          ),
                          title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(contact.phone),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.green),
                                onPressed: () => SmsService.makeCall(contact.phone),
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Colors.blue),
                                onPressed: () => SmsService.openSMS(
                                  phone: contact.phone,
                                  message: "Hey, I need help.",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 30),

            // 📢 RECENT ALERTS
            if (emergencyAlerts.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Emergency Alerts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: emergencyAlerts.length > 5 ? 5 : emergencyAlerts.length,
                itemBuilder: (context, index) {
                  final alert = emergencyAlerts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 1),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.warning, color: Colors.white, size: 20),
                      ),
                      title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${alert.body}\n${timeago.format(alert.time)}"),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  void _showTemplateSheet(BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SOS Message Template",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Customize your message below. Save after editing.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write SOS message...",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  settingsProvider.saveSOSTemplate(messageController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template saved successfully")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("SAVE TEMPLATE"),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 📍 TOKEN INFO (NORMAL COLOR)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(text: "Use "),
                          TextSpan(
                            text: "{location}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: " to include your live coordinates."),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
