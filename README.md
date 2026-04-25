# भारत Budget — Flutter App

Android aur Windows dono ke liye ready Flutter app.

## Features
- 🏠 Home — Cash flow, AI insights, salary usage
- 📊 Reports — Category breakdown, all transactions
- 📈 Invest — SIP calculator, FD calculator
- 🎯 Goals — Saving targets with progress
- 🏛️ Accounts — Bank accounts, balance toggle
- 👥 People — Shared expenses tracker (Raju, Meena, Rahul, Ammi)

## Setup Steps (VS Code mein)

### 1. Flutter Install karo
```
https://flutter.dev/docs/get-started/install
```

### 2. Is folder ko VS Code mein kholo
```
File > Open Folder > bharat_budget
```

### 3. Dependencies install karo (terminal mein)
```bash
flutter pub get
```

### 4. Android ke liye run karo
```bash
# Phone connect karo USB se, ya emulator start karo
flutter run
```

### 5. Windows ke liye run karo
```bash
flutter run -d windows
```

### 6. APK build karo (Android)
```bash
flutter build apk --release
# APK milega: build/app/outputs/flutter-apk/app-release.apk
```

### 7. Windows exe build karo
```bash
flutter build windows --release
# Exe milega: build/windows/x64/runner/Release/
```

## Project Structure
```
lib/
  main.dart              # Entry point + bottom nav
  theme.dart             # Dark theme, colors, helpers
  state.dart             # App state (Provider)
  models/
    models.dart          # Transaction, Goal, Person models
  screens/
    home_screen.dart     # Home screen
    people_screen.dart   # People + Person detail
    other_screens.dart   # Reports, Goals, Invest, Accounts
    add_transaction_screen.dart
```

## Requirements
- Flutter SDK >= 3.0.0
- Android Studio / Xcode (for emulator)
- Windows build tools (for Windows target)
