<div align="center">

<img src="assets/icon.png" width="100" alt="ELED Logo" />

# ELED

**English Learning Every Day**

A vocabulary learning app built with Flutter, designed around passive immersion and spaced repetition.

[![Release](https://img.shields.io/github/v/release/NguyenPhuDuc307/ELED?include_prereleases&label=latest&color=4CAF50)](https://github.com/NguyenPhuDuc307/ELED/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue)](https://github.com/NguyenPhuDuc307/ELED/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-orange)](LICENSE)

</div>

---

## Overview

ELED helps you build English vocabulary through **passive exposure** — notifications that surface new words throughout your day, without requiring dedicated study sessions. The app uses a brutalist design aesthetic with strong typography and high contrast.

---

## Features

### 📚 Vocabulary Database — 24,853 unique words
- **Oxford Core (5,878 words)** — CEFR levels A1 → C1, deduplicated
- **Topic sets (23,073 words)** — 480 specialized topics (Business, Medicine, Technology, Daily Life, etc.)
- All CSV data is merged at runtime into a single deduplicated flashcard pool

### 🔔 Background Notifications
- Schedule vocabulary notifications at custom intervals (1 min – 60 min)
- Set an active time window (e.g. 09:00 – 22:00) — silent outside those hours
- Native Android scheduling via `AlarmManager` for 100% reliable delivery
- **Pronunciation audio plays automatically** when each notification fires (Oxford UK MP3)
- One-tap "Known" action button — marks the word without opening the app

### 🃏 Flashcard Learning
- Swipe through word cards with IPA, part of speech, CEFR level, and topic badges
- Toggle between **English definition** (Oxford) and **Vietnamese translation** of that definition (Google Translate, on demand)
- Tap the Oxford link to open the full dictionary entry in-browser
- Audio playback button on every card

### 🔍 Search & History
- Full-text search across the entire 24,853-word database
- Notification history — last 500 words surfaced, tap any to revisit
- Known Words list — words you've marked; excluded from future notifications

### 📦 Collections
- Save words to custom collections for focused review

### 🏠 Home Screen Widget (Android)
- Displays the current vocabulary word directly on your home screen
- Updates automatically in sync with notifications

### 🔄 In-App Updates
- Check for new releases from Settings → App Version
- Direct APK download link when an update is available

### ☁️ Google Account Sync
- Sign in with Google to sync known words, collections, and notification history across devices (Firestore)

---

## Download

Grab the latest APK from [Releases](https://github.com/NguyenPhuDuc307/ELED/releases).

> **iOS:** Build from source with Xcode. No TestFlight distribution yet.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State management | `setState` + `ValueNotifier` |
| Notifications (Android) | Native `AlarmManager` + `BroadcastReceiver` (Kotlin) |
| Notifications (iOS) | `flutter_local_notifications` |
| Vocabulary data | 485 CSV files, merged at runtime |
| Oxford definitions | Scraped via `data-src-mp3` / sense HTML parsing |
| Sync | Firebase Auth + Cloud Firestore |
| Home widget | `home_widget` + native `AppWidgetProvider` |
| Audio | `just_audio` (in-app), `MediaPlayer` (notification) |
| Translation | Google Translate unofficial endpoint |

---

## Building from Source

**Prerequisites:** Flutter 3.x, Android SDK 34+, Xcode 15+ (iOS)

```bash
git clone https://github.com/NguyenPhuDuc307/ELED.git
cd ELED
flutter pub get
flutter run                        # debug
flutter build apk --release        # Android release APK
flutter build ios --release        # iOS release
```

> The app downloads vocabulary data (~1.4 MB zip) from GitHub Releases on first launch. Internet connection required for initial sync.

---

## Project Structure

```
lib/
├── models/          # Vocabulary, OxfordSense
├── screens/         # UI screens (Menu, Home, Learning, Settings, ...)
├── services/        # CsvService, NotificationService, OxfordService, UpdateService, ...
├── theme/           # BrutalistTheme (light + dark)
└── widgets/         # BrutalistCard, shared UI components

android/app/src/main/kotlin/com/nguyenphuduc/eled/
├── MainActivity.kt
├── VocabNotificationReceiver.kt   # AlarmManager-based notification + audio
├── MarkWordKnownReceiver.kt       # "Known" action without opening app
├── VocabularyWidgetProvider.kt    # Home screen widget
└── WidgetUpdateReceiver.kt        # Widget auto-update on notification fire

assets/data/
├── popularity/      # Oxford Core CSVs (A1–C1)
└── topic/           # 480 topic CSVs
```

---

## Vocabulary Data

Data is sourced from Oxford Learner's Dictionaries. Audio URLs are scraped from Oxford pages and stored directly in CSV files (column 8). The full dataset is hosted as a zip on GitHub Releases and downloaded on first launch.

To regenerate audio links after adding new words:

```bash
pip install requests
python tools/scrape_audio_links.py
```

---

## License

MIT © [Nguyen Phu Duc](https://github.com/NguyenPhuDuc307)
