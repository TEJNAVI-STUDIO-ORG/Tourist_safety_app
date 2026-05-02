# TouristSafe - Smart Tourist Safety & Tracking System

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)

A comprehensive Flutter mobile app for real-time tourist safety. The app uses live location tracking, geofencing alerts, emergency SOS, and local persistence to keep tourists secure.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technical Stack](#technical-stack)
- [Current Requirements](#current-requirements)
- [Current Progress/Status](#current-progressstatus)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [API & Integrations](#api--integrations)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)
- [Screenshots](#screenshots)

## Overview

This repository contains the TouristSafe app, a product focused on improving tourist safety through a mobile app. It is designed to be fully cross-platform with Flutter, using local device storage and direct app state management.

## Features

### Core MVP

- Real-time Google Maps location tracking
- SOS button with emergency SMS routing
- Geofencing danger alerts with map visualization
- Privacy mode toggle
- Emergency contact management

### Should-Have

- Push notifications for alerts

### Nice-to-Have

- History of alerts
- Safe zone routing
- Multi-language support
- Admin dashboard

## Technical Stack

| Area | Technology | Purpose |
|------|------------|---------|
| Mobile | Flutter | Cross-platform app development |
| Maps | Google Maps Flutter | Interactive map display |
| Location | geolocator | GPS and location tracking |
| Permissions | permission_handler | Manage location and SMS permissions |
| Notifications | flutter_local_notifications | Local alert notifications |
| SMS | flutter_sms | Send emergency SMS messages |
| Persistence | shared_preferences / hive | Local storage for app state and cached data |

## Current requirements

The current requirements of TouristSafe are to create a minimum viable product that proves a real-time safety workflow: live location tracking, geofence warnings, emergency SOS, and local persistence.

## Current Progress/status

- Product requirements and technical stack documented
- Wireframes completed for dashboard, map, emergency, and settings
- Local storage and persistence design defined
- Initial Flutter folder structure and feature layout drafted
- SMS, geofencing, and Google Maps integration identified as core areas

If you want, I can also merge this directly into README.md and update the table of contents.

## Project Structure

```
.
├── android/                           # Android platform project and Gradle build files
│   ├── app/
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   └── settings.gradle.kts
├── lib/                               # Flutter Dart application code
│   ├── main.dart                      # App entry point
│   ├── firebase_options.dart          # Generated Firebase config helper (legacy)
│   ├── config/                        # App configuration files
│   │   └── api_keys.dart              # Google Maps API key and app settings
│   ├── core/                          # App constants, themes, and utility helpers
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── colors.dart
│   │   │   └── strings.dart
│   │   ├── themes/
│   │   │   ├── app_theme.dart
│   │   │   └── text_styles.dart
│   │   └── utils/
│   │       ├── date_formatter.dart
│   │       ├── location_utils.dart
│   │       └── permission_utils.dart
│   ├── services/                      # Location, geofence, SMS, notification, background services
│   │   ├── background_service.dart
│   │   ├── firebase_service.dart
│   │   ├── geofence_service.dart
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   └── sms_service.dart
│   ├── models/                        # Data models used across the app
│   │   ├── alert_model.dart
│   │   ├── contact_model.dart
│   │   ├── device_model.dart
│   │   ├── geofence_model.dart
│   │   ├── location_model.dart
│   │   └── user_model.dart
│   ├── providers/                     # State management providers
│   │   ├── app_provider.dart
│   │   ├── device_provider.dart
│   │   ├── location_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/                       # Main app screens
│   │   ├── dashboard_screen.dart
│   │   ├── emergency_screen.dart
│   │   ├── map_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/                       # Reusable UI components
│   │   ├── common/
│   │   ├── dashboard/
│   │   ├── emergency/
│   │   ├── map/
│   │   └── settings/
│   └── assets/                        # Static assets
│       ├── fonts/
│       └── images/
├── pubspec.yaml                       # Flutter package manifest
├── firebase.json                      # Firebase config file (legacy / optional)
├── android/app/google-services.json   # Android Firebase config (legacy / optional)
├── README.md                          # Project documentation
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # License file
└── Resources/                         # Docs, wireframes, and planning artifacts
    ├── Tourist_safety_app.md
    ├── Wireframing_doc.md
    └── smart_tourist_safety_system/    # Wireframe HTML and screenshot files
```

> Note: The `android/` folder is separate from `lib/`. `lib/` contains your Flutter/Dart app code, while `android/` contains the native Android wrapper, build scripts, and Gradle config.

## Resource Links

- [Product Requirements Document](Resources/Tourist_safety_app.md)
- [Wireframing Specifications](Resources/Wireframing_doc.md)
- [Wireframe Assets and Screenshots](Resources/smart_tourist_safety_system/)
- [Contribution Guidelines](CONTRIBUTING.md)
- [License](LICENSE)
- [Planning Document](Resources/planing.md)


## Installation

### Prerequisites

- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/tourist-safety-app.git
   cd tourist-safety-app
   ```

2. Install Flutter packages:
   ```bash
   flutter pub get
   ```

3. Configure API keys:
   - Add Google Maps API key using `lib/config/api_keys.dart`.

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

- Open the app on a connected device or emulator.
- Grant location and SMS permissions.
- Use the dashboard to monitor status and location.
- Press the SOS button in case of emergency.

## API & Integrations

This project uses:

- Local device storage for app data persistence and caching.
- Google Maps API for map rendering and geofence visualization.
- Flutter SMS for emergency messaging.
- Local notifications for push-style alerts.

See `Resources/Tourist_safety_app.md` for full integration details.


## Roadmap
 
- MVP: Live tracking, geofencing, SOS, local persistence.
- Next: Push notifications, battery alerts, offline behavior.
- Future: Multi-language, alert history, admin dashboard.

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Screenshots

### Dashboard Screen
[![Dashboard](Resources/smart_tourist_safety_system/home_dashboard/screen.png)](Resources/smart_tourist_safety_system/home_dashboard/screen.png)

### Tracking Map Screen
[![Tracking Map](Resources/smart_tourist_safety_system/detailed_tracking_map/screen.png)](Resources/smart_tourist_safety_system/detailed_tracking_map/screen.png)

### Emergency Screen
[![Emergency](Resources/smart_tourist_safety_system/emergency_tab/screen.png)](Resources/smart_tourist_safety_system/emergency_tab/screen.png)

### Settings Screen
[![Settings](Resources/smart_tourist_safety_system/settings_configuration/screen.png)](Resources/smart_tourist_safety_system/settings_configuration/screen.png)


---

