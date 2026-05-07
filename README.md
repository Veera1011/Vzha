# VZHA — The Ultimate Developer Hub 🚀

**VZHA** is a premium, all-in-one productivity suite for developers. Built with **Flutter** and **Supabase**, it brings together news, security, collaboration, and AI assistance into a single, high-performance experience.

![Premium Design](https://img.shields.io/badge/Design-Premium-blueviolet?style=for-the-badge)
![Tech Stack](https://img.shields.io/badge/Stack-Flutter_%7C_Supabase_%7C_Groq_AI-blue?style=for-the-badge)

## ✨ Modernized Features

*   🪄 **AI Assistant:** A dedicated, standalone AI screen featuring **Groq (Llama 3)** integration. Get instant package summaries, code explanations, and security advice with a stunning glassmorphism UI.
*   📰 **Real-time News Feed:** Stay ahead of the curve with a curated tech feed (Dev.to, Hacker News, GitHub Trending) that refreshes every **2 hours** to ensure zero stale content.
*   📦 **Multi-Ecosystem Package Tracker:** Track the latest versions across **NPM (JS)**, **Pub.dev (Dart)**, **Maven (Java/Kotlin)**, and **PyPI (Python)**.
*   🚨 **Proactive Security Alerts:** Integrated **OSV.dev** vulnerability scanning for all supported ecosystems.
*   💬 **Advanced Developer Chat:** Real-time collaboration rooms with **smart unread badges**, "last read" persistence, and rich text formatting for code snippets.
*   📍 **Location-Aware Context:** Optimized timing and context services powered by precise location verification.
*   🎨 **Customizable DNA:** Tailor every detail! Custom primary colors, font selections (Inter, Roboto, etc.), and scaling that reflect across the entire app ecosystem.
*   🔔 **Universal Feedback:** Modern SnackBar system providing instant feedback for all user actions.

## 🛠️ Technology Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend** | Flutter (Material 3 + Glassmorphism) |
| **Backend** | Supabase (Postgres, Auth, RLS) |
| **Intelligence** | Groq AI (Llama 3 70B) |
| **State** | Provider |
| **Storage** | SharedPreferences (Local Caching) |
| **Services** | Geolocator, Share Plus, URL Launcher |

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (3.24+ recommended)
*   A [Supabase](https://supabase.com/) Project
*   A [Groq](https://groq.com/) API Key

### 1. Database Setup
Execute the `supabase_schema.sql` in your Supabase SQL Editor. This initializes tables for:
*   `news_feed` (with automated 2hr refresh logic)
*   `saved_items`
*   `chat_messages` & `chat_rooms`

### 2. Configuration
Create a `.env` file or use `--dart-define` to provide credentials:
```bash
GROQ_API_KEY=your_key_here
```

Update `lib/core/constants/supabase_constants.dart` with your URL and Anon Key.

### 3. Build & Run
```bash
flutter pub get
flutter run --dart-define=GROQ_API_KEY=your_key_here
```

## ⚙️ CI/CD & Delivery
Automated via GitHub Actions. Every push to `main` generates a fresh **APK** and **AAB** build, available for download in the Actions tab.

---
*Built with ❤️ for the Developer Community.*
