# Haven

<p align="center">
  <strong>A private, minimalist digital sanctuary for quiet reflection, daily journaling, weekly planning, and personal notes.</strong>
</p>

---

## Overview

**Haven** is a local-first, distraction-free Flutter application built from the ground up to provide a calm, monochromatic space for your inner life. There are no social feeds, no public profiles, no advertisements, and no mandatory sign-in. Your data belongs exclusively to you and remains safely stored on your device.

Haven embraces an achromatic design system inspired by minimalist editorial typography, featuring a pure white (`#FFFFFF`) light appearance and a true AMOLED black (`#000000`) dark appearance.

---

## Core Product Principles

1. **Private by Default:** Data is stored locally on-device. Zero third-party telemetry, tracking, or analytics.
2. **Local-First Persistence:** SQLite database on mobile and desktop platforms, with resilient JSON storage fallback on Flutter Web.
3. **Reliable Autosave:** All writing screens (Notes, Journal) silently persist changes with debounced background synchronization.
4. **No Mandatory Accounts:** Open the app and begin writing immediately without creating an account or providing an email.
5. **Calm Monochromatic Aesthetic:** Strict black-and-white theme palette with an optional 8-shade muted card tint system for notes.
6. **Intentional Limits:** Daily reflective allowance of 10 random question answers per day to preserve thoughtfulness and prevent mindless scrolling.

---

## Key Features & Screen Tour

### 1. Home Dashboard
- **Recently Saved Notes:** Two-column responsive card grid displaying your recent writing with relative time formatting (e.g., *Today*, *Yesterday*, *3d ago*).
- **Responsive Container:** Constrained 640px max-width boundary providing desktop and tablet elegance.
- **Empty State:** Thoughtful starter prompts encouraging your first entry.

### 2. Daily Journaling
- **Date Navigation Bar:** Seamless date switcher with day-by-day forward/back navigation.
- **7-Day Strip:** Monday-to-Sunday interactive week view with status dots highlighting logged entries.
- **Today's Entry Card:** Overview card with quick edit and view triggers.
- **Chronological History:** List of past reflections grouped with timestamps.
- **Journal Editor Screen:** Fullscreen, distraction-free writing environment with autosave, word count, character count, and entry deletion.

### 3. Notes Library & Rich Editor
- **Category Filter Chips:** Instant filtering across *All*, *Personal*, *People*, *Ideas*, and *Other*.
- **Search Bar:** Real-time text search querying note titles, body content, and categories.
- **Note Editor Screen:**
  - Dedicated plain-text canvas with automatic focus.
  - Options bottom sheet with **8 restrained color swatches** (*Default Neutral, Warm Cream, Pale Sage, Soft Clay, Muted Slate, Dusty Rose, Pale Sand, Deep Charcoal*).
  - Text size toggle (*Small 14pt, Medium 16pt, Large 18pt*).
  - Undo / Redo controls.
  - Note duplication and deletion with safe confirmation dialogs.

### 4. Discover & Introspective Reflection
- **Daily Reflection Card:** A single deterministic question presented every day, with inline answers and editing.
- **"Get to know yourself" 2x2 Grid:** Four curated introspective pathways:
  - *My Story* (Roots, childhood, beliefs, defining seasons)
  - *My People* (Mentors, friendships, gratitude, relationships)
  - *My Interests* (Curiosity, craft, rituals, books, film)
  - *My Future* (Aspirations, fears, longings, intentional focus)
- **Daily Limit Enforcement:** Strict ceiling of 10 random responses per day to encourage depth over volume.
- **Template Carousel:** Horizontal preview cards leading directly into pre-structured note templates.

### 5. Curated Template Catalog
- 12 pre-loaded thought structures:
  - *Personal Profile*, *People I Want to Remember*, *Annual & Seasonal Direction*
  - *Weekly Reset*, *Daily Rhythm & Habits*, *Project Clarity & Scope*
  - *Important Life Memories*, *Books Worth Remembering*, *Movies That Stayed With Me*
  - *Quiet Evening Decompression*, *Decision Framing & Tradeoffs*, *Places I Have Been*
- **One-Tap Note Creation:** Instantly turns any template into an independent, editable note.

### 6. Weekly Planner & Goals
- **Weekly Task Management:** Reorderable tasks with custom due dates and notes.
- **Monday Rollover:** Automatic carry-forward tool that brings unfinished tasks into the new week.
- **Sunday Weekly Review:** Five-question structured reflection questionnaire evaluating wins, challenges, and upcoming changes.
- **Monthly & Yearly Direction:** Separate goal trackers categorized by intentional timeframe.

### 7. Private People Directory
- Personal directory independent of your phone contacts.
- Track relationship types (*Friend, Family, Mentor, Colleague, Collaborator*), birthdays, anniversaries, and personal context notes.

### 8. Settings & Privacy Controls
- **Monastic Theme Selector:** *System*, *Light (Pure White)*, or *AMOLED Dark (True Black #000000)*.
- **Biometric App Lock:** Local biometric authentication (Face ID / Fingerprint / Device PIN) with fullscreen shield protection.
- **Quiet Notification Reminders:**
  - Daily Journaling Reminder (configurable time)
  - Monday Weekly Plan Reminder (9:00 AM)
  - Sunday Weekly Review Reminder (7:00 PM)
- **Backup & Restore:** Portable JSON file export/import and Google Drive cloud backup.
- **Clear All Data:** Secure double-confirmation wipe that resets all tables and re-seeds starter templates.

---

## Application Architecture

Haven uses a clean feature-first architecture with clear separation between UI, state management, and persistence layers:

```
lib/
├── core/
│   ├── database/          # DatabaseService (SQLite FFI + Web SharedPreferences fallback)
│   ├── models/            # Immutable models (Note, JournalEntry, PlannerTask, Question, Person, Settings)
│   ├── services/          # BackupService, NotificationService, AuthLockService, SeedService
│   ├── state/             # HavenState (ChangeNotifier global provider)
│   ├── theme/             # HavenTheme, HavenColors, HavenTypography
│   └── widgets/           # HavenHeader, HavenBottomNav, HavenResponsiveContainer, HavenEmptyState
├── features/
│   ├── discover/          # DiscoverScreen, QuestionAnswerScreen, PreviousAnswersScreen
│   ├── home/              # HomeScreen (Recently saved notes grid)
│   ├── journal/           # JournalScreen, JournalEditorScreen
│   ├── notes/             # NotesScreen, NoteEditorScreen
│   ├── people/            # PeopleScreen (Contact-free private directory)
│   ├── planner/           # PlannerScreen (Weekly tasks, Sunday review, Goals)
│   ├── settings/          # SettingsScreen
│   ├── templates/         # TemplatesScreen
│   └── main_shell.dart    # App Shell (HavenHeader + BottomNav + Auth Lock Overlay)
└── main.dart              # App entry point
```

### Persistence Strategy
- **Mobile (iOS, Android) & Desktop (macOS, Linux, Windows):** Native SQLite engine managed via `sqflite` and `sqflite_common_ffi`.
- **Flutter Web:** Persistent JSON-serialized key-value store using `shared_preferences` fallback, ensuring instant browser execution without requiring WASM-native SQLite binaries.

---

## Getting Started & Local Run

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.24+ (Tested on Flutter 3.47.7 / Dart 3.13.5).
- macOS, Windows, Linux, Android Studio, or Google Chrome.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/bhvyshrm/Haven.git
   cd Haven
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run automated tests to verify your environment:
   ```bash
   flutter test
   ```

4. Launch the application:
   - **Chrome Web:**
     ```bash
     flutter run -d chrome
     ```
   - **macOS Desktop:**
     ```bash
     flutter run -d macos
     ```
   - **Connected Mobile Device:**
     ```bash
     flutter run
     ```

---

## Automated Test Suite

Haven features a comprehensive automated testing suite covering models, persistence, daily allowance limits, planner carry-forward, JSON backup serialization, and widget navigation:

```bash
flutter test
```

### Test Suites Included:
- `test/unit/haven_models_and_persistence_test.dart`: Note CRUD, journal date uniqueness, people archive, and 520+ question seed catalog.
- `test/unit/planner_and_rollover_test.dart`: Weekly task creation, reordering, Monday unfinished carry-forward, Sunday review persistence, and goals.
- `test/unit/questions_and_daily_limits_test.dart`: Deterministic daily question rotation and strict 10 question/day random response limit.
- `test/unit/backup_and_restore_serialization_test.dart`: Portable JSON snapshot generation, table restoration, and corrupt payload rejection.
- `test/widget_test.dart`: MainShell rendering, canonical lowercase "haven" wordmark, 4 primary destinations (Home, Journal, Notes, Discover), tab switching, and theme toggling.

---

## Google Drive Cloud Backup Setup

Haven supports private cloud backup to your personal Google Drive using the hidden `appDataFolder` scope (which isolates Haven backup files from your general Drive files):

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a project (e.g. `Haven Private Backup`).
3. Under **APIs & Services**, enable the **Google Drive API**.
4. Configure the **OAuth Consent Screen** (User Type: *External*, add your email under Test Users).
5. Add the scope `https://www.googleapis.com/auth/drive.appdata`.
6. Under **Credentials**, create an **OAuth 2.0 Client ID**:
   - For **Android**: specify your package name (`com.haven.haven`) and SHA-1 fingerprint.
   - For **iOS / macOS**: configure the bundle identifier and URL schemes.
   - For **Web**: add your authorized JavaScript origins and redirect URIs.
7. Note: If OAuth client credentials are not configured, Haven displays a transparent, informative dialog explaining the setup and recommends using the instant, zero-setup **Export Backup File (.json)** option.

---

## License

Private and open for personal use. Created with care for quiet minds.
