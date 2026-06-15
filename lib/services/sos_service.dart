import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/emergency/emergency_countdown_dialog.dart';
import '../core/global.dart';
import 'sms_service.dart';
import 'notification_service.dart';

/// Service to manage SOS system status and readiness
class SosService {
  static bool _isEmergencyFlowActive = false;

  /// Check if SOS system is ready and update status
  static void checkAndUpdateSosStatus({
    required SystemStatusProvider statusProvider,
    required SettingsProvider settingsProvider,
  }) {
    final bool hasContacts = settingsProvider.contacts.isNotEmpty;
    final bool hasValidMessage = _isValidSosMessage(settingsProvider.sosMessageTemplate);
    final bool isReady = hasContacts && hasValidMessage;
    final bool pushEnabled = settingsProvider.pushNotifications || settingsProvider.smsAlerts;

    statusProvider.updateSOS(isReady);
    statusProvider.updateSosDetails(
      ready: isReady,
      contactCount: settingsProvider.contacts.length,
      messageValid: hasValidMessage,
    );

    String sosState = isReady ? 'READY' : 'NOT READY';
    String pushState = pushEnabled ? 'ACTIVE' : 'DISABLED';
    String statusMessage = 'Push Alerts: $pushState | SOS: $sosState';

    if (!isReady) {
      String reason = '';
      if (!hasContacts) reason += 'No contacts';
      if (!hasValidMessage) {
        if (reason.isNotEmpty) reason += ', ';
        reason += 'Invalid or missing message template';
      }
      statusMessage += ' ($reason)';
    }

    statusProvider.updateNotifications(
      active: pushEnabled,
      status: statusMessage,
    );
  }
  
  /// Validate SOS message template
  static bool _isValidSosMessage(String message) {
    return message.isNotEmpty && 
           message.trim().length > 10 &&
           (message.contains("{location}") || message.toLowerCase().contains("location"));
  }
  
  /// Get SOS readiness details
  static Map<String, dynamic> getSosReadiness({
    required SettingsProvider settingsProvider,
  }) {
    final bool hasContacts = settingsProvider.contacts.isNotEmpty;
    final bool hasValidMessage = _isValidSosMessage(settingsProvider.sosMessageTemplate);
    final bool isReady = hasContacts && hasValidMessage;
    
    return {
      'isReady': isReady,
      'hasContacts': hasContacts,
      'contactCount': settingsProvider.contacts.length,
      'hasValidMessage': hasValidMessage,
      'messageLength': settingsProvider.sosMessageTemplate.length,
      'message': settingsProvider.sosMessageTemplate,
    };
  }
  
  /// Unified emergency flow with countdown dialog
  static Future<void> triggerEmergencyFlow({
    required BuildContext context,
    required String reason,
    int countdownSeconds = 30,
    VoidCallback? onSafe,
    VoidCallback? onLeaveZone,
  }) async {
    if (_isEmergencyFlowActive) return;
    _isEmergencyFlowActive = true;

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final statusProvider = Provider.of<SystemStatusProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => EmergencyCountdownDialog(
        title: "Emergency Alert",
        message: "We detected a $reason. Sending SOS in $countdownSeconds seconds if no response.",
        countdownSeconds: countdownSeconds,
        onLeaveZone: onLeaveZone,
        onEmergency: () async {
          _isEmergencyFlowActive = false;
          // Refresh location before sending
          await locationProvider.getCurrentLocation();
          await triggerSOS(
            statusProvider: statusProvider,
            settingsProvider: settingsProvider,
          );
        },
        onSafe: () {
          _isEmergencyFlowActive = false;
          if (onSafe != null) onSafe();
        },
      ),
    );
  }

  /// Trigger SOS and update status
  static Future<bool> triggerSOS({
    required SystemStatusProvider statusProvider,
    required SettingsProvider settingsProvider,
    String? customMessage,
  }) async {
    try {
      // Update status to show SOS is being sent
      statusProvider.updateNotifications(
        active: true, 
        status: "Sending SOS..."
      );
      
      final recipients = settingsProvider.contacts
          .map((contact) => contact.phone)
          .toList();
      
      String message = customMessage ?? settingsProvider.sosMessageTemplate;
      
      // Inject location if placeholder exists
      final ctx = navigatorKey.currentContext;
      if (message.contains("{location}")) {
        if (ctx != null) {
          final lp = Provider.of<LocationProvider>(ctx, listen: false);
          final locationText = "https://maps.google.com/?q=${lp.latitude},${lp.longitude}";
          message = message.replaceAll("{location}", locationText);
        }
      }
      
      final success = await SmsService.sendSOS(
        recipients: recipients,
        message: message,
      );
      
      if (success) {
        statusProvider.updateNotifications(
          active: true, 
          status: "SOS Sent Successfully"
        );

        // Send local push notification
        await NotificationService.showNotification(
          title: "🚨 SOS Alert Sent",
          body: "Emergency message has been sent to ${recipients.length} contacts.",
        );

        // Add to notification provider (Alert Center & Emergency Screen)
        if (ctx != null) {
          final lp = Provider.of<LocationProvider>(ctx, listen: false);
          Provider.of<NotificationProvider>(ctx, listen: false).addNotification(
            title: "Emergency SOS Sent",
            body: "Sent to ${recipients.length} contacts. Location: ${lp.latitude}, ${lp.longitude}",
            type: "emergency",
          );
        }
      } else {
        statusProvider.updateNotifications(
          active: false, 
          status: "SOS Failed - Check permissions"
        );
      }
      
      return success;
    } catch (e) {
      statusProvider.updateNotifications(
        active: false, 
        status: "SOS Error: ${e.toString()}"
      );
      return false;
    }
  }
}
