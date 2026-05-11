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



# Resent updetes:

## ✅ WHAT IS ACTUALLY COMPLETED

## 🧠 1. APP ARCHITECTURE

### STATUS: ✅ GOOD FOUNDATION

You now have:

```txt id="k4m7zs"
providers/
models/
services/
themes/
screens/
```

Meaning:
✅ scalable structure
✅ maintainable code
✅ provider state management
✅ reusable services
✅ real architecture

This part is REAL and usable.

---

# 🌙 2. DARK MODE SYSTEM

### STATUS: ⚠️ PARTIALLY COMPLETE

### DONE:

✅ dark theme created
✅ app-wide theme switching
✅ navigation fixed

### NOT COMPLETE:

❌ theme state not saved permanently
❌ app resets after restart

### NEED:

Save theme using:

```txt id="g9q2vd"
SharedPreferences
```

---

# 📞 3. CONTACT STORAGE SYSTEM

### STATUS: ✅ MOSTLY COMPLETE

### DONE:

✅ dynamic contacts
✅ provider integration
✅ persistent local storage
✅ JSON serialization
✅ SharedPreferences saving/loading

### NOT COMPLETE:

❌ add contact screen
❌ edit/delete UI
❌ phone contact import

But the backend foundation is REAL.

---

# 🚨 4. SOS SYSTEM

### STATUS: ⚠️ PARTIAL

### DONE:

✅ provider integration
✅ uses saved contacts
✅ real location injection architecture
✅ native Android SMS channel architecture

### NOT COMPLETE:

❌ native Kotlin SMS sending not fully tested
❌ runtime permission edge cases
❌ delivery confirmation
❌ fallback handling

### IMPORTANT:

Right now:

```txt id="q7p3wf"
architecture = real
implementation = incomplete
```

---

# 📍 5. LOCATION SYSTEM

### STATUS: ⚠️ SEMI COMPLETE

### DONE:

✅ real GPS permissions
✅ current location fetching
✅ geolocator integration

### NOT COMPLETE:

❌ live tracking stream
❌ continuous updates
❌ background tracking
❌ marker auto movement

### CURRENT:

```txt id="x2n6cv"
fetch once only
```

NOT:

```txt id="z5w1qa"
real-time tracking
```

---

# 🗺️ 6. MAP SYSTEM

### STATUS: ⚠️ PARTIAL

### DONE:

✅ OpenStreetMap integration
✅ no API key architecture
✅ map rendering
✅ markers
✅ danger circles
✅ dashboard preview

### NOT COMPLETE:

❌ live moving marker
❌ route tracking
❌ geofence logic
❌ unsafe area detection

---

# 🔴 7. GEOFENCING SYSTEM

### STATUS: ❌ NOT BUILT YET

Currently:

```txt id="j1r4mk"
red circle = visual only
```

NOT actual detection.

Still needed:
✅ coordinate boundary checking
✅ enter/exit detection
✅ danger alerts
✅ automatic SOS triggers

---

# 🔔 8. NOTIFICATION SYSTEM

### STATUS: ❌ NOT STARTED

Needed:
✅ local notifications
✅ geofence alerts
✅ SOS success/failure alerts
✅ background warnings

---

# 📱 9. CONTACT MANAGEMENT UI

### STATUS: ❌ NOT STARTED

Needed:
✅ add contact screen
✅ remove contact
✅ edit contact
✅ validation

---

# 🔥 WHAT IS CURRENTLY “REAL”

## ACTUALLY REAL + WORKING:

✅ Flutter architecture
✅ provider state management
✅ persistent contact storage backend
✅ dark theme UI
✅ OpenStreetMap
✅ real GPS fetching
✅ dynamic data flow

---

# ⚠️ WHAT IS STILL “MVP / FAKE / INCOMPLETE”

❌ hardcoded danger zones
❌ single-time GPS fetch
❌ non-live map marker
❌ unverified SOS sending
❌ no geofence engine
❌ no notifications
❌ no contact UI management

---

# 🚀 WHAT YOU SHOULD DO NEXT

NOT random features anymore.

Now complete systems one by one.

---

# 🥇 PRIORITY ORDER (IMPORTANT)

# 1️⃣ COMPLETE LIVE LOCATION SYSTEM

THIS is the core.

Need:
✅ continuous GPS stream
✅ provider auto updates
✅ moving marker
✅ dashboard live updates

Without this:

* geofencing useless
* SOS weak
* safety logic fake

THIS should be next.

---

# 2️⃣ COMPLETE CONTACT MANAGEMENT

Need:
✅ add contact screen
✅ remove contact
✅ edit contact

Then your SOS system becomes actually usable.

---

# 3️⃣ COMPLETE GEOFENCING ENGINE

Need:
✅ danger zone models
✅ distance calculation
✅ enter/exit detection
✅ alert triggers

THIS is your app’s MAIN FEATURE.

---

# 4️⃣ COMPLETE NOTIFICATIONS

Need:
✅ local alerts
✅ warning popups
✅ background alerts

---

# 5️⃣ COMPLETE SOS SYSTEM

After location + contacts stabilize:
✅ fully test native SMS
✅ retry logic
✅ fallback handling

---

# 🧠 FINAL REALITY CHECK

Right now your app is:

```txt id="p8v4zt"
65% architecture
35% real functionality
```

Which is NORMAL.

You’ve built the skeleton correctly.

Now comes:

# “making every system fully real”

That’s the hard but important phase 😭


---

✅ COMPLETED PROPERLY
Core Architecture

✅ Provider state management
✅ Persistent settings
✅ Persistent dark mode
✅ Persistent contacts
✅ Add/Edit/Delete contacts
✅ Multi-screen navigation
✅ App-wide theme system

GPS + Tracking

✅ Real GPS access
✅ Continuous live location updates
✅ Live coordinates
✅ Live speed
✅ Live accuracy
✅ Tracking toggle system
✅ Private mode system
✅ Moving marker data ready

(Marker camera-follow still remaining)

Emergency System

✅ Dynamic emergency contacts
✅ SOS workflow
✅ Real SMS app launching
✅ Real call launcher
✅ SOS preview system
✅ Emergency UI complete

ONLY remaining:

❌ auto-send SMS
❌ saveable SOS template

Map System

✅ Real OpenStreetMap integration
✅ Real live marker position
✅ Danger zone rendering support
✅ Preview map
✅ Detailed map

Remaining:
❌ auto-moving camera
❌ geofence engine
❌ zone database
❌ boundary detection

UI / UX

✅ Dashboard stable
✅ Emergency screen stable
✅ Settings stable
✅ Dark/light responsive
✅ Scroll-safe UI

📊 REAL STATUS

You’re around:

✅ 75–80% COMPLETE

The REMAINING 20–25% is the HARD PART:

geofencing engine
background services
notifications
smart alerts
zone intelligence
fall detection
automated safety logic

That’s the actual “smart tourist protection system”.

🚀 WHAT WE DO NOW

You said first:

1️⃣ SAVE SOS TEMPLATE
2️⃣ SETTINGS IMPROVEMENTS
3️⃣ ABOUT / PRIVACY / TERMS
4️⃣ FALL DETECTION TOGGLE

Correct order.

THEN:

PHASE 2
Notifications Engine

THEN:

PHASE 3
Geofencing Engine

THEN:

PHASE 4
Zone Intelligence

Perfect roadmap honestly





> “Hazard Zone Intelligence Engine”

NOT a full GIS system.

And yes — you can do this mostly with:

* OpenStreetMap
* OpenTopoMap
* Geolocator
* Custom zone logic

That’s enough.

---

# ✅ FINAL SIMPLIFIED ARCHITECTURE

## CURRENT STACK

| Purpose           | Service                  |
| ----------------- | ------------------------ |
| Base Map          | OpenStreetMap            |
| Terrain Data      | OpenTopoMap              |
| User Location     | geolocator               |
| Zone Rendering    | Flutter circles/polygons |
| Zone Intelligence | Custom Engine            |

---

# ✅ WHAT IS ACTUALLY NEED FROM OSM

OSM already contains tags for:

| Type             | OSM Tags                  |
| ---------------- | ------------------------- |
| Dense Forest     | `landuse=forest`          |
| Water            | `natural=water`           |
| Mountain         | `natural=peak`            |
| Cliff            | `natural=cliff`           |
| Restricted Area  | `military=*`              |
| Private Area     | `access=private`          |
| Landslide Area   | `hazard=landslide`        |
| Dangerous Area   | `hazard=*`                |
| Protected Zone   | `boundary=protected_area` |
| Dense Population | `place=city/town`         |
| Sparse Area      | low nearby nodes/roads    |
| No Network Zone  | custom estimation logic   |

SO:
you do NOT need another huge service.
OSM already gives the objects.

---

# ✅ YOUR ENGINE FLOW

## STEP 1

Get user location.

```dart
Position position = await Geolocator.getCurrentPosition();
```

---

# STEP 2

Query nearby OSM objects.

You’ll use:

## OVERPASS API

Official OSM query system.

Official:
[Overpass API](https://overpass-api.de?)

Example query:

```txt
(
  node["natural"="cliff"](around:3000,lat,lng);
  way["landuse"="forest"](around:3000,lat,lng);
  way["military"](around:3000,lat,lng);
  way["hazard"](around:3000,lat,lng);
);
out center;
```

This gives nearby:

* cliffs
* forests
* hazards
* restricted areas

SUPER lightweight.

---

# ✅ STEP 3

Convert them into zones.

Example:

| Area Type       | Zone Color | Radius       |
| --------------- | ---------- | ------------ |
| Dense Forest    | Orange     | 500m         |
| Cliff           | Red        | 300m         |
| Restricted Area | Dark Red   | Full polygon |
| Mountain        | Yellow     | 800m         |
| Hazard Area     | Red        | 600m         |

---

# ✅ STEP 4

Draw circles/polygons on map.

Using Flutter:

```dart
CircleLayer(
  circles: [
    CircleMarker(
      point: LatLng(lat, lng),
      radius: 200,
      color: Colors.red.withOpacity(0.4),
    ),
  ],
)
```

DONE.

That’s literally your zone system.

---

# ✅ IMPORTANT

You should NOT scan the ENTIRE map.

ONLY scan:

* around user
* around active trip
* around route

Example:

* 2km radius
* 5km radius

Otherwise performance dies 💀

---

# ✅ NO NETWORK ZONE LOGIC

OSM doesn’t provide network strength.

So fake-smart it.

## Example logic:

```text
IF:
- dense forest
- mountains
- far from roads
- far from towns
THEN:
=> possible low network zone
```

That’s actually how outdoor apps estimate danger.

---

# ✅ HOW ZONES SHOULD LOOK

## RED

* cliffs
* landslide
* military
* dangerous hazard

## ORANGE

* dense forest
* isolated area
* difficult mountain terrain

## YELLOW

* river nearby
* rough terrain
* moderate slope

## GREEN

* populated area
* safe roads
* tourist zones

---


---

# ✅ WHAT YOU SHOULD BUILD NOW

## Build Order

### 1. User location (i think we have this alredy we just need to use it here )

### 2. OSM Overpass fetch

### 3. Parse hazard tags

### 4. Create zone model

### 5. Draw circles On the Detailed Tracking Map

### 6. Add color legend

### 7. Add risk score

That’s the correct implementation order.

---

# ✅ MOST IMPORTANT THING

DO NOT hardcode zones manually.
app should dynamically generate them from nearby OSM data.
That’s what makes it smart.
