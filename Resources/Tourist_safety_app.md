# Smart Tourist Safety & Tracking System

## Table of Contents

- [Product Overview](#product-overview)
- [MVP Feature List](#mvp-feature-list)
- [Technical Stack](#technical-stack)
- [API / Integration List](#api--integration-list)
- [Folder Structure (Flutter)](#folder-structure-flutter)
- [Data Model Idea](#data-model-idea)
- [Core User Flow](#core-user-flow)
- [Functional Requirements](#functional-requirements)
- [Non-Functional Requirements](#non-functional-requirements)
- [Risks and Mitigations](#risks-and-mitigations)
- [Similar Existing Solutions](#similar-existing-solutions)
- [Success Metrics](#success-metrics)
- [Pros, Cons, Flaws, and Fixes](#pros-cons-flaws-and-fixes)

## Product Overview

### Product Name

**Smart Tourist Safety & Tracking System**

### Product Vision

A mobile app that helps tourists stay safe by combining **live tracking, geofencing, emergency alerts, and IoT-based device monitoring** in one dashboard.

> "A Flutter-based tourist safety system that combines live location tracking, Firebase-backed IoT data sync, geofence warnings, and emergency SOS support."

### Problem Statement

Tourists often travel in unfamiliar places and may face:

- Getting lost
- Entering unsafe zones
- Device failure
- Delayed help during emergencies

This app reduces that risk by showing live location, detecting danger zones, and sending emergency alerts quickly.

### Target Users

- Tourist / traveler
- Family member / emergency contact

### Core Goals

- Track user location in real time
- Detect danger zones using geofencing
- Send SOS alerts instantly
- Alert user when entering predefined danger zones
- Read IoT device data from Firebase
- One-tap SOS emergency messaging
- Show device status, battery, and fall alerts (data read from Firebase)
- Support privacy mode

## MVP Feature List

### Must-Have

- Google Maps live screen
- Current location tracking
- Firebase Realtime Database integration
- Device status online/offline
- SOS button with emergency contact
- Geofence alert zones
- Privacy mode toggle

### Should-Have

- Battery level display
- Fall detection alert from device
- Push notifications
- Emergency contact list

### Nice-to-Have

- History of alerts
- Safe zone routing
- Multi-language support
- Admin dashboard

---

## Technical Stack

### Mobile App

| Component              | Technology / Library                  | Purpose                                      |
|------------------------|--------------------------------------|----------------------------------------------|
| Mobile Framework       | Flutter                              | Cross-platform app development              |
| Maps Integration       | Google Maps Flutter                  | Display interactive maps and markers        |
| Location Services      | geolocator                           | Get current location and track movement     |
| Permissions Handling   | permission_handler                   | Manage app permissions (location, SMS)      |
| Notifications          | flutter_local_notifications          | Local push notifications for alerts         |
| SMS / SOS              | flutter_sms                          | Send emergency SMS messages                 |
| Background Tracking    | Platform channels / background_fetch | Handle location updates in background       |
| State Management       | Provider                             | Manage app state (location, device data)    |
| UI Framework           | Material Design / Cupertino          | Consistent UI components                    |

### Backend / Sync

| Component              | Technology / Service                 | Purpose                                      |
|------------------------|--------------------------------------|----------------------------------------------|
| Realtime Database      | Firebase Realtime Database           | Store and sync device data in real-time     |
| Authentication         | Firebase Authentication              | User login and session management            |
| Push Notifications     | Firebase Cloud Messaging             | Send push alerts to app                     |
| SMS Service            | Twilio / Firebase Functions          | Send emergency SMS to contacts              |
| Data Sync              | Firebase SDK                         | Real-time data synchronization               |

### Hardware

| Component              | Technology / Module                  | Purpose                                      |
|------------------------|--------------------------------------|----------------------------------------------|
| Microcontroller        | ESP32 / Arduino                      | Main processing unit for IoT device          |
| GPS Module             | GPS Receiver (e.g., NEO-6M)          | Location tracking and coordinates           |
| Accelerometer          | MPU-6050 / ADXL355                   | Fall detection and motion sensing           |
| Battery Monitoring     | Voltage divider / ADC                | Monitor battery level                       |
| Connectivity           | WiFi / Cellular (SIM800L)            | Send data to Firebase                       |
| Power Management       | Battery + regulator                  | Efficient power usage                       |

## API / Integration List

For a clean v1, use these:

1. **Google Maps API / Geofencing API**

   - Show map
   - Render markers
   - Draw geofence zones
2. **Firebase Realtime Database**

   - ESP32/Arduino connects to Firebase to send real-time data to fetch latitude and longitude
   - Receive GPS coordinates
   - Receive fall status

   > "Firebase is used as a real-time intermediary between the IoT device and the mobile app to ensure scalable, asynchronous communication."
   >
3. **SMS to pre-selected emergency contacts**

   - Push SOS and location via SMS (with a message)

### Integration Flow

```
ESP32 → Firebase → Flutter App
             ↓
        Geofence Logic
             ↓
        Alert / Notification
             ↓
        SOS → SMS
```

## Folder Structure (Flutter)

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── colors.dart                # Color palette
│   │   └── strings.dart               # Localized strings
│   ├── themes/
│   │   ├── app_theme.dart             # Light/dark theme definitions
│   │   └── text_styles.dart           # Text style constants
│   └── utils/
│       ├── date_formatter.dart        # Date/time utilities
│       ├── location_utils.dart        # Location helper functions
│       └── permission_utils.dart      # Permission handling utilities
├── services/
│   ├── firebase_service.dart          # Firebase database operations
│   ├── location_service.dart          # Location tracking and geofencing
│   ├── geofence_service.dart          # Geofence zone management
│   ├── sms_service.dart               # Emergency SMS sending
│   ├── notification_service.dart      # Local notifications
│   └── background_service.dart        # Background location updates
├── models/
│   ├── user_model.dart                # User data model
│   ├── device_model.dart              # IoT device data model
│   ├── location_model.dart            # Location data model
│   ├── geofence_model.dart            # Geofence zone model
│   ├── alert_model.dart               # Alert/notification model
│   └── contact_model.dart             # Emergency contact model
├── providers/
│   ├── app_provider.dart              # Main app state provider
│   ├── location_provider.dart         # Location state management
│   ├── device_provider.dart           # Device data provider
│   └── settings_provider.dart         # App settings provider
├── screens/
│   ├── dashboard_screen.dart          # Main dashboard/home screen
│   ├── map_screen.dart                # Full tracking map screen
│   ├── emergency_screen.dart          # SOS and emergency contacts
│   └── settings_screen.dart           # Configuration and settings
├── widgets/
│   ├── common/
│   │   ├── app_header.dart            # Top app bar with title and icon
│   │   ├── bottom_navigation.dart     # Bottom tab navigation
│   │   └── loading_indicator.dart     # Loading spinner
│   ├── dashboard/
│   │   ├── device_status_card.dart    # Device online/offline status
│   │   ├── battery_level_bar.dart     # Battery percentage display
│   │   ├── map_preview.dart           # Small map preview widget
│   │   └── private_mode_toggle.dart   # Tracking on/off switch
│   ├── map/
│   │   ├── full_map_view.dart         # Full screen map component
│   │   ├── danger_zone_marker.dart    # Danger zone visualization
│   │   ├── location_marker.dart       # Current location pin
│   │   └── safety_status_card.dart    # Safety status indicator
│   ├── emergency/
│   │   ├── sos_button.dart            # Large emergency button
│   │   ├── contact_list.dart          # Emergency contacts display
│   │   ├── call_button.dart           # Direct call button
│   │   └── sms_button.dart            # SMS send button
│   └── settings/
│       ├── theme_setting.dart         # Light/dark mode selector
│       ├── contact_section.dart       # Emergency contacts management
│       ├── device_pairing.dart        # IoT device connection
│       ├── alert_preferences.dart     # Notification settings
│       └── api_config.dart            # Firebase/API settings
├── config/
│   ├── firebase_config.dart           # Firebase configuration
│   └── api_keys.dart                  # API keys and secrets
└── assets/
    ├── images/                       # App images and icons
    │   ├── icons/
    │   └── wireframes/               # Wireframe screenshots
    └── fonts/                        # Custom fonts if needed
```

## Data Model Idea

### Firebase Nodes

- `/users/{userId}`
- `/devices/{deviceId}`
- `/devices/{deviceId}/location`
- `/devices/{deviceId}/battery`
- `/devices/{deviceId}/fall`
- `/geofences/{zoneId}`
- `/alerts/{alertId}`
- `/contacts/{userId}`

### Example JSON Structure

```json
{
  "users": {
    "user_001": {
      "name": "Rahul",
      "email": "[rahul@email.com](mailto:rahul@email.com)",
      "deviceId": "device_001",
      "createdAt": 1710000000
    }
  },
  "devices": {
    "device_001": {
      "meta": {
        "name": "Tourist Device 1",
        "assignedUser": "user_001"
      },
      "state": {
        "online": true,
        "lastUpdated": 1710000000
      },
      "location": {
        "lat": 18.5204,
        "lng": 73.8567,
        "accuracy": 10,
        "timestamp": 1710000000
      },
      "battery": {
        "level": 78,
        "charging": false,
        "timestamp": 1710000000
      },
      "fall": {
        "detected": false,
        "lastFallTime": null
      }
    }
  },
  "geofences": {
    "zone_001": {
      "name": "Danger Area",
      "type": "danger",
      "center": {
        "lat": 18.52,
        "lng": 73.85
      },
      "radius": 200,
      "createdAt": 1710000000
    }
  },
  "alerts": {
    "alert_001": {
      "deviceId": "device_001",
      "userId": "user_001",
      "type": "geofence",
      "message": "Entered danger zone",
      "location": {
        "lat": 18.5204,
        "lng": 73.8567
      },
      "timestamp": 1710000000,
      "status": "active"
    }
  },
  "contacts": {
    "user_001": {
      "primary": {
        "name": "Parent",
        "phone": "+911234567890"
      },
      "secondary": {
        "name": "Friend",
        "phone": "+919876543210"
      }
    }
  }
}
```

## Core User Flow

### Tourist Flow

1. Open app
2. See live location on map
3. View device status
4. Enter or leave danger zone
5. Get alert if needed
6. Press SOS if emergency happens
7. Send location to emergency contact

### Device Flow

1. ESP32 reads GPS / accelerometer / battery
2. Pushes data to Firebase
3. App listens in real-time
4. Dashboard updates instantly

## Functional Requirements

- App must show the user's current location
- App must fetch hardware coordinates from Firebase
- App must mark danger zones on the map
- App must trigger alert when user enters zone
- App must allow SOS with one tap
- App must show device online/offline state
- App must show battery percentage
- App must allow private mode toggle
- App must receive fall detection alerts

## Non-Functional Requirements

- Fast response time for alerts
- Low battery usage
- Secure Firebase rules
- Reliable background updates
- Clear UI
- Works on Android and iOS if possible
- Graceful handling when location or internet fails

## Risks and Mitigations

### Risk: False Alerts

**Mitigation:** Add delay and confirmation logic.

### Risk: GPS Drift

**Mitigation:** Use accuracy checks and smooth updates.

### Risk: Firebase Misuse

**Mitigation:** Clean schema and strict security rules.

### Risk: Too Many Permissions

**Mitigation:** Ask permissions only when needed.

### Risk: Hardware Disconnects

**Mitigation:** Show stale data clearly and keep app usable.

---

## Similar Existing Solutions

### Research-Level "Smart Tourist Safety Systems"

- There are papers like "AI-Powered Smart Tourist Safety System with Geo-Fencing and Blockchain Identity"
- These focus on:
  - Tourist risk detection
  - Geofencing alerts
  - Identity + safety tracking
- **BUT:** Mostly theoretical / research-heavy, not practical mobile apps ([ResearchGate](https://www.researchgate.net/publication/400194378_AI-Powered_Smart_Tourist_Safety_System_with_Geo-Fencing_and_Blockchain_Identity?utm_source=chatgpt.com))

### Smart Tourist Apps (Maps + Firebase)

They use:

- Google Maps APIs
- Firebase (Auth, DB, Messaging)
- GPS + real-time data ([ResearchGate](https://www.researchgate.net/publication/362209331_Smart_Tourist_Guide_Mobile_Application?utm_source=chatgpt.com))

**BUT:**

- Focus = **Tourism info (hotels, guides, routes)**
- NOT safety + IoT + SOS combo

### Geofencing Apps (Closest Match Technically)

- Example project: GeoAssistant geofence reminder app

Features:

- Map + geofence
- Notification on entering area
- Firebase + Google Maps integration ([GitHub](https://github.com/AliElDerawi/GeoAssistant?utm_source=chatgpt.com))

**BUT:**

- Only reminders (like "buy milk here")
- No:
  - IoT device
  - SOS system
  - Fall detection
  - Emergency contacts

### IoT + Firebase Tracking Systems

- Systems exist using:
  - Sensors (Raspberry Pi / ESP32)
  - Database real-time updates
  - Alert notifications ([Google Maps Platform](https://mapsplatform.google.com/resources/blog/iot-proof-geolocation-and-firebase21?utm_source=chatgpt.com))

**BUT:**

- Mostly **home security / intrusion detection**
- Not mobile tourist tracking

---

- Devices can be inaccurate (GPS drift) ([Android Developers](https://developer.android.com/training/location/geofencing?utm_source=chatgpt.com))

---

## Success Metrics

- Location update appears within a few seconds
- SOS alert reaches contact reliably
- Geofence alert fires correctly
- Device status reflects actual hardware state
- App remains stable during background use

---

## Pros, Cons, Flaws, and Fixes


| Part                         | Good Thing                         | Flaw / Risk                                                 | How to Fix It                                                                    |
| ---------------------------- | ---------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Live map tracking            | Very practical and easy to demo    | GPS can be inaccurate indoors or in crowded places          | Show last known location, accuracy radius, and update only when movement changes |
| Geofencing danger zones      | Strong safety feature              | Circle-based geofences can create false alerts              | Use dwell time, buffer zones, and allow manual zone editing                      |
| Firebase realtime sync       | Fast to build, great for live data | Security rules and data structure can get messy             | Design clean database nodes and lock down rules from day 1                       |
| SOS button                   | Easy to understand and useful      | SMS may fail if permissions/network are bad                 | Add fallback to phone call, push alert, and shareable live link                  |
| Fall detection               | Makes the app feel "smart"         | False positives are common                                  | Use threshold + delay + cancel timer before sending alert                        |
| Device online/offline status | Helpful for monitoring             | Can confuse users if the device is just temporarily delayed | Show "last updated time" and connection lag clearly                              |
| Battery level display        | Good dashboard detail              | Needs hardware support and stable data                      | Treat it as a read-only hardware value, not a core app dependency                |
| Private mode toggle          | Good for privacy                   | If handled badly, it can kill the safety purpose            | Make it "pause tracking" with clear warning, not silent disabling                |

### Main Flaws in the Project Idea

1. **Too many features at once**

   - If you try to build everything, the project becomes unstable.
   - **Fix:** Separate into MVP and future versions.
2. **GPS accuracy issues**

   - Location can drift, especially in cities or indoors.
   - **Fix:** Use accuracy filtering, update throttling, and last known position display.
3. **False emergency alerts**

   - Fall detection and geofence alerts can misfire.
   - **Fix:** Add debounce logic, confirmation delays, and user cancel options.
4. **Internet dependence**

   - Firebase and maps need connectivity.
   - **Fix:** Cache last data locally and keep SOS fallback options.
5. **Privacy concerns**

   - Users need to trust the app.
   - **Fix:** Clear consent, visible tracking status, and a real private mode.
6. **Hardware dependency**

   - If ESP32/Arduino fails, the app should still work partially.
   - **Fix:** Make the mobile app usable even without IoT input.
