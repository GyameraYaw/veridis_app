# VERIDIS — Smart Campus Recycling

A Flutter app for Academic City University students and staff to deposit plastic and glass bottles into a smart recycling machine, earn rewards, and withdraw to MTN Mobile Money.

---

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase CLI
- A Google account with access to the VERIDIS Firebase project

### Setup

1. Clone the repo and install dependencies:
```bash
git clone https://github.com/GyameraYaw/veridis_app.git
cd veridis_app
flutter pub get
```

2. Generate Firebase config files (required — these are not committed to the repo):
```bash
flutterfire configure --project=veridis-app
```
Select **android** and **web** when prompted. This generates `lib/firebase_options.dart` and `android/app/google-services.json` locally.

3. Run the app:
```bash
flutter run -d chrome      # web (recommended for development)
flutter run -d android     # Android device or emulator
```

---

## Notes

- Firebase config files (`firebase_options.dart`, `google-services.json`) are intentionally excluded from the repo. Every developer must run `flutterfire configure` once after cloning.
- Hot reload: `r` | Hot restart: `R` | Quit: `q`
