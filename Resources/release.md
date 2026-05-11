Here is release note text you can paste into GitHub Releases (adapt the tag/date if yours differ).

---

## TouristSafe **v1.0.0+1**

Tourist safety companion app built with Flutter: live location on an OpenStreetMap-based map, emergency contacts, SOS-style messaging UX, configurable safety features, and in-app alerts/history scaffolding.

Design and planning references live under **`Resources/`** (Guardian Pulse – `DESIGN.md`, HTML wireframes, PNG mocks for home / emergency / settings, PRD **`Tourist_safety_app.md`**, **`Wireframing_doc.md`**, and roadmap notes in **`planing.md`**).

---

### Added

- **Four-tab shell**: Dashboard, Tracking map, Emergency, Settings (`main.dart`).
- **Live location**: Geolocator stream, speed/accuracy exposed via `LocationProvider`; map and dashboard consume updates.
- **OpenStreetMap map** (`flutter_map`): current-location marker and illustrative danger-zone circles (`map_screen.dart` / dashboard preview).
- **Emergency flow**: SOS-style workflow with templated message, contact list integration, SMS composer via **`url_launcher`** (`sms:`), and **`tel:`** for calls (`sms_service.dart`, `emergency_screen.dart`).
- **Contacts & settings persistence**: Emergency contacts CRUD, toggles for geofence/SMS/private mode/alerts/fall detection, SOS message template backed by **`shared_preferences`** (`settings_provider.dart`, `settings_screen.dart`).
- **Legal & app info screens**: About, Privacy Policy, Terms (`about_screen.dart`, `privacy_policy_screen.dart`, `terms_screen.dart`).
- **In-app notifications list**: Stored history, filters UI, **`NotificationProvider`** + **`notification_model`** (`notifications_screen.dart`); reachable from dashboard bell.
- **Local notifications plumbing**: **`flutter_local_notifications`** + Android receivers in manifest (`notification_service.dart`).
- **Fall detection experimentation**: **`sensors_plus`**, **`advanced_fall_detection_service`** / **`fall_detection_service`**, **`fall_alert_screen`**; wakelock / vibration integrations where used.
- **Permissions helper**: Consolidated runtime permission requests (`permission_service.dart`).
- **Android**: Core library **desugaring** enabled for `flutter_local_notifications` (`android/app/build.gradle.kts`).
- **Firebase**: `firebase_options.dart` / `google-services.json` present for future Firebase use (minimal surface in UI for this milestone).

---

### Changed / fixed

- **Startup**: Notifications init no longer blocks `runApp` (reduces hangs on OEM devices with repetitive `VRI` / predraw warnings); permission + location bootstrap deferred until after first frame (`main.dart`).
- **Notifications entry**: Dashboard notification icon navigates to **`NotificationsScreen`** (`dashboard_screen.dart`).

---

### Dependencies (high level)

`provider`, `geolocator`, `flutter_map`, `permission_handler`, `shared_preferences`, `url_launcher`, `flutter_local_notifications`, `timezone`, `sensors_plus`, `battery_plus`, `vibration`, `wakelock_plus`, `timeago`, **`flutter_background_service`** (+ Android package declared in **`pubspec.yaml`**).

---

### Known limitations & what’s left (aligned with **`Resources/planing.md`**)

- **Geofencing**: Danger areas are largely **visual** (e.g. circle on map); **enter/exit detection**, zone database, and automated alerts are **not** the full engine yet.
- **SOS / SMS**: Flow opens the device **SMS composer** with a prefilled body; silent / background auto-send via native channel, retries, and delivery receipts are **out of scope for this listing** unless you separately verify **`MainActivity`** SMS channel usage end-to-end.
- **Background execution**: **`flutter_background_service`** is listed as a dependency but **has no Dart integration** in `lib/` for this milestone—treat as **future background tracking / alerts**.
- **Map UX**: Possible follow-ups include **camera follow** / richer route history (see plan).
- **Notifications**: Channels exist; tying **every** alert type (geofence, SOS outcome, fall) consistently into **shown** notifications and background behavior is incremental work.
- **Product roadmap** (from resources): multilingual UI, tighter testing (integration/geofence), store deployment polish, zone intelligence—not claimed as completed here.

---

### Assets for this release

- Optional screenshots/wire comparisons: **`Resources/smart_tourist_safety_system/home_dashboard/hd.png`**, **`emergency_tab/e.png`**, **`settings_configuration/se.png`**, plus HTML wireframes in the same folders.
- **`Resources/logo.jpeg`** for store or README branding.

---

### Install / build

```text
flutter pub get
flutter run   # Android device/emulator recommended
```

On Windows, symlink warnings when the project and pub cache are on **different drives** may affect **`windows/`** tooling; Android builds typically unaffected.

---

You can shorten the **Known limitations** block for a “marketing” release or keep it for a transparent changelog. If you tell me your exact Git tag (`v1.0.0` vs `v0.9.0`) and whether this is Google Play/internal only, wording can be tightened further.

Here’s wording you can **paste into the same GitHub Release** body so it matches “APK attached + freeze this build” clearly.

---

### Download

- **Attached to this release:** `app-debug.apk` — install by opening the APK on an Android device (enable **Install unknown apps** for your browser/files app if prompted).
- If you need the source code that is also provided for that perticular version `Tourist_safety_app.zip` extract it and build the application


**Note:** A **debug** APK is fine for testers; for Play Store or broad distribution you’ll usually attach a **release** build (`flutter build apk --release`), sign it properly, and name it distinctly (e.g. `tourist-safe-1.0.0-release.apk`).

---

### Verify

Optional line for picky testers:

```text
SHA256: <run: certutil -hashfile app-debug.apk SHA256  on Windows>
```

(Add the hash if you publish it—that’s the usual “frozen build” reassurance.)

---

If you meant something else by **“freeze”** (e.g. lock dependency versions, or the app freezes at runtime), say which and we can tune the wording.