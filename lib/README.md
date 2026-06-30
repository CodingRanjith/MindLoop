# MindLoop — `lib/` Module Structure

Feature-first **Clean Architecture**. Each module owns its data, domain, presentation, and module-specific services/utils.

> **Last updated:** June 2026  
> **Routes:** `app/router/app_router.dart`  
> **DI:** `app/di/injection.dart`

---

## Top-level layout

```text
lib/
├── main.dart                 # App entry point
├── app/                      # App shell (router, DI, root widget)
│   ├── app.dart
│   ├── di/injection.dart
│   └── router/app_router.dart
├── core/                     # Cross-module shared code
│   ├── constants/app_constants.dart
│   ├── services/             # e.g. notification_service
│   └── utils/                # app_responsive, theme_preferences, etc.
├── shared/                   # Reusable UI & theme (no business logic)
│   ├── theme/
│   └── widgets/
└── modules/                  # Feature modules (see below)
```

---

## Module pattern

Full modules (auth, reminder, finance) follow:

```text
modules/<name>/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/          # module-only widgets
├── services/             # optional
└── core/                 # optional — module constants & utils
    ├── constants/
    └── utils/
```

Presentation-only modules (calculator, pomodoro, legal, etc.) contain only `presentation/pages/` plus optional `core/` or `services/`.

---

## Modules

| Module | Path | Layers | Description |
|--------|------|--------|-------------|
| **auth** | `modules/auth/` | data · domain · presentation | Login, signup, forgot password, `AuthBloc` |
| **reminder** | `modules/reminder/` | data · domain · presentation · services | Reminders, calendar, alarms, ringtones |
| **finance** | `modules/finance/` | data · domain · presentation · services | PFM, budget, transactions, export, expense reminders |
| **dashboard** | `modules/dashboard/` | presentation | Home hub & reminders module view |
| **home** | `modules/home/` | presentation | Bottom navigation shell |
| **settings** | `modules/settings/` | presentation | App settings, expense reminder config |
| **profile** | `modules/profile/` | presentation | Profile hub |
| **onboarding** | `modules/onboarding/` | presentation | Splash & first-run onboarding |
| **calculator** | `modules/calculator/` | presentation · core | Calculator tool |
| **pomodoro** | `modules/pomodoro/` | presentation · services · core | Focus timer |
| **legal** | `modules/legal/` | presentation | Privacy policy & terms |
| **future** | `modules/future/` | presentation | Roadmap / coming-soon gallery |

---

## Navigation

```
Splash → Onboarding (first run) → Login/Signup
                                      ↓
                    ┌─────────────────────────────────────┐
                    │         HomeShell (bottom nav)       │
                    ├──────────┬──────────┬───────┬───────┤
                    │   Home   │ Calendar │Finance│Profile│
                    └──────────┴──────────┴───────┴───────┘
```

| Tab | Route | Module |
|-----|-------|--------|
| Home | `/home` | dashboard |
| Calendar | `/calendar` | reminder |
| Finance | `/finance/dashboard` | finance |
| Profile | `/profile` | profile |

---

## Import conventions

Use package imports with the module path:

```dart
// Auth
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';

// Reminder
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';

// Finance
import 'package:mindloop/modules/finance/presentation/pages/pfm_dashboard_screen.dart';

// Shared UI
import 'package:mindloop/shared/widgets/glass_card.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

// App / core
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/core/constants/app_constants.dart';
```

**Rules:**
- Module code should not import from another module's `data/` layer — go through `domain/` contracts or shared `core/`.
- Put cross-module widgets in `shared/widgets/`.
- Register all repositories and blocs in `app/di/injection.dart`.

---

## Adding a new module

1. Create `modules/<feature>/` with the layers you need.
2. Add pages to `presentation/pages/`.
3. Register routes in `app/router/app_router.dart`.
4. Wire repositories/blocs in `app/di/injection.dart`.
5. Use `shared/` for theme and generic widgets.

---

## Screen status

See the tables below for implementation status. Routes are defined in `app/router/app_router.dart`.

### Status legend

| Status | Meaning |
|--------|---------|
| ✅ Complete | UI and core behavior work end-to-end with local storage/services |
| 🟡 Incomplete | Usable but missing features, demo-only, or redirected |
| ⏳ Pending | Placeholder or roadmap-only |

### Auth (`modules/auth/`)

| Page | Route | Status |
|------|-------|--------|
| Login | `/login` | 🟡 Local auth only |
| Signup | `/signup` | 🟡 Local auth only |
| Forgot password | `/forgot` | 🟡 Demo snackbar |

### Finance (`modules/finance/`)

| Page | Route | Status |
|------|-------|--------|
| PFM Dashboard | `/finance/dashboard` | ✅ |
| Transactions | `/finance/transactions` | ✅ |
| Analytics | `/finance/analytics` | ✅ |
| Budget | `/finance/budget` | ✅ |
| Goals / Loans / Net Worth / Export | `/finance/*` | ✅ |
| AI Insights | `/finance/insights` | 🟡 Rule-based |
| Finance Notifications | `/finance/notifications` | 🟡 Derived alerts |

### Reminder (`modules/reminder/`)

| Page | Route | Status |
|------|-------|--------|
| Calendar | `/calendar` | ✅ |
| Create / Edit | `/reminder/create` | ✅ |
| Detail | `/reminder/:id` | ✅ |
| Full-screen alert | `/alert` | ✅ |
| Expense alert | `/expense-alert` | ✅ (finance module page) |

### Other modules

| Module | Key routes | Status |
|--------|------------|--------|
| onboarding | `/splash`, `/onboarding` | ✅ |
| dashboard | `/home` | ✅ |
| settings | `/settings` | 🟡 Some toggles UI-only |
| profile | `/profile` | 🟡 Hub redirects |
| calculator | `/calculator` | ✅ |
| pomodoro | `/pomodoro` | ✅ |
| legal | `/privacy`, `/terms` | ✅ |
| future | `/future` | ⏳ Coming-soon cards |

---

*For setup, architecture overview, and product vision see the root [README.md](../README.md).*
