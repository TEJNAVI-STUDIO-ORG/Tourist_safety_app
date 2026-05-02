## MVP Build Plan

### 1. Confirm the app structure
- Keep android as the native platform wrapper.
- Put all app logic in lib.
- Use pubspec.yaml to manage packages.

### 2. Start with the app shell
- Create main.dart with `MaterialApp` and basic navigation.
- Add the four main screens:
  - `dashboard_screen.dart`
  - `map_screen.dart`
  - `emergency_screen.dart`
  - `settings_screen.dart`

### 3. Add state management
- Use `providers/` for app state:
  - `app_provider.dart`
  - `location_provider.dart`
  - `settings_provider.dart`
- Keep state simple at first: current location, selected contact, privacy mode.

### 4. Build the core features one by one
1. **Live location tracking**
   - Implement `location_service.dart`
   - Display current position on the map
   - Update `map_screen.dart` and `dashboard_screen.dart`

2. **Google Maps display**
   - Add maps package and API key in api_keys.dart
   - Render map in `map_screen.dart`
   - Add a current-location marker

3. **Emergency SOS**
   - Build `emergency_screen.dart`
   - Use `sms_service.dart` to send SMS
   - Add a big SOS button and emergency contact picker

4. **Geofence alerts**
   - Create `geofence_service.dart`
   - Define danger zones in app state
   - Show warnings in `dashboard_screen.dart` and on the map

5. **Local persistence**
   - Start with `shared_preferences` or `hive`
   - Save emergency contacts, settings, last location
   - Load them at startup

### 5. Keep UI simple
- Use `widgets/` for reusable pieces:
  - `app_header.dart`
  - `loading_indicator.dart`
  - `bottom_navigation.dart`
- Focus on a clean, functional dashboard first.

### 6. Test the flow on device
- Run on Android emulator or real device
- Verify:
  - Map loads
  - Location updates
  - SOS sends SMS
  - Settings persist

### 7. Iterate and improve
- Once the core workflow works, add:
  - notifications
  - danger zone markers
  - better contact management
  - privacy mode

## Updated Plan: Tourist Safety App Development Plan

Build the Tourist Safety app by starting with app architecture and frontend development, ensuring integration of local storage, Google Maps, geofencing, and SMS for a functional MVP. This phased approach minimizes risks, leverages available resources (PRD, wireframes, tech stack), and allows iterative testing.

**Steps**
1. **Phase 1: Project Setup and Planning** - Finalize scope, set up development environment, and gather resources. Create detailed GitHub README for community engagement. *Parallel with initial research.*
2. **Phase 2: Data Persistence and Architecture Setup** - Design local storage, define data models, and integrate APIs. *Depends on Phase 1.*
3. **Phase 4: Frontend Development** - Implement Flutter app screens and features based on wireframes. *Depends on Phase 2.*
4. **Phase 5: Integration and Testing** - Connect all components, perform end-to-end testing. *Depends on Phase 4.*
5. **Phase 6: Deployment and Launch** - Prepare for app store release. *Depends on Phase 5.*

**Relevant files**
- Tourist_safety_app.md — Use PRD for feature prioritization, tech stack, folder structure, data model, and requirements.
- Wireframing_doc.md — Reference screen layouts, elements, and annotations for UI implementation.
- smart_tourist_safety_system/ subfolders — Use HTML wireframes and PNGs for visual guidance on dashboard, map, emergency, and settings screens.
- README.md (to be created) — Detailed GitHub README with project overview, setup instructions, screenshots, and contribution guidelines.

**Verification**
1. Validate local persistence and app data flow.
2. Use Flutter integration tests for geofencing, location tracking, and SMS sending.
3. Perform manual end-to-end tests: Simulate alerts and verify app responses.
4. Conduct user acceptance testing with wireframe comparisons for UI accuracy.
5. Validate README by checking GitHub repository stats for increased contributions.

**Decisions**
- Scope limited to MVP features (must-have and should-have from PRD); nice-to-have deferred.
- Assumes solo development with Flutter expertise.
- Use local device storage for persistence and app state; no cloud middleware or custom servers.
- Include geofencing and SMS as core; exclude multi-language and admin dashboard initially.
- Prioritize community building with detailed README to attract contributors.

**Further Considerations**
1. Timeline flexibility: Adjust based on development delays. Recommendation: Add buffer weeks for unforeseen issues.
2. Risk management: Monitor GPS accuracy and false alerts early. Recommendation: Implement logging for debugging.
3. Contribution strategy: Use README to highlight open issues and easy entry points for contributors.

## Detailed GitHub README Content

Here's the full, detailed README.md content you can copy-paste into your GitHub repository root. It includes project overview, setup, features, screenshots (linked to images at the bottom), contributing guidelines, and more to attract contributors.

```
# TouristSafe - Smart Tourist Safety & Tracking System

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)

A comprehensive Flutter-based mobile app for real-time tourist safety. Features live location tracking, geofencing alerts, and emergency SOS to help travelers stay safe in unfamiliar areas.

## 🚀 Features

### Core Functionality
- **Real-Time Location Tracking**: Live GPS updates with accuracy indicators.
- **Geofencing Alerts**: Automatic notifications when entering predefined danger zones.
- **Emergency SOS**: One-tap SOS button to send location and alerts to emergency contacts via SMS.
- **Privacy Mode**: Toggle tracking on/off for user control.
- **Interactive Maps**: Google Maps integration with markers, zones, and layers.

### Additional Features
- **Push Notifications**: Local alerts for geofence breaches.
- **Emergency Contacts**: Manage and prioritize contacts for SOS messaging.
- **Theme Support**: Light/dark mode for better usability.
- **Responsive Design**: Optimized for mobile devices.

