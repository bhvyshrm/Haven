# Haven — Implementation Plan

## 1. Existing Assets and Environment Inspection

### 1.1 Development Environment
- **Flutter SDK**: 3.47.7 (Channel stable)
- **Dart SDK**: 3.13.5
- **OS**: macOS 27.2 (darwin-arm64)
- **Available Targets**: Chrome (Web), macOS Desktop, Android SDK 36.0.0
- **Workspace**: `/Users/bhavyasharma/Creations/Haven`
- **Source Stitch Export**: `stitch_haven_app_home_dashboard.zip`

### 1.2 Stitch Design Inventory
- `haven_monastic_editorial/DESIGN.md`: Complete design system spec (Inter typography, #FFFFFF light, #000000 AMOLED dark, 1px hairlines, 16px/20px border radii, pill chips, Lucide/Material outline icons).
- `haven_home_dashboard_light_amoled_dark_1 & 2`: TopAppBar with 'haven' wordmark + theme toggle, "Recently saved" grid (2 columns), floating pill bottom navigation.
- `haven_journal_overview & amoled_dark`: Date navigation bar, 7-day week strip (M-S) with checkmarks and today indicator, "Today's Entry" card with Continue/New action, "Previous entries" chronological list.
- `haven_journal_editor_light_theme & options_three_dot_menu`: Seamless notebook page, back arrow, date anchor, title field, multiline body, bottom sheet for Appearance (Background colour palette, Text size S/M/L), Writing Actions (Select all, Undo, Redo, Duplicate, Delete with confirmation).
- `haven_notes_library_master & amoled_dark`: Notes heading + Explore templates link, Search input + New Note button, Category filter pills (All, Personal, People, Ideas, Other), 2-column note cards with category tags, title, body preview, timestamp.
- `haven_discover_light & amoled_dark`: Daily Reflection ("What is something small that made today better?" with Answer & Previous answers), "Get to know yourself" 2x2 grid (My Story, My People, My Interests, My Future), Templates horizontal carousel with See all, "Ask me something else" random prompt generator.

---

## 2. Missing Components to Implement

1. **Flutter Project Initialization**: Scaffold native Flutter project with clean structure.
2. **Core Design System**: Achromatic theme tokens, Inter font setup, HavenAppBar, HavenBottomNavBar, custom palette definitions.
3. **Data Layer & Local Persistence**: SQLite database (via sqflite/drift or robust cross-platform SQLite/indexedDB/shared_preferences abstraction for Web + Native support) storing:
   - Notes
   - Journal entries
   - Weekly plans & task items
   - Sunday reviews
   - Monthly & yearly goals
   - Questions catalog & user responses
   - My People records
   - Seedable template catalog
   - User settings & preferences
4. **Screens & Workflows**:
   - Primary Tabs: Home, Journal Overview, Notes Library, Discover
   - Editors: Note Editor & Journal Editor (with autosave debounce, background color picker, text size selector, undo/redo, delete dialog)
   - Planning Section: Weekly planner, task reordering, Monday rollover, Sunday reflection review, Monthly/Yearly goals
   - Questions Experience: Single question answering flow, 500+ seeded question catalog, daily limit enforcement (10/day for random), response history
   - Personal Archive: My Story, My People (add, edit, notes, important dates), My Interests, My Future
   - Templates Library: Category filtering, search, template preview, "Use template" generating independent notes
   - Settings & Privacy: Theme preference (System/Light/Dark), App Lock (Biometrics/PIN check), Notification reminders, Google Drive backup/restore, Local JSON export/import, Wipe data with strong confirmation
5. **Testing Suite**: Unit tests (persistence, date logic, weekly rollover, questions, templates, backup serialization), Widget tests (navigation, theme switching, note creation, dialogs), Integration tests (end-to-end flows).
6. **Documentation & GitHub Integration**: `README.md`, `BUILD_REPORT.md`, remote origin setup, verification and push to `https://github.com/bhvyshrm/Haven.git`.

---

## 3. Architecture & Package Selection

### 3.1 Architectural Pattern
- **Feature-First Clean Architecture**:
  - `lib/core/`: theme, constants, widgets, database, services (auth, notifications, storage, backup)
  - `lib/features/home/`: Home screen, recent notes grid, state
  - `lib/features/journal/`: Journal overview, week strip, date picker, journal editor
  - `lib/features/notes/`: Notes library, category filters, search, note editor
  - `lib/features/discover/`: Daily reflection, prompt answers, questions flow
  - `lib/features/planner/`: Weekly planner, Monday rollover, Sunday review, Goals
  - `lib/features/people/`: My People directory & profiles
  - `lib/features/templates/`: Template browser, template seed catalog, note generator
  - `lib/features/settings/`: Preferences, app lock, backup/restore, export
- **State Management**: Lightweight, testable `ChangeNotifier` / `ValueNotifier` repositories and providers, avoiding heavy boilerplate while ensuring reactive updates across all tabs.

### 3.2 Key Dependencies
- `provider`: Clean, battle-tested dependency injection and state management.
- `sqflite` + `sqflite_common_ffi` (or web-compatible sqlite / shared_preferences hybrid storage): Robust local SQL storage that works seamlessly on iOS, Android, macOS, and fallback/indexedDB for Web.
- `intl`: Local date formatting and week calculation.
- `uuid`: Secure, unique ID generation for records.
- `flutter_local_notifications`: Scheduled reminders (Monday plan, Sunday review, daily journal).
- `local_auth`: Biometric and device PIN authentication for App Lock.
- `file_picker` / `share_plus`: Backup file export and import.
- `google_sign_in` / `googleapis`: Google Drive backup integration (with safe graceful fallback if unconfigured).

---

## 4. Data Model & Storage Design

### Tables:
1. `notes`: `id`, `title`, `body`, `category`, `color_hex`, `font_size`, `created_at`, `updated_at`, `is_pinned`, `is_archived`
2. `journal_entries`: `id`, `entry_date` (YYYY-MM-DD), `title`, `body`, `color_hex`, `font_size`, `created_at`, `updated_at`
3. `planner_weeks`: `id` (e.g. 2026-W43), `year`, `week_number`, `created_at`
4. `planner_tasks`: `id`, `week_id`, `title`, `notes`, `is_completed`, `due_date`, `sort_order`, `created_at`
5. `sunday_reviews`: `id`, `week_id`, `achieved_notes`, `went_well`, `unfinished_notes`, `lessons_learned`, `changes_next_week`, `created_at`
6. `goals`: `id`, `title`, `description`, `period_type` ('monthly'/'yearly'), `target_date`, `is_completed`, `created_at`
7. `questions`: `id`, `text`, `category`, `tags`, `is_active`
8. `question_responses`: `id`, `question_id`, `answer_text`, `response_date`, `created_at`, `updated_at`
9. `people`: `id`, `name`, `relationship`, `notes`, `important_dates`, `created_at`, `updated_at`
10. `templates`: `id`, `title`, `category`, `description`, `content`, `version`
11. `settings`: key-value preferences store

---

## 5. Implementation Phases
1. **Scaffold Flutter Project & Configure Assets**
2. **Implement Core Theme & Shared Widgets** (HavenAppBar, HavenBottomNavBar, Swatches)
3. **Build Database Engine & Repositories** (Native SQLite + Web storage support)
4. **Implement Home & Notes Library + Note Editor** (with real autosave & background styling)
5. **Implement Journal Overview & Journal Editor** (Week strip, day navigation, autosave)
6. **Implement Discover & Questions Engine** (Seeded 500+ questions catalog, daily limit, responses)
7. **Implement Templates Library** (Independent note spawning)
8. **Implement My People & Personal Archive**
9. **Implement Weekly Planner, Rollover & Sunday Review, Goals**
10. **Implement Settings, App Lock, Notifications & Google Drive Backup/Restore / Export**
11. **Comprehensive Automated Tests** (Unit, Widget, Integration)
12. **Static Analysis & Formatting (`flutter analyze`, `dart format`)**
13. **Local Run Verification** (Chrome / macOS)
14. **Git Repository Setup & Push to GitHub** (`https://github.com/bhvyshrm/Haven.git`)
15. **Documentation & `BUILD_REPORT.md`**
