# DailyDew

**DailyDew – Your garden in your pocket: simple plant watering reminders.**

DailyDew is a minimalistic, garden‑themed plant care tracker for Android. It helps you keep your houseplants healthy with custom watering schedules and gentle reminders, all inside a small, emoji‑driven virtual garden.

## Features

- Garden theme with emoji “plots”
- Add, edit, and delete plants
- Custom watering intervals per plant
- Local notifications for watering reminders
- Care history / log per plant
- Fully offline; no accounts, no cloud, no ads

## Tech Stack

- **Framework**: Flutter (Dart)
- **Architecture**: Custom reactive pattern using `SharedRef` (no external state management library)
- **Local storage**: `shared_preferences`
- **Notifications**: `flutter_local_notifications`
- **Platform**: Android

## Screenshots

- Garden view with emoji plants  
- Add/edit plant screen  
- Plant detail with watering schedule  
- Care history / log view  
- Settings / reminders overview

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Android SDK
- A physical Android device or emulator

### Installation

```bash
git clone https://github.com/kimkev/plant_sip.git
cd plant_sip
flutter pub get
flutter run
```

## Privacy

DailyDew does not collect, store, or transmit personal data to external servers. All plant and care data is stored locally on your device. The app does not use third‑party analytics or advertising SDKs.

Privacy policy:  
[https://kimkev.github.io/privacypolicies/privacy-dailydew.html](https://kimkev.github.io/privacypolicies/privacy-dailydew.html)

## License

This project is licensed under the [MIT License](LICENSE).