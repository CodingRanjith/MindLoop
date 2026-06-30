# MindLoop

**Futuristic smart reminder & budget management** for Android and iOS. Built with **Flutter**, **Clean Architecture**, and **BLoC**.

MindLoop is a next-generation reminder and memory assistant: smart reminders, emotional notification experiences, budget tracking, immersive UI/UX, and AI-inspired personalization—designed to feel premium, cinematic, and distinct from traditional reminder apps.

---

## Table of contents

- [Goals](#goals)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Screens](#screens)
- [UI & UX](#ui--ux)
- [Design system](#design-system)
- [Dynamic backgrounds](#dynamic-backgrounds)
- [Firebase & data model](#firebase--data-model)
- [Notifications](#notifications)
- [Security & accessibility](#security--accessibility)
- [Performance](#performance)
- [Branding assets](#branding-assets)
- [Getting started](#getting-started)
- [Configuration checklist](#configuration-checklist)
- [Roadmap](#roadmap)

---

## Goals

### Primary

- Help users never forget important events  
- Create emotional, memorable reminder moments  
- Deliver immersive, futuristic UI  
- Unify reminders and budgets in one experience  
- Provide premium mobile UX  

### Secondary

- AI-inspired personalization  
- Mood-based themes  
- Smart integrations (future)  
- Cross-device synchronization  

---

## Features

### Smart reminder system

- Create reminders with future date & time  
- Notes, categories, and optional images  
- Custom ringtone / music selection  
- Repeating reminders  
- Voice reminder creation (planned / advanced)  
- Full-screen reminder alert experience  

### Reminder trigger experience

When a reminder fires:

- Full-screen popup  
- Music / ringtone playback  
- Image and notes display  
- Dynamic animated background  
- Vibration  
- Snooze and dismiss with polished transitions  

### Budget management

- Income and expenses  
- Monthly budget planning  
- Spending analytics and savings tracking  
- Budget-related reminders  
- Dashboard: balance, income/expense summary, savings visualization, payment reminders  

### Dashboard (control center)

Widgets and sections for:

- Today’s reminders  
- Upcoming reminders  
- Budget overview  
- Calendar preview  
- Quick actions  
- AI suggestions  
- Mood cards  
- Recent activity  
- **Coming soon** feature cards  

### Coming soon (premium cards)

- AI Assistant  
- Smart Voice AI  
- Wearable sync  
- Family sharing  
- Smart home integration  
- AI mood music  
- Dynamic wallpapers  

Cards use glow effects, lock animations, and futuristic styling.

### Advanced (target capabilities)

- AI reminder suggestions  
- Smart repeat patterns  
- Cloud sync (Firestore)  
- Offline support  
- Multi-language  
- Smart search  
- Voice-to-reminder  
- Animated countdowns  
- Reminder sharing  
- Theme customization  

---

## Tech stack

| Layer | Technology |
|--------|------------|
| Framework | Flutter (latest stable), Dart |
| State management | BLoC |
| Architecture | Clean Architecture |
| Backend | Firebase |
| Database | Cloud Firestore |
| Push | Firebase Cloud Messaging |
| Local notifications | `flutter_local_notifications` |
| Local storage | Hive, SharedPreferences |
| Animations | Lottie, Rive, `flutter_animate` |
| Audio | `just_audio`, `audioplayers` |

---

## Architecture

**Pattern:** Clean Architecture  

| Layer | Responsibility |
|--------|----------------|
| **Presentation** | UI, screens, widgets, BLoC |
| **Domain** | Entities, use cases |
| **Data** | Repositories, Firebase services, DTOs / models |

Data flows inward: UI → BLoC → use cases → repositories → Firebase / local stores.

---

## Project structure

Module-wise **Clean Architecture** under `lib/`:

```text
lib/
├── main.dart
├── app/                    # App shell, router, dependency injection
├── core/                   # Cross-module constants, services, utils
├── shared/                 # Shared theme & widgets
└── modules/
    ├── auth/
    ├── reminder/
    ├── finance/
    ├── dashboard/
    ├── home/
    ├── settings/
    ├── profile/
    ├── onboarding/
    ├── calculator/
    ├── pomodoro/
    ├── legal/
    └── future/
```

Each full module contains `data/`, `domain/`, `presentation/` (and optional `services/`, `core/`). See [lib/README.md](lib/README.md) for import conventions and per-module details.

- **app** — `MindLoopApp`, `go_router`, GetIt DI  
- **core** — app-wide constants, notification service, shared utils  
- **shared** — theme, glass cards, dynamic backgrounds, generic widgets  
- **modules/** — feature-owned blocs, repositories, screens, and module services  

---

## Screens

| Screen | Purpose |
|--------|---------|
| Splash | Animated logo, glow, cinematic intro |
| Onboarding | First-run experience |
| Login / Signup / Forgot password | Firebase Auth |
| Home dashboard | Central hub |
| Reminder creation | Full create flow |
| Reminder details | View / edit |
| Calendar view | Schedule overview |
| Budget manager | Income / expenses |
| Analytics | Charts and summaries |
| Notification popup | Full-screen alert UI |
| Profile | User info |
| Settings | Preferences, theme, notifications |
| Future features | Coming-soon gallery |

---

## UI & UX

### Philosophy

Futuristic, emotional, premium, interactive, cinematic—inspired by polished consumer apps (e.g. Apple-like clarity, fluid motion, assistant-style surfaces).

### Visual language

- Glassmorphism and subtle neumorphism  
- Dynamic gradients and neon accents  
- Floating motion and smooth page transitions  
- Blur, depth, and selective neon glow  
- Modern typography and responsive layouts  
- Haptic feedback where appropriate  

### Animation system

- Page transitions  
- Floating particles  
- Dynamic backgrounds  
- Music-reactive or pulse-style effects (where applicable)  
- Notification and button interactions  
- Card entrance animations  

---

## Design system

### Primary palette

- Neon purple  
- Electric blue  
- Soft pink glow  
- Black / dark gradients  

### Theme modes

- Dark (default)  
- Dynamic theme engine (mood / time / category-driven adjustments)  

### Components

- Premium cards, glowing primary actions  
- Animated bottom navigation  
- Floating action patterns  
- Futuristic dashboard widgets  

---

## Dynamic backgrounds

Background mood can reflect:

- Time of day (e.g. night: stars / moon; morning: sunrise glow)  
- User or app “mood”  
- Reminder category (e.g. birthday: confetti / balloons; romantic: hearts)  
- Weather (when integrated)  
- Music context (when integrated)  

---

## Firebase & data model

### Auth

- Email / password  
- Google Sign-In  
- Firebase Authentication  

### Suggested Firestore collections

**`users`**

| Field | Description |
|-------|-------------|
| `userId` | Document ID / UID |
| `username` | Display name |
| `email` | Email |
| `profileImage` | URL or storage path |

**`reminders`**

| Field | Description |
|-------|-------------|
| `reminderId` | Unique id |
| `title` | Title |
| `date` / `time` | Schedule |
| `note` | Text |
| `image` | Optional attachment |
| `music` | Selected sound asset / URI |
| `category` | Category key |
| `userId` | Owner (add for security rules) |

**`budgets` / transactions** (refine in implementation)

| Concern | Fields (example) |
|---------|------------------|
| Income / expenses | amount, category, date, type |
| Summary | derived or stored aggregates, savings targets |

> **Note:** Finalize indexes and composite queries with your query patterns. Lock down access with **Firestore Security Rules** (users read/write only their own data).

---

## Notifications

- Local notifications for scheduled reminders  
- FCM for remote / cross-device (when enabled)  
- Types: simple reminder, emotional reminder, budget alert, daily summary  
- Full-screen intent / high-priority channels on Android; appropriate categories on iOS  
- Snooze actions, vibration, optional custom sound  

---

## Security & accessibility

### Security

- Firestore security rules  
- Encrypted sensitive local data where needed  
- Secure authentication flows  
- No secrets in source control (use `--dart-define` or Firebase config files gitignored as appropriate)  

### Accessibility

- Scalable text  
- Large touch targets  
- Dark mode tuned for contrast  
- Haptics used thoughtfully  

---

## Performance

- Prefer `const` constructors and selective rebuilds  
- Limit simultaneous heavy animations; use `RepaintBoundary` where it helps  
- Lazy lists for long feeds  
- Image caching and reasonable asset sizes  
- Fast cold start: defer non-critical work  

---

## Branding assets

### App icon

- Loop symbol  
- Neon gradient on dark base  
- Minimal, futuristic, premium finish  
- Black + purple + blue family  

### Splash

- Animated logo reveal  
- Glow and smooth transition into app shell  

### Notification icon (Android)

- Simple silhouette compatible with monochrome / tinted notification bar  

---

## Getting started

Prerequisites: **Flutter SDK** (stable), **Android Studio / Xcode** (for device builds).

```bash
cd "d:\Gayu - workspace\Mywork space\new"
flutter pub get
```

**No Android phone or emulator?** Run in the browser (easiest on Windows):

```bash
flutter run -d chrome
```

Or on Windows desktop (requires [Visual Studio](https://visualstudio.microsoft.com/) with **Desktop development with C++**):

```bash
flutter run -d windows
```

**With an Android phone:** enable USB debugging, connect the phone, then:

```bash
flutter run -d android
```

### Demo login

Use any email and a password with **6+ characters** (local auth demo; wire Firebase Auth for production).

### What's implemented

- Clean Architecture + BLoC
- All main screens (splash, onboarding, auth, dashboard, reminders, budget, calendar, analytics, profile, settings, future features, full-screen alert)
- Hive offline storage + SharedPreferences session
- Local notifications scheduling
- Futuristic UI (glass cards, dynamic backgrounds, animations, bottom nav)
- Image picker for reminders

### Firebase (optional next step)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then add `firebase_core`, `firebase_auth`, and `cloud_firestore` and connect repositories to Firestore.

### Firebase setup (summary)

1. Create a Firebase project.  
2. Add Android & iOS apps with correct package/bundle IDs.  
3. Download `google-services.json` and `GoogleService-Info.plist` into platform folders.  
4. Enable Authentication (Email, Google) and Firestore.  
5. Configure FCM and upload keys / certificates per platform docs.  

---

## Configuration checklist

When creating or updating the app:

- [ ] **Display name:** MindLoop  
- [ ] **Package name** (Android) / **bundle ID** (iOS)  
- [ ] **Launcher icon** (e.g. `flutter_launcher_icons`)  
- [ ] **Splash screen** (e.g. `flutter_native_splash` or custom)  
- [ ] **Notification icon** (Android adaptive / small icon)  
- [ ] **App metadata** — store descriptions, privacy policy URLs  
- [ ] **deeplinks / intent filters** if using full-screen notification activity (Android)  

---

## Roadmap

The product vision is a **premium reminder ecosystem**: emotional memory assistant, budget planner, AI-inspired productivity, and futuristic lifestyle surface—with continuous polish on motion, personalization, and trust (privacy, security, reliability).

---

## License

Specify your license here (e.g. MIT, proprietary).

---

## Contributing

Add team guidelines: branches, PRs, code style (`dart format`, `flutter analyze`), and commit conventions.

---

*Documentation version aligned with MindLoop specification — Futuristic reminder & budget experience.*
