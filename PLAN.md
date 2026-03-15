# VERIDIS — Project Context & Architecture

## What This Project Is

VERIDIS is a smart campus recycling Flutter app for **Academic City University** students and staff (Ghana). Users deposit plastic/glass bottles into a physical sorting machine on campus. The app:
1. Links the user to the machine via QR code scan
2. Guides them through depositing multiple bottles
3. Shows real-time classification and weight per bottle
4. Credits earnings to an in-app wallet
5. Allows withdrawal to MTN Mobile Money

---

## Environment

- **Framework:** Flutter (Dart 3.10.7+)
- **Platforms:** Android, iOS, Web (Chrome), macOS desktop
- **Run command:** `flutter run -d chrome` (macOS has no Xcode installed; Android emulator is API 30 x86 — unsupported)
- **Dependency added:** `mobile_scanner: ^5.0.0` for QR scanning
- **No backend yet** — all data is in-memory (singleton services). Firebase planned for later.
- **No real payment API** — wallet is simulated. Admin manually processes MoMo withdrawals.

---

## Complete File Structure

```
lib/
├── main.dart                          # App entry — uses AppTheme.theme, routes to LoginScreen
├── theme/
│   └── app_theme.dart                 # Design system: AppColors, AppSpacing, AppRadius, AppTextStyles, AppDecorations, AppTheme
├── widgets/
│   └── responsive_layout.dart         # ResponsiveWrapper: centers content at max 480px on web/desktop
├── models/
│   ├── recycling_session.dart         # Session model (multi-bottle) + MaterialType enum + rate constants
│   ├── bottle_item.dart               # Single bottle: material, weight, earnings, CO2
│   └── wallet_transaction.dart        # Wallet credit / withdrawal transaction
├── services/
│   ├── session_service.dart           # Singleton: active session + completed session history
│   └── wallet_service.dart            # Singleton: balance, credit earnings, request withdrawal
└── screens/
    ├── login_screen.dart              # Two-zone layout: green hero top + white form bottom
    ├── register_screen.dart           # Full registration with campus selection (Firebase TODO)
    ├── home_screen.dart               # Bottom nav + HomeContent with hero balance card + metric grid
    ├── statistics_screen.dart         # Live stats from SessionService + session history list
    ├── leaderboard_screen.dart        # Ranking UI (mock data — needs backend)
    ├── profile_screen.dart            # User info + stats + wallet balance shortcut
    ├── qr_scan_screen.dart            # Camera QR scanner → parses veridis:// URI → ActiveSessionScreen
    ├── active_session_screen.dart     # Core session flow: scan bottles → continue/done → summary
    ├── history_screen.dart            # Read-only list of completed sessions from SessionService
    └── wallet_screen.dart             # Hero gradient balance header + withdraw to MoMo + transaction history
```

---

## Data Models

### `MaterialType` (enum, in recycling_session.dart)
```dart
enum MaterialType { plastic, glass, unknown }
```

### `BottleItem` (bottle_item.dart)
One bottle dropped in a session:
```dart
class BottleItem {
  final MaterialType materialType;
  final double weightKg;
  final double earnings;   // pre-calculated
  final double co2Saved;   // pre-calculated
  final DateTime scannedAt;
}
```

### `RecyclingSession` (recycling_session.dart)
Groups all bottles from one machine visit:
```dart
class RecyclingSession {
  final String id;
  final String machineId;       // from QR code
  final DateTime startTime;
  final DateTime? endTime;
  final List<BottleItem> bottles;

  // Computed:
  double get totalWeight
  double get totalEarnings
  double get totalCo2Saved
  int get bottleCount

  // Static helpers:
  static double earningsFor(MaterialType, double kg)
  static double co2For(MaterialType, double kg)
}
```

**Earnings rates (constants in recycling_session.dart):**
- `kPlasticRateGhs = 0.30` GHS/kg
- `kGlassRateGhs = 0.20` GHS/kg
- `kPlasticCo2PerKg = 2.5` kg CO₂/kg
- `kGlassCo2PerKg = 0.5` kg CO₂/kg

### `WalletTransaction` (wallet_transaction.dart)
```dart
enum TransactionType { credit, withdrawalRequest }

class WalletTransaction {
  final String id;
  final DateTime timestamp;
  final TransactionType type;
  final double amount;
  final String description;
  final bool isPending;   // true = withdrawal awaiting admin
}
```

---

## Services

### `SessionService` (singleton)
```
activeSession          → RecyclingSession? (null when idle)
completedSessions      → List<RecyclingSession> (newest first)
startSession(machineId)       → creates active session
addBottleToActive(BottleItem) → appends bottle to active session
endSession()                  → finalises session, credits wallet, returns finished session
cancelSession()               → discards active session

Aggregates (from completedSessions):
  totalWeight, totalEarnings, totalCo2Saved, sessionCount
  plasticWeight, glassWeight
```

### `WalletService` (singleton)
```
balance                       → double (credits - withdrawals)
transactions                  → List<WalletTransaction>
creditEarnings(amount, desc)  → adds credit transaction
requestWithdrawal(amount, momo) → deducts balance, adds pending transaction
                                  returns false if insufficient balance
```

---

## Screen Flow

```
LoginScreen
    ↓ (sign in)
HomeScreen (bottom nav)
    ├── Home tab (HomeContent)
    │     ├── [Start Session] → QrScanScreen
    │     │       ↓ (scan veridis://session?machine=X&token=Y)
    │     │   ActiveSessionScreen
    │     │       ├── Place bottle → Scan (5-step pipeline)
    │     │       ├── Bottle result: material + weight + earnings
    │     │       ├── [Add Another Bottle] → back to waiting
    │     │       └── [Done] → Session Summary → Return Home
    │     ├── [My Wallet]  → WalletScreen
    │     └── [History]    → HistoryScreen
    ├── Statistics tab     → StatisticsScreen (live data)
    ├── Leaderboard tab    → LeaderboardScreen (mock)
    └── Profile tab        → ProfileScreen (wallet shortcut)
```

---

## QR Code Format

The physical machine displays:
```
veridis://session?machine=MACHINE_001&token=<timestamp>
```
- App scans → `QrScanScreen._handleQrCode()` parses URI
- Calls `SessionService().startSession(machineId)`
- Navigates to `ActiveSessionScreen`
- **For Chrome/web testing:** "Simulate QR Scan" button generates a test URI

---

## Hardware Pipeline (simulated — 5 steps, ~4.1s total)

Defined as `_BottleStep` enum in `active_session_screen.dart`:

| Step | Hardware | Simulated delay |
|---|---|---|
| detecting | Proximity sensor | 0.8s |
| capturing | HuskyLens AI camera | 1.0s |
| classifying | LDR + IR sensors | 1.0s |
| weighing | Load cell + HX711 | 0.8s |
| sorting | Servo motor gate | 0.5s |

**TODO markers in `active_session_screen.dart` (lines ~51, ~59):**
- Replace random `MaterialType` with real Bluetooth/HTTP result from microcontroller
- Replace random weight with actual HX711 reading

---

## UI Design System (`lib/theme/app_theme.dart`)

Brand: VERIDIS = Latin *viridis* (green/fresh). Palette is **green + white only**.

### Color Palette
| Constant | Hex | Usage |
|---|---|---|
| `AppColors.forestGreen` | `#1A5C38` | AppBar, hero cards, primary buttons |
| `AppColors.freshGreen` | `#2E7D32` | Accents, icons, secondary buttons |
| `AppColors.midGreen` | `#388E3C` | Glass material, mid-level accents |
| `AppColors.sessionGreen` | `#43A047` | Session count metric |
| `AppColors.mintGreen` | `#E8F5E9` | Subtle backgrounds, avatar fills |
| `AppColors.scaffoldBg` | `#F5F7F5` | Page background |
| `AppColors.earningsGreen` | `#2E7D32` | GHS amounts (NOT orange) |
| `AppColors.co2DeepGreen` | `#1B5E20` | CO₂ metric (NOT blue) |
| `AppColors.pendingAmber` | `#F59E0B` | ONLY non-green — "Pending" badge only |

### Key Decorations
- `AppDecorations.heroCard` — forest green gradient, used for home balance card + wallet header
- `AppDecorations.loginHero` — same gradient, rounded bottom corners only (login screen top zone)
- `AppDecorations.contentCard` — white bg, green-tinted box shadow
- `AppDecorations.infoBox` — mint bg, green border (campus info notices)

### Responsive Layout
- `ResponsiveWrapper` (`lib/widgets/responsive_layout.dart`) wraps all Scaffold roots
- On web/desktop (> 480px wide): centers content in 480px column with neutral surround
- On mobile: full-width, no change

### Login Screen Structure
Two-zone layout (NOT a single scroll):
1. `Container` with `AppDecorations.loginHero` — height = `clamp(MediaQuery height × 0.32, 200, 280)`
2. `Expanded` white `SingleChildScrollView` with the form

---

## Key Design Decisions

1. **No button on the machine** — machine screen too small. User taps "Done" or "Add Another" in the app.
2. **One session = multiple bottles** — `RecyclingSession.bottles` is a list; running tally shown during session.
3. **Simulated wallet** — no Paystack/MoMo API. Admin manually sends MoMo after receiving withdrawal request.
4. **No concurrency** — machine is sequential; one user at a time. QR token ties the user to the session.
5. **`_pages` is a getter (not const)** in `HomeScreen` so Statistics/Profile always rebuild with fresh data on tab switch.
6. **`hide MaterialType`** — Flutter's `material.dart` exports a `MaterialType` that conflicts with ours. All screens that import both use `import 'package:flutter/material.dart' hide MaterialType;`.
7. **Theme via `AppTheme.theme`** — `main.dart` uses `useMaterial3: true` + `ColorScheme.fromSeed(forestGreen)`. Never add raw `Color(0xFF...)` literals in screens — always use `AppColors.*` constants.

---

## Known TODOs (not yet implemented)

| Area | What's needed |
|---|---|
| Auth | Firebase Authentication (phone OTP) |
| Registration | Firebase user creation + campus ID verification |
| Backend | Firebase Firestore to persist sessions + wallet across app restarts |
| QR validation | Firebase validates machine token (currently just parsed locally) |
| Hardware | Real Bluetooth/HTTP communication with microcontroller |
| Leaderboard | Real data from Firestore, ranked by total weight |
| Payments | Optional: Paystack Ghana MoMo API for automated payouts |

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on Chrome (recommended for now — no Xcode)
flutter run -d chrome

# Run on macOS (requires full Xcode.app from developer.apple.com)
flutter run -d macos

# Fix Android emulator (create new AVD: Pixel 6, API 33, x86_64)
flutter run -d emulator-5554
```

**Hot reload:** `r` | **Hot restart:** `R` | **Quit:** `q`
