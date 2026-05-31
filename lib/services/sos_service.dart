import '../providers/system_status_provider.dart';
import '../providers/settings_provider.dart';
import 'sms_service.dart';

/// Service to manage SOS system status and readiness
class SosService {
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
  
  /// Trigger SOS and update status
  static Future<bool> triggerSOS({
    required SystemStatusProvider statusProvider,
    required SettingsProvider settingsProvider,
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
      
      final message = settingsProvider.sosMessageTemplate;
      
      final success = await SmsService.sendSOS(
        recipients: recipients,
        message: message,
      );
      
      if (success) {
        statusProvider.updateNotifications(
          active: true, 
          status: "SOS Sent Successfully"
        );
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
