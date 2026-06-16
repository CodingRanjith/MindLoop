# MindLoop — `lib/` Pages & Status

This document lists every screen/page in the MindLoop Flutter app, where it lives, how to reach it, and whether it is **complete**, **incomplete**, or **pending**.

> **Last reviewed:** June 2026  
> **Routes source:** `routes/app_router.dart`  
> **Total routed screens:** 32 (including 2 legacy redirects)

---

## Status legend

| Status | Meaning |
|--------|---------|
| ✅ **Complete** | UI and core behavior work end-to-end with local storage/services. |
| 🟡 **Incomplete** | Screen exists and is usable, but important features are missing, demo-only, or redirected elsewhere. |
| ⏳ **Pending** | Placeholder, roadmap-only, or not implemented yet. |

---

## App navigation overview

```
Splash → Onboarding (first run) → Login/Signup
                                      ↓
                    ┌─────────────────────────────────────┐
                    │         HomeShell (bottom nav)       │
                    ├──────────┬──────────┬───────┬───────┤
                    │   Home   │ Calendar │Finance│Profile│
                    └──────────┴──────────┴───────┴───────┘
```

**Bottom navigation tabs** (`presentation/screens/home/home_shell.dart`):

| Tab | Route | Screen |
|-----|-------|--------|
| Home | `/home` | Dashboard |
| Calendar | `/calendar` | Calendar |
| Finance | `/finance/dashboard` | PFM Dashboard |
| Profile | `/profile` | Profile |

---

## 1. App entry & authentication

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| Splash | `/splash` | `presentation/screens/splash/splash_screen.dart` | ✅ Complete | Animated logo; triggers auth check via `AuthBloc`. |
| Onboarding | `/onboarding` | `presentation/screens/onboarding/onboarding_screen.dart` | ✅ Complete | 3-slide intro; marks onboarding done in SharedPreferences. |
| Login | `/login` | `presentation/screens/auth/login_screen.dart` | 🟡 Incomplete | UI complete. Auth is **local only** (SharedPreferences), not Firebase. |
| Signup | `/signup` | `presentation/screens/auth/signup_screen.dart` | 🟡 Incomplete | Same as login — no real backend or email verification. |
| Forgot password | `/forgot` | `presentation/screens/auth/forgot_password_screen.dart` | 🟡 Incomplete | Demo only — shows snackbar *"Connect Firebase Auth for production"*. |

**Pending auth work:** Firebase Auth, Google Sign-In, real password reset, session sync across devices.

---

## 2. Home tab (Dashboard)

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| Dashboard (Hub) | `/home` | `presentation/screens/dashboard/dashboard_screen.dart` | ✅ Complete | Main control center (~1900 lines). Greeting, module cards, quick links. |
| → Reminders module | (in-dashboard) | same file — `_RemindersModuleView` | ✅ Complete | List, filters, create/detail navigation, stats. |
| → Future Works module | (in-dashboard) | same file — `_FutureModuleView` | ⏳ Pending | Preview cards only; links to `/future`. |
| Calculator | `/calculator` | `presentation/screens/calculator/calculator_screen.dart` | ✅ Complete | Basic arithmetic; usage tracked for hub footer. |
| Settings | `/settings` | `presentation/screens/settings/settings_screen.dart` | 🟡 Incomplete | See [Settings gaps](#settings-gaps) below. |

### Settings gaps

| Feature | Status |
|---------|--------|
| Currency picker | ✅ Works (persisted) |
| Expense reminder section | ✅ Works |
| Alarm permissions helper | ✅ Works |
| Privacy / Terms links | ✅ Works |
| Notifications toggle | 🟡 UI only — not persisted |
| Haptic feedback toggle | 🟡 UI only — not persisted |
| Dynamic theme toggle | 🟡 UI only — not persisted |
| Language picker | ⏳ `onTap: () {}` — not implemented |

---

## 3. Calendar tab

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| Calendar | `/calendar` | `presentation/screens/calendar/calendar_screen.dart` | ✅ Complete | Month + agenda views, category filter, reminder dots, tap to detail. |

---

## 4. Finance tab (PFM — Personal Finance Module)

All finance screens use the **PFM drawer** (`widgets/pfm/pfm_drawer.dart`) for sub-navigation.

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| PFM Dashboard | `/finance/dashboard` | `presentation/screens/pfm/pfm_dashboard_screen.dart` | ✅ Complete | Balance, health score, charts, category overview, quick actions. |
| Transactions | `/finance/transactions` | `presentation/screens/pfm/pfm_transactions_screen.dart` | ✅ Complete | Search, income/expense filter, add via bottom sheets. |
| Analytics | `/finance/analytics` | `presentation/screens/pfm/pfm_analytics_screen.dart` | ✅ Complete | Income/expense trends, category charts. |
| Budget | `/finance/budget` | `presentation/screens/pfm/pfm_budget_screen.dart` | ✅ Complete | 50/30/20, 60/20/20, custom rules; bucket status. |
| Goals | `/finance/goals` | `presentation/screens/pfm/pfm_goals_screen.dart` | ✅ Complete | CRUD goals, progress bars, add sheet. |
| Loans | `/finance/loans` | `presentation/screens/pfm/pfm_loans_screen.dart` | ✅ Complete | EMI tracking, due dates, add sheet. |
| Net Worth | `/finance/net-worth` | `presentation/screens/pfm/pfm_net_worth_screen.dart` | ✅ Complete | Assets & liabilities list, add sheet. |
| Export Report | `/finance/export` | `presentation/screens/pfm/pfm_export_screen.dart` | ✅ Complete | Excel, PDF, CSV export via `FinanceExportService`. |
| AI Insights | `/finance/insights` | `presentation/screens/pfm/pfm_insights_screen.dart` | 🟡 Incomplete | Rule-based text insights (not real AI/ML). |
| Finance Notifications | `/finance/notifications` | `presentation/screens/pfm/pfm_notifications_screen.dart` | 🟡 Incomplete | **Derived** alerts from budget/loals data — not a push notification inbox. |

**Data layer:** Hive local storage (`data/repositories/pfm_repository_impl.dart`).

**Legacy redirects (not real pages):**

| Route | Redirects to | File |
|-------|--------------|------|
| `/budget` | `/finance/dashboard` | `presentation/screens/budget/budget_screen.dart` (unused — router redirects first) |
| `/finance` | `/finance/dashboard` | — |
| `/analytics` | `/finance/analytics` | `presentation/screens/analytics/analytics_screen.dart` |

### PFM add sheets (not full pages)

| Component | File | Status |
|-----------|------|--------|
| Add transaction / goal / loan / net-worth sheets | `presentation/screens/pfm/pfm_add_sheets.dart` | ✅ Complete |

---

## 5. Profile tab

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| Profile | `/profile` | `presentation/screens/profile/profile_screen.dart` | 🟡 Incomplete | Hub menu only — several items redirect to other screens instead of dedicated pages. |

| Menu item | Current behavior | Dedicated page? |
|-----------|------------------|-----------------|
| Personal Information | → `/settings` | ⏳ Pending |
| Bank Accounts | → `/finance/net-worth` | ⏳ Pending (reuses Net Worth) |
| Payment Methods | → `/finance/transactions` | ⏳ Pending |
| Categories | → `/finance/budget` | ⏳ Pending |
| Backup & Restore | → `/settings` | ⏳ Pending (API exists in repository, **no UI**) |
| Export Data | → `/finance/export` | ✅ Uses export screen |
| Expense Reminders | → `/settings` | ✅ Section in settings |
| Logout | Auth logout | ✅ Works |

**Pending profile work:** Dedicated Personal Info editor, Backup/Restore UI (`exportBackupJson` / `restoreBackupJson` already in `PfmRepository`).

---

## 6. Reminders (full-screen routes)

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| Create / Edit reminder | `/reminder/create` | `presentation/screens/reminder/reminder_create_screen.dart` | ✅ Complete | Title, note, schedule, repeat, category, image, built-in/custom ringtones. |
| Reminder detail | `/reminder/:id` | `presentation/screens/reminder/reminder_detail_screen.dart` | ✅ Complete | View, edit, complete, delete, snooze. |
| Reminder alert (full-screen) | `/alert` | `presentation/screens/reminder/reminder_alert_screen.dart` | ✅ Complete | Cinematic alarm UI, sound, snooze, dismiss, optional rigging image mode. |
| Expense reminder alert | `/expense-alert` | `presentation/screens/pfm/expense_reminder_alert_screen.dart` | ✅ Complete | Prompts user to log daily spending. |

---

## 7. Legal & roadmap

| Page | Route | File | Status | Notes |
|------|-------|------|--------|-------|
| Privacy Policy | `/privacy` | `presentation/screens/legal/privacy_policy_screen.dart` | ✅ Complete | Static in-app policy text. |
| Terms of Service | `/terms` | `presentation/screens/legal/terms_of_service_screen.dart` | ✅ Complete | Static terms text. |
| Future Features | `/future` | `presentation/screens/future/future_features_screen.dart` | ⏳ Pending | Coming-soon gallery only. |

### Future features (all ⏳ Pending)

Listed in `future_features_screen.dart`:

- AI Assistant
- Smart Voice AI
- Wearable Sync (Apple Watch & Wear OS)
- Family Sharing
- Smart Home / IoT
- AI Mood Music
- Dynamic Wallpapers

---

## Summary counts

| Status | Count | Pages |
|--------|-------|-------|
| ✅ Complete | **20** | Splash, Onboarding, Dashboard, Reminders module, Calculator, Calendar, all core PFM screens (8), Reminder create/detail/alert, Expense alert, Privacy, Terms |
| 🟡 Incomplete | **9** | Login, Signup, Forgot password, Settings, Profile, PFM Insights, PFM Notifications, Auth layer (local-only) |
| ⏳ Pending | **8+** | Future Works module, Future Features screen, Language picker, Backup/Restore UI, Personal Info page, Bank Accounts page, Payment Methods page, all roadmap AI/voice/wearable features |

---

## Folder structure (screens)

```
presentation/screens/
├── analytics/          # Legacy redirect → PFM analytics
├── auth/               # login, signup, forgot_password
├── budget/             # Legacy redirect → PFM dashboard
├── calculator/
├── calendar/
├── dashboard/          # Home hub + reminders + future preview
├── future/             # Roadmap gallery (pending)
├── home/               # home_shell.dart (bottom nav shell)
├── legal/              # privacy, terms
├── onboarding/
├── pfm/                # Finance module (10 screens + add sheets)
├── profile/
├── reminder/           # create, detail, alert
├── settings/           # settings + expense_reminder_settings_section
└── splash/
```

---

## Related non-page files

| Area | Location |
|------|----------|
| Routing | `routes/app_router.dart` |
| App root / BLoC providers | `app.dart`, `main.dart` |
| DI | `core/di/injection.dart` |
| Themes | `themes/` |
| Shared widgets | `widgets/` |
| Services (notifications, export, alarms) | `services/` |
| BLoCs | `presentation/blocs/` |

---

## Recommended next steps (by priority)

1. **Firebase Auth** — replace local SharedPreferences auth; wire forgot-password flow.
2. **Backup & Restore UI** — connect existing `PfmRepository.exportBackupJson()` / `restoreBackupJson()`.
3. **Settings persistence** — save notification, haptics, and theme toggles.
4. **Language support** — implement locale picker and i18n.
5. **Profile sub-pages** — Personal Information, dedicated Bank/Payment/Categories screens.
6. **Real AI Insights** — replace rule-based strings with ML or cloud API (optional).
7. **Future roadmap** — AI Assistant, Voice AI, Wearables, etc.

---

*For setup, architecture, and product vision see the root [README.md](../README.md).*
