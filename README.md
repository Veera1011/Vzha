# VZHA — Built by devs, for devs. 🚀

VZHA is a modern developer app built with Flutter and Supabase. A central place for developers to read tech news, track package versions, monitor security vulnerabilities, and collaborate in real-time chat rooms.

## ✨ Features

*   📰 **Tech News Feed:** Stay informed with the latest programming articles sourced directly from the Dev.to API.
*   📦 **Package Tracker:** Instantly search for packages across **NPM** and **Pub.dev** to check for the latest versions.
*   🚨 **Vulnerability Alerts:** Query the **OSV.dev** database to discover recent security vulnerabilities for specific packages or ecosystems.
*   🔖 **Saved Items:** Bookmark your favorite articles, packages, and important security alerts directly to a cloud database.
*   🎨 **Dynamic Theming:** Fully customizable UI! Change the app's primary color, font family, and text scaling on the fly via the Settings screen. Your preferences are saved locally.

## 🛠️ Tech Stack

*   **Frontend:** Flutter (Material 3, Clean Nordic Aesthetic)
*   **Backend:** Supabase (PostgreSQL Database, Authentication, Row Level Security)
*   **State Management:** Provider
*   **Local Storage:** SharedPreferences (for theme persistence)

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK installed
*   A [Supabase](https://supabase.com/) account and project

### 1. Database Setup
A SQL schema is provided to set up the necessary tables and Row Level Security (RLS) policies.
1. Open your Supabase project dashboard.
2. Navigate to the **SQL Editor**.
3. Copy the contents of the `supabase_schema.sql` file located in the root of this repository.
4. Paste and execute the script.

### 2. Configure Credentials
In the `lib/core/constants/supabase_constants.dart` file, you need to provide your Supabase connection details:

```dart
class SupabaseConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```
*Note: Make sure to use the **Project Anon public key** (JWT token starting with `eyJhbGci...`), not the Service Role Secret key.*

### 3. Run the App
Install dependencies and launch the application:
```bash
# Get dependencies
flutter pub get

# Run the app on your connected device or emulator
flutter run
```

## ⚙️ CI/CD

This repository includes a GitHub Actions workflow (`.github/workflows/build.yml`) that automatically builds a release **APK** and **AAB** whenever code is pushed to the `main` or `master` branches. The compiled binaries can be downloaded directly from the GitHub Actions tab.
