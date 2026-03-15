# SpendWise

A new Flutter project.

## Features

- Authentication (Login, Sign Up, Password Reset)
- Income tracking
- Expense tracking
- Loan management
- Light / Dark theme
- Total balance overview
- Real-time sync with Firebase

## 📥 Download

| Platform | Download                                                                                                                      |
|---|-------------------------------------------------------------------------------------------------------------------------------|
| Android | [SpendWise_v1.0.0.apk](https://github.com/dev-abdul-haseeb/spend_wise/releases/latest/download/SpendWise_v1.0.0.apk)          |
|️ Windows | [SpendWise_Setup_v1.0.0.exe](https://github.com/dev-abdul-haseeb/spend_wise/releases/latest/download/SpendWise_Setup_v1.0.0.exe) |

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/dev-abdul-haseeb/spend_wise.git
cd spend_wise
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Setup Firebase
- Create a project at [Firebase Console](https://console.firebase.google.com/)
- Run the Firebase CLI setup commands
- Enable **Email/Password** authentication in Firebase Console
- Enable **Cloud Firestore** in Firebase Console

### 4. Get SHA Keys (Android)
```bash
cd android
./gradlew signingReport
```
Add the SHA-1 and SHA-256 keys to your Firebase Android app settings.

### 5. Run the app
```bash
flutter run
```

## 🛠 Tech Stack

Framework: Flutter
Backend: Firebase (Auth + Firestore)
State Management: BLoC
Architecture: BLoC (MVVM-aligned)
Local Storage: Shared Preferences


## Packages used:

1. firebase_core
2. firebase_auth
3. cloud_firestore
4. bloc
5. flutter_bloc
5. google_fonts
6. Equatable
7. shared_preferences
8. flutter_launcher_icons

## Project structure:

lib/
|
|-config/
|   |-color/
|   |-components/
|   |-enum/
|   |-flash_bar/
|   |-list_tile/
|   |-routes/
|
|-model/
|   |-expense/
|   |-income/
|   |-loan/
|   |-user/
|
|-repository/
|   |-auth_repository/
|   |-expense_repository/
|   |-income_repository/
|   |-loan_repository/
|   |-user_repository/
|
|-view/
|   |-auth_navigator/
|   |-authentication/
|   |-expense_screen/
|   |-home/
|   |-income_screen/
|   |-loan_screen/
|   |-profile_screen/
|   |-reset_password/
|   |-splash/
|
|-viewModel/
|   |-bloc/
|   |   |-auth_state/
|   |   |-expense/
|   |   |-income/
|   |   |-loan/
|   |   |-navigation/
|   |   |-obscure_text/
|   |   |-theme/
|   |   |-total_balance/

## Platforms

| Platform | Status |
|---|---|
| Android |  Supported |
| Windows |  Supported |
| iOS | Not configured |

## License

This project is for personal/educational use.

