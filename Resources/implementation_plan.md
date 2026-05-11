# Native Silent SMS + Background Fall Detection

## Summary

Two native Android features to add true silent SMS and always-on fall detection:

1. **Silent SMS** — The `MainActivity.kt` already has `SmsManager.sendTextMessage()` wired to a `MethodChannel`, but the Dart `SmsService` still uses `url_launcher`. We just need to update the Dart side to call the channel instead, handle long messages (multipart), and add a graceful fallback.

2. **Background Fall Detection** — The existing `AdvancedFallDetectionService` runs in the Flutter UI isolate. When the app is killed, sensors die. We need a native Android `ForegroundService` that uses the hardware `TYPE_ACCELEROMETER` sensor, communicates detected falls back to Flutter via a `MethodChannel` (when app is alive) or SharedPreferences + notification (when killed).

---

## What Already Exists (Good News)

| Component | Status |
|---|---|
| `SEND_SMS` permission in `AndroidManifest.xml` | ✅ Already there |
| `SmsManager` call in `MainActivity.kt` (`sms_channel`) | ✅ Already there |
| `flutter_background_service` foreground service | ✅ Already running |
| `sensors_plus` dependency | ✅ Already in pubspec |
| `FOREGROUND_SERVICE` permission | ✅ Already declared |
| `WAKE_LOCK` permission | ✅ Already declared |

---

## Feature 1 — True Silent SMS

### Problem
`SmsService.dart` still calls `url_launcher` (opens SMS app). `MainActivity.kt` already has the native channel but Dart never calls it.

### Fix — Dart Only

#### [MODIFY] [sms_service.dart](file:///e:/Adi_32GR_files/MyCodingHelper/Projects/Multi_lang/Tourist_safety_app/lib/services/sms_service.dart)

- Remove `url_launcher` import
- Add `flutter/services.dart` for `MethodChannel`
- Replace `sendSOS` to call `sms_channel/sendSMS` via MethodChannel
- Long messages (>160 chars) are sent multi-part — handle in Kotlin

#### [MODIFY] [MainActivity.kt](file:///e:/Adi_32GR_files/MyCodingHelper/Projects/Multi_lang/Tourist_safety_app/android/app/src/main/kotlin/com/example/tourist_safety_app/MainActivity.kt)

- Switch from `sendTextMessage` to `sendMultipartTextMessage` (divides message into multiple parts automatically if > 160 chars)
- Add `@SuppressLint("MissingPermission")` guard with try/catch
- Use `SmsManager.createForSubscriptionId` on API 31+ for reliability

---

## Feature 2 — Background Fall Detection via Native Foreground Service

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Android Native Layer                                   │
│                                                         │
│  FallDetectionService.kt (ForegroundService)            │
│    ├── SensorManager → TYPE_ACCELEROMETER               │
│    ├── Fall algorithm (free-fall + impact detection)    │
│    ├── When app alive: MethodChannel → Flutter          │
│    └── When app killed: SharedPreferences + Notification│
└─────────────────────────────────────────────────────────┘
          ↕  MethodChannel("fall_detection_channel")
┌─────────────────────────────────────────────────────────┐
│  Flutter Layer                                          │
│                                                         │
│  NativeFallBridge.dart                                  │
│    ├── Listens to MethodChannel from native service     │
│    ├── Shows fall dialog if app is active               │
│    └── Stops/starts native service                      │
│                                                         │
│  AdvancedFallDetectionService.dart (existing)           │
│    └── Delegates to NativeFallBridge instead of sensors │
└─────────────────────────────────────────────────────────┘
```

### Files

#### [NEW] `android/.../FallDetectionService.kt`
- Extends `Service` (not Activity)
- `startForeground()` with a low-priority sticky notification
- Registers `SensorManager.registerListener` for `TYPE_ACCELEROMETER`
- Fall algorithm identical to current Dart logic:
  - magnitude < 2.0 → free-fall timestamp
  - magnitude > 25 within 1500ms → possible impact
  - 4s immobility check after impact
  - If still → send fall event
- **When app alive**: calls `MethodChannel` → Flutter shows dialog
- **When app killed**: writes `fall_pending=true` to `SharedPreferences`, posts a high-priority `NotificationManager` notification with "I'm Safe" action

#### [MODIFY] `AndroidManifest.xml`
- Register `FallDetectionService` with `foregroundServiceType="health|sensors"` 
- Add `FOREGROUND_SERVICE_HEALTH` and `FOREGROUND_SERVICE_SENSORS` permissions (API 34+)
- Register `BootReceiver` to restart the service after device reboot

#### [NEW] `android/.../FallBootReceiver.kt`
- `BroadcastReceiver` that starts `FallDetectionService` on `BOOT_COMPLETED`

#### [NEW] `lib/services/native_fall_bridge.dart`
- Dart wrapper: `startNativeService()`, `stopNativeService()`
- Subscribes to `fall_detection_channel` MethodChannel
- On `fallDetected` message → delegates to existing `_showFallDialog()` + countdown

#### [MODIFY] `lib/services/advanced_fall_detection_service.dart`
- `initialize()` now starts the native service via `NativeFallBridge`
- Keeps the Dart-side sensor listener as a **secondary fallback only** (when app is in foreground)
- `dispose()` stops native service

#### [MODIFY] `lib/main.dart`
- Import `NativeFallBridge`; in `initState` call `NativeFallBridge.initialize(context)` instead of raw `AdvancedFallDetectionService.initialize()`

---

## Permissions to Add

```xml
<!-- For FallDetectionService (API 34+) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_HEALTH"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
<uses-permission android:name="android.permission.HIGH_PRIORITY_WAKEUP"/>
```

---

## Verification Plan

### Automated
- `flutter analyze` — no new lint errors
- `flutter build apk --debug` — builds cleanly

### Manual
1. **Silent SMS**: Trigger SOS → messages appear in sent box without any app opening.
2. **Background fall**: Swipe app away → simulate drop (shake phone hard) → notification appears with "I'm Safe" action.
3. **Foreground fall**: App open → simulate fall → countdown dialog appears as before.
4. **Boot**: Restart device → notification bar still shows "Fall Detection Active".

---

## Open Questions

> [!IMPORTANT]
> **Android 14 (API 34)** added strict `foregroundServiceType` enforcement. The fall service will use `health` or `dataSync`. On older devices (<API 34) this still works fine. Should I target API 34+ only, or add backward-compatible fallback?

> [!NOTE]
> The native fall service will show a **persistent notification** (e.g. "TouriSafe — Fall Detection Active") while running. This is required by Android — it cannot be hidden. Is this acceptable UX, or should it be merged with the existing `Guardian Pulse` location notification?
