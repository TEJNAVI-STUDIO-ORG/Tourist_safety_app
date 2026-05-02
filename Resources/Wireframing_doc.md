# Wireframing Document

## Table of Contents

- [Project Overview](#project-touristSafe--smart-tourist-safety--tracking-system)
- [Main Screens](#main-screens)
- [1. Dashboard / Home Screen](#1-dashboard--home-screen)
- [2. Tracking Map Screen](#2-tracking-map-screen)
- [3. Emergency Screen](#3-emergency-screen)
- [4. Settings / Configuration Screen](#4-settings--configuration-screen)
- [Common Navigation Notes](#common-navigation-notes)
- [Common Interaction Notes](#common-interaction-notes)
- [Empty States](#empty-states)
- [Error States](#error-states)
- [Responsive Notes](#responsive-notes)
- [Simple Wireframe Flow](#simple-wireframe-flow)

---

## Project: TouristSafe – Smart Tourist Safety & Tracking System

### Main Screens

1. Dashboard / Home
2. Tracking Map
3. Emergency Screen
4. Settings / Configuration

---

## 1. Dashboard / Home Screen

## Screen Title and ID

**Dashboard-Main-01**

## Purpose

This is the first screen the user sees after opening the app. It gives a quick summary of device status, battery, current location preview, and the SOS button.

## Wireframe Preview

![Dashboard Wireframe](smart_tourist_safety_system/home_dashboard/screen.png)

## Main Wireframe Elements

1. Top bar with app name and notification icon
2. Device status card
3. Private mode toggle
4. Battery level bar
5. Current location map preview
6. SOS button
7. Bottom navigation bar

## Numbered Annotations and Behavior

**1. App Header**
Shows the app name “TouristSafe” and notification bell icon.

**2. Status Card**
Shows the current app or connection state.

**3. Private Mode Toggle**
Turns tracking on or off.

**4. Battery Level Bar**
Shows the device battery percentage.

**5. Map Preview**
Shows a small live preview of the current location and danger zone.

**6. SOS Button**
Sends emergency alert and current location to the emergency contact.

**7. Bottom Navigation**
Used to switch between Dashboard, Tracking, Emergency, and Settings.

## Content Specifications

* Device status should be shown as text like “Online” or “Offline”
* Battery should be shown in percentage
* Map preview should be a small image or embedded map
* SOS button must be large and easy to tap
* Private mode must be clearly visible

## Simple States

* **Online state:** green badge
* **Offline state:** gray or red badge
* **Private mode ON:** tracking paused warning
* **Private mode OFF:** normal tracking active

## Error / Edge Cases

* If device is offline, show “Last updated time”
* If battery data is missing, show “Battery unavailable”
* If location is not available, show “Location not found”

---

## 2. Tracking Map Screen

## Screen Title and ID

**Tracking-Map-01**

## Purpose

This screen shows the full map with the user’s live location and danger zones.

## Wireframe Preview

![Tracking Map Wireframe](smart_tourist_safety_system/detailed_tracking_map/screen.png)

## Main Wireframe Elements

1. Top app bar
2. Full map area
3. Danger zone circles
4. Current location marker
5. Safety status card
6. Map layers button
7. Recenter location button
8. Bottom navigation bar

## Numbered Annotations and Behavior

**1. Header**
Shows app name and notification icon.

**2. Full Map Area**
Displays live map with the user's position.

**3. Danger Zone Circles**
Shows marked danger areas like steep terrain or restricted area.

**4. Location Marker**
Shows the current position of the user/device.

**5. Safety Status Card**
Shows whether the user is safe or in danger.

**6. Layers Button**
Changes map style or map view.

**7. Recenter Button**
Brings the map back to the user’s current location.

**8. Bottom Navigation**
Used to move to other screens.

## Content Specifications

* Map should take most of the screen
* Danger zones should be shown as red circles
* Location marker should be centered or easy to find
* Safety status should be short, like “Secure” or “Warning”

## Simple States

* **Safe state:** green safety card
* **Danger state:** red safety card and alert popup
* **Tracking pause state:** map stays visible but live movement stops

## Error / Edge Cases

* If internet is weak, show last known map location
* If GPS is weak, show an accuracy circle
* If geofence data is missing, show “No danger zones found”

---

## 3. Emergency Screen

## Screen Title and ID

**Emergency-SOS-01**

## Purpose

This screen helps the user quickly send help using SOS and contacts.

## Wireframe Preview

![Emergency Wireframe](smart_tourist_safety_system/emergency_tab/screen.png)

## Main Wireframe Elements

1. Emergency Header
2. Big SOS Button
3. Emergency Contact List
4. Call Button
5. SMS Button
6. Alert Preview Area
7. Bottom Navigation Bar

## Numbered Annotations and Behavior

**1. Header**
Shows page title like “Emergency”.

**2. Big SOS Button**
Main action button. Sends emergency location instantly.

**3. Emergency Contact List**
Shows saved contacts like parent, friend, or local help.

**4. Call Button**
Starts a call to the selected emergency contact.

**5. SMS Button**
Sends current location by message.

**6. Alert Preview Area**
Shows what message will be sent.

**7. Bottom Navigation**
Switches to other pages.

## Content Specifications

* SOS button should be the biggest element on the screen
* Contact names and phone numbers should be clearly shown
* Message should include location link or coordinates
* One primary contact should always be shown first

## Simple States

* **No contacts added:** show “Add emergency contact”
* **SOS sent:** show confirmation message
* **Failed send:** show error and retry option

## Error / Edge Cases

* If SMS permission is denied, show permission request
* If no network is available, show fallback call option
* If location is missing, send last known location
---

## 4. Settings / Configuration Screen

## Screen Title and ID

**Settings-Config-01**

## Purpose

This screen is for emergency contacts, app configuration, and API settings.

## Wireframe Preview

![Settings Wireframe](smart_tourist_safety_system/settings_configuration/screen.png)

## Main Wireframe Elements

1. Theme Setting
2. Emergency Contacts Section
3. Add Contact Button
4. Alert Preferences Section
5. App Status Section
6. Alert Preferences Section
7. API Configuration Section
8. Save Configuration Button
9. About App Section
10. Reset Settings Button

## Numbered Annotations and Behavior

**1. Theme Setting**
Lets user switch between light and dark mode.

**2. Emergency Contacts Section**
Shows saved emergency contacts.

**3. Add Contact Button**
Opens form to add a new contact.

**4. Alert Preferences Section**
Turns fall alerts and geofence alerts, push notifications, sms alerts on/off.

**5. App Status Section**
Shows the current app or connection state.

**6. API Configuration Section**
Stores local settings and Google Maps API key.

**7. Save Button**
Saves all configuration changes.

**8. API Configuration Section**
Stores local settings and Google Maps API key.

**9. Save Button**
Saves all configuration changes.

**10. About App Section**
Shows version and support links.

**11. Reset Button**
Restores default settings.

## Content Specifications

* Contacts should show name and phone number
* App status should describe the current mode or connection state
* API fields should be input fields
* Save button should be clearly visible

## Simple States

* **Theme selected:** highlight current option
* **Device connected:** green status
* **Device disconnected:** gray status
* **Settings saved:** success message

## Error / Edge Cases

* If API key is invalid, show warning
* If app settings fail to save, show retry option
* If contact list is empty, show “No emergency contacts added”

---

# Common Navigation Notes

## Bottom Navigation Bar

This should appear on the main app screens.

Tabs:

* Dashboard
* Tracking
* Emergency
* Settings

## Behavior

* Active tab should look highlighted
* Tapping a tab opens that screen
* Navigation should be simple and always visible

---

# Common Interaction Notes

## Buttons

* SOS button = emergency action
* Add button = opens form
* Save button = stores changes
* Toggle switch = turns a feature on/off

## Cards

* Used for status, battery, profile, and settings
* Each card should have a title and short detail

## Map

* Must show current location
* Must show danger zones
* Must show safety status

---

# Empty States

## No Emergency Contacts

Show:

* “No contacts added”
* Add Contact button

## No Location Available

Show:

* “Waiting for location data”

---

# Error States

## No Internet

Show:

* “Connection lost”
* Last known location only

## GPS Off

Show:

* “Location permission needed”

## Device Offline

Show:

* “Device offline”
* Last update time

---

# Responsive Notes

## Mobile

* Bottom navigation visible
* Map and cards stacked vertically

## Tablet / Large Screen

* Cards can appear in two columns
* Navigation still simple

---

# Simple Wireframe Flow

**Dashboard → Tracking → Emergency → Settings**

That is the basic flow of the app.

---

