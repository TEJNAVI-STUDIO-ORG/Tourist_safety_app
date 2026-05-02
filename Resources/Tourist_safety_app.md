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

A mobile app that helps tourists stay safe by combining **live tracking, geofencing, and emergency alerts** in one dashboard.

> "A Flutter-based tourist safety system that combines live location tracking, geofencing warnings, and emergency SOS support."

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
- One-tap SOS emergency messaging
- Support privacy mode

## MVP Feature List

### Must-Have

- Google Maps live screen
- Current location tracking
- SOS button with emergency contact
- Geofence alert zones
- Privacy mode toggle

### Should-Have

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

### Persistence

| Component              | Technology / Service                 | Purpose                                      |
|------------------------|--------------------------------------|----------------------------------------------|
| Local Storage          | shared_preferences / hive / sqflite  | Persist settings, alerts, and cached data    |
| Notifications          | flutter_local_notifications          | Local alerts and reminders                   |
| SMS Service            | flutter_sms                          | Send emergency SMS to contacts               |
                       |

## API / Integration List

For a clean v1, use these:

1. **Google Maps API / Geofencing API**

   - Show map
   - Render markers
   - Draw geofence zones
2. **Local Device Storage**

   - Persist geofence settings, emergency contacts, and alert history on-device
   - Cache current location and app state for offline use
   - Keep data local and reduce cloud dependency

3. **SMS to pre-selected emergency contacts**

   - Push SOS and location via SMS (with a message)

### Integration Flow

```
Flutter App → Local Storage → UI / Alerts
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
│   ├── constants/                     # App constants and themes
│   ├── themes/                        # Theme and text styles
│   └── utils/                         # Helper utilities
├── services/                          # Local storage, location, SMS, notifications
├── models/                            # Data models (location, geofence, contacts)
├── providers/                         # State management providers
├── screens/                           # App screens (dashboard, map, emergency, settings)
├── widgets/                           # Reusable UI components
├── config/                            # API and app configuration
└── assets/                            # Images and wireframes
Resources/
├── Tourist_safety_app.md              # Product requirements document
├── Wireframing_doc.md                 # Wireframe specifications
└── smart_tourist_safety_system/       # Wireframe HTML and screenshot files
```

## Data Model Idea

## Local Storage Model

Use on-device storage for:

- User settings and emergency contacts
- Geofence zones and alert rules
- Cached location and recent alert history

Example local data model:

- `settings`
- `contacts`
- `geofences`
- `alerts`
- `location_cache`

## Core User Flow

### Tourist Flow

1. Open app
2. See live location on map
3. View current safety status
4. Enter or leave danger zone
5. Get alert if needed
6. Press SOS if emergency happens
7. Send location to emergency contact

### App Flow

1. Open the app and request location permission
2. Cache the latest location and geofence data locally
3. Update the dashboard from local state
4. Trigger alerts based on geofence logic
5. Send SOS via SMS if needed

## Functional Requirements

- App must show the user's current location
- App must mark danger zones on the map
- App must trigger alert when user enters a zone
- App must allow SOS with one tap
- App must allow private mode toggle
- App must persist emergency contacts and settings locally

## Non-Functional Requirements

- Fast response time for alerts
- Low battery usage
- Secure local data storage
- Reliable background updates
- Clear UI
- Works on Android and iOS if possible
- Graceful handling when location or internet fails

## Risks and Mitigations

### Risk: False Alerts

**Mitigation:** Add delay and confirmation logic.

### Risk: GPS Drift

**Mitigation:** Use accuracy checks and smooth updates.

### Risk: Local Storage Misuse

**Mitigation:** Validate data formats and encrypt sensitive on-device values.

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

### Smart Tourist Apps (Maps)

They use:

- Google Maps APIs
- GPS + real-time data ([ResearchGate](https://www.researchgate.net/publication/362209331_Smart_Tourist_Guide_Mobile_Application?utm_source=chatgpt.com))

**BUT:**

- Focus = **Tourism info (hotels, guides, routes)**
- NOT safety + SOS combo

### Geofencing Apps (Closest Match Technically)

- Example project: GeoAssistant geofence reminder app

Features:

- Map + geofence
- Notification on entering area
- Google Maps integration ([GitHub](https://github.com/AliElDerawi/GeoAssistant?utm_source=chatgpt.com))

**BUT:**

- Only reminders (like "buy milk here")
- No:
  - SOS system
  - Fall detection
  - Emergency contacts

### Offline Geolocation Tracking Systems

- Systems exist using:
  - Sensors and local processing
  - Local persistence for cached location
  - Alert notifications (Google Maps Platform resource)

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
- Status reflects current app state
- App remains stable during background use

---

## Pros, Cons, Flaws, and Fixes


| Part                         | Good Thing                         | Flaw / Risk                                                 | How to Fix It                                                                    |
| ---------------------------- | ---------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Live map tracking            | Very practical and easy to demo    | GPS can be inaccurate indoors or in crowded places          | Show last known location, accuracy radius, and update only when movement changes |
| Geofencing danger zones      | Strong safety feature              | Circle-based geofences can create false alerts              | Use dwell time, buffer zones, and allow manual zone editing                      |
| Local persistence            | Fast to build and reliable when cached | Data model and storage format must stay simple            | Use a clean local model and cache only what the app needs |
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

   - Maps need connectivity.
   - **Fix:** Cache last data locally and keep SOS fallback options.
5. **Privacy concerns**

   - Users need to trust the app.
   - **Fix:** Clear consent, visible tracking status, and a real private mode.
6. **Hardware dependency**

   - If external sensors fail, the app should still work partially.
   - **Fix:** Make the mobile app usable even without external input.
