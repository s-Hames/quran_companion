# Quran Companion (قرآن كومبانيون)
> A serene, respectful Flutter study companion for personal Quran reading, understanding, and family reflection powered by Google Gemini.

---

## 🌟 Overview

**Quran Companion** is designed for everyday family use. When reading from a physical Mushaf, readers can photograph or upload a page to identify the passage using Gemini Vision AI, or select any of the 114 Surahs and verse ranges manually.

The app generates a structured, multi-dimensional study guide distinguishing:
1. **Direct Quranic Verses**: Rendered in clear Arabic script (Amiri font, RTL direction).
2. **Translations**: Clearly labelled with source citations.
3. **Simple Explanation**: Accessible, plain-English overview of core meanings and themes.
4. **Historical Context**: Makki/Madani classification, context of revelation, and verified Sabab al-Nuzul.
5. **Related Stories & Narratives**: Quranic and established historical accounts.
6. **Lessons & Practical Reflections**: Bullet points for character, patience, gratitude, and moral choices.
7. **Scholarly Interpretations (Tafsir)**: Perspectives from classical works (e.g., Ibn Kathir, Al-Qurtubi, Al-Tabari) without fabricated citations.
8. **Spiritual Meanings & Sayings of Awliya**: Contemplations attributed to classical sages (e.g., Imam al-Ghazali, Hasan al-Basri) with transparent attribution distinctions.
9. **Contextual Q&A**: Ask Gemini questions scoped specifically to the current passage.

---

## 🎨 Visual Design & Aesthetics

- **Primary Colors**: Deep forest green (`#16423C` / `#0F2E2A`), soft sage (`#6A8E7F`), and muted olive.
- **Accents**: Subtle warm gold (`#C49A45`).
- **Surfaces**: Warm ivory/cream background (`#FAF7F2`) with clean card containers.
- **Accessibility for Older Readers**:
  - Adjustable text size controls directly in the explanation viewer and settings.
  - Large tappable controls and high contrast.
  - Distinct Quranic Arabic rendering.

---

## 👨‍👩‍👧 Family Profiles & Local Privacy

- **Three Profiles**: "Me", "Father", and "Mother" by default (editable to personal names such as "Hamid", "Baba", "Ammi").
- **Local Persistence**: All reading sessions, calendars, bookmarks, and private notes are stored strictly on the local device using SQLite (`sqflite` with desktop/testing `sqflite_common_ffi` support).
- **Zero Cloud Tracking**: No external databases, no registration, no advertising, and no analytics.
- **Data Transparency**: Only uploaded page images or selected passage references are transmitted to Google's Gemini API for processing.

---

## 🔑 Gemini API Configuration

You can configure your Gemini API key in two ways:

### Option 1: Local `.env` File (Recommended for Development)
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` and add your API key from [Google AI Studio](https://aistudio.google.com/):
   ```env
   GEMINI_API_KEY=AIzaSyYourActualKeyHere
   ```
3. The `.env` file is ignored in `.gitignore` to prevent committing secrets.

### Option 2: In-App Settings Screen (Convenient for Mobile & Family Use)
1. Launch the app.
2. Navigate to **Settings** > **Gemini AI Configuration**.
3. Tap **Enter Gemini API Key**, paste your key, and tap **Test Connection**.

> **Note**: If no API key is provided, the app runs in **Demonstration Mode**. It remains 100% usable, with sample passage scans, full manual selection of all 114 Surahs, reading calendar, bookmarks, and local SQLite notes.

---

## 🚀 Running the Application

### Prerequisites
- Flutter 3.41+ (Dart 3.11+)
- macOS / iOS / Android

### Steps
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run static analysis:
   ```bash
   flutter analyze
   ```
3. Run the automated test suite:
   ```bash
   flutter test
   ```
4. Launch on macOS desktop:
   ```bash
   flutter run -d macos
   ```
5. Or launch on a connected iOS or Android phone:
   ```bash
   flutter run
   ```

---

## 📁 Architecture & File Layout

The codebase follows clean architecture principles with strict separation of concerns:

```text
lib/
├── main.dart                          # App entrypoint, dotenv loading, SQLite init
├── app.dart                           # Root MaterialApp & 4-tab bottom navigation shell
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Forest green, sage, gold, and warm ivory tokens
│   │   └── quran_data.dart            # Full catalog of 114 Surahs with Arabic names & verse bounds
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 theme and typography
│   └── utils/
│       └── date_formatter.dart        # Friendly relative and calendar date formats
├── data/
│   ├── database/
│   │   └── app_database.dart          # SQLite schema, migrations, in-memory test injection
│   ├── models/
│   │   ├── profile.dart               # Family member profiles (Me, Father, Mother)
│   │   ├── reading_session.dart       # Reading session persistence model
│   │   ├── bookmark.dart              # Bookmark model
│   │   ├── quran_surah.dart           # Surah metadata model
│   │   ├── passage_identification.dart # Gemini Vision OCR parsing model
│   │   ├── quran_explanation.dart     # Structured explanation domain model
│   │   └── qa_message.dart            # Scoped Q&A conversation model
│   └── repositories/
│       ├── profile_repository.dart    # Profile CRUD operations
│       ├── reading_repository.dart    # Reading sessions, calendar lookup, interval-merged coverage
│       └── bookmark_repository.dart   # Bookmark management
├── features/
│   ├── home/                          # Home screen with greeting, reader pills, recent session
│   ├── journey/                       # My Journey with TableCalendar and coverage stats
│   ├── bookmarks/                     # Bookmarks filtered by session, passage, reflection
│   ├── settings/                      # Family profiles, font scaling, API key setup, export
│   ├── upload/                        # Camera/Gallery photo picker and Gemini scanning
│   ├── confirmation/                  # Detection preview and verse correction screen
│   ├── passage_selection/             # 114 Surah manual search and verse range picker
│   └── exploration/                   # Multi-section study guide, notes, and scoped Q&A
├── providers/
│   └── app_providers.dart             # Riverpod dependency injection & reactive state
├── services/
│   ├── gemini_service.dart            # Prompt engineering, JSON schemas, error formatting, demo mode
│   ├── image_service.dart             # Image compression, permanent local storage
│   └── settings_service.dart          # SharedPreferences persistence
└── shared/
    └── widgets/
        ├── arabic_text_view.dart      # RTL Arabic verse display
        └── profile_avatar.dart        # Distinct family member avatars
```

---

## 🧪 Testing Suite

Automated tests cover all critical business logic and UI components:
- **`quran_data_test.dart`**: Verification of all 114 Surahs, verse ranges, and boundary checks.
- **`passage_identification_test.dart`**: Valid JSON, markdown fences, malformed payloads, and string-to-int normalization.
- **`quran_explanation_test.dart`**: Multi-section response parsing, fallback text extraction.
- **`sqlite_repository_test.dart`**: In-memory SQLite testing of profile management, session filtering, reading dates lookup, bookmark toggling, and interval-merged verse coverage.
- **`gemini_service_test.dart`**: API configuration detection, mock demo fallbacks, scoped Q&A.
- **`widget_test.dart`**: Component-level widget testing for `ArabicTextView` and `ManualPassageScreen`.
