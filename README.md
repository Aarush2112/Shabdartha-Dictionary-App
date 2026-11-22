# Garuda Lexicon

> **The Modern Dictionary & AI Language Companion**  
> *A submission for the Garuda Prakashan × Rishihood Live Project — Dictionary App Track.*  
> *"Words are only the beginning."*

---

## 1. Product Vision & Overview

**Garuda Lexicon** is a thoughtfully designed, editorial-grade language discovery and dictionary mobile application. Rather than offering a generic dictionary template or standard chat wrapper, Garuda Lexicon bridges classical philology, authentic Indian linguistic heritage, contemporary English literature, and an intelligent AI language mentor called **Ask Garuda**.

### Core Pillars
1. **Authoritative Lexicon:** Seamless lookups supporting both local curated entries and real-time live queries via the Free Dictionary API and Datamuse suggestions.
2. **Authentic Indian Linguistic Heritage:** Rigorous academic exploration of Indian language connections. Crucially, the app **strictly distinguishes** between:
   - **Direct Loanwords:** Historical borrowings such as *Juggernaut* (from Odia/Sanskrit *Jagannātha*), *Avatar* (*avatāra*), *Guru*, *Bungalow*, *Jungle*, *Cheetah*, and *Loot*.
   - **Proto-Indo-European (PIE) Cognates:** Genetic cousins sharing deep prehistoric ancestry without borrowing, such as English *Mother* & Sanskrit *Mātṛ*, English *Brother* & Sanskrit *Bhrātṛ*, and English *Name* & Sanskrit *Nāma*.
   - **Conceptual Parallels:** Philosophical and aesthetic equivalences (e.g. *Petrichor* and *Mitti Attar*, *Equanimity* and *Samatvam* in the Bhagavad Gita).
3. **Deterministic Word of the Day:** A calendar-stable featured word that does not randomly re-roll upon reopening the app.
4. **Thematic Word Explorer:** Curated collections for *Complex & Subtle Emotions*, *Words for Writing & Rhetoric*, *Words of Indian Origin*, *PIE Cognates*, and *Commonly Confused Words*.
5. **Personal Vocabulary Notebook:** Full bookmarking with local offline persistence, search filtering, and date tracking.
6. **"Ask Garuda" — AI Language Companion:** A dedicated linguistic assistant that helps users understand word nuances, contrast near-synonyms, explore etymology, and polish sentences without generic AI clichés.

---

## 2. Visual Identity & Editorial Design System

- **Warm Parchment Surface:** `#FAF7F2` evokes fine paper and classical book design.
- **Deep Ink Typography:** `#1A1815` provides high contrast, literary readability.
- **Muted Terracotta Accent:** `#B84A29` highlights interactions with warm, Indian-inspired elegance.
- **Sage Green State:** `#2E6347` denotes verified linguistic relations and successful actions.
- **Typography:** Google Fonts `Cormorant Garamond` (classic serif) for hero words and editorial headings, paired with `Plus Jakarta Sans` for clean, modern legibility.

---

## 3. Architecture & Directory Structure

```
lib/
├── main.dart                      # App entry point & storage initialization
├── app.dart                       # Main navigation shell with IndexedStack
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Parchment, deep ink, terracotta, sage green
│   │   ├── app_typography.dart    # Cormorant Garamond & Plus Jakarta Sans
│   │   └── app_theme.dart         # Material 3 light theme definition
│   └── constants/
│
├── data/
│   ├── curated_words.dart         # Academic dataset with verified etymologies
│   └── curated_collections.dart   # Thematic vocabulary collections
│
├── models/
│   ├── word_model.dart            # WordEntry, IndianLanguageConnection, WordMeaning
│   ├── chat_message.dart          # ChatMessage model with quick action chips
│   └── collection_model.dart      # Curated collection data model
│
├── services/
│   ├── dictionary_service.dart    # Hybrid lookup (Curated + Free Dictionary API + Datamuse)
│   ├── ai_service.dart            # Pluggable AI: GoogleGeminiAiService + GarudaDemoAiService
│   ├── storage_service.dart       # SharedPreferences persistence (Bookmarks, History, Keys)
│   └── audio_service.dart         # Audio pronunciation playback
│
├── features/
│   ├── home/                      # Masthead, Word of the Day, search trigger, collections
│   ├── search/                    # Debounced instant search, suggestions, history
│   ├── word_details/              # Reading-first detail screen, audio, Indian roots card
│   ├── saved_words/               # Vocabulary library, search filter, remove/undo
│   ├── word_explorer/             # Thematic collections & word list view
│   └── ai_companion/              # "Ask Garuda" chat interface, markdown, settings dialog
│
└── widgets/
    ├── app_bottom_navigation.dart # Minimalist 4-tab bottom navigation
    ├── empty_state_view.dart      # Reusable elegant empty state
    ├── error_state_view.dart      # Reusable error state with retry
    └── loading_view.dart          # Subtle loading indicator
```

---

## 4. AI Companion — Ask Garuda

### Architectural Abstraction
The AI Companion is implemented behind an abstract contract (`AiService`), ensuring zero vendor lock-in.

- **Production Live Mode (`GoogleGeminiAiService`):**
  Connects directly to Google Gemini API (`gemini-1.5-flash`, `gemini-1.5-pro`, or `gemini-2.0-flash`). Injects a specialized system instruction that eliminates generic filler phrases ("Certainly!", "Great question!") and directs the model to act as a literary and etymological mentor.
- **Built-in Linguistic Engine (`GarudaDemoAiService`):**
  When no API key is provided, the app remains fully functional in **Demo Mode**. It answers queries on word comparisons (e.g. *melancholy vs. sadness vs. grief*), sentence refinement, mnemonics, and Indian roots, transparently displaying a `Demo Mode` badge so reviewers know exactly what is executing.

### Key Capabilities
1. **Explain a Word:** Break down nuance, historical context, and literary register.
2. **Contextual Usage:** Contrast speech registers across casual, formal, and creative prose.
3. **Compare Nuances:** Clarify subtle boundaries between near-synonyms.
4. **Sentence Polish:** Refine cadence and vocabulary while preserving the writer's authentic voice.
5. **Indian Language Connections:** Explore verified Sanskrit/Hindi roots and PIE cognates.
6. **Vocabulary Mnemonics:** Memory anchors and etymological hooks for difficult words.

---

## 5. Getting Started & Setup

### Prerequisites
- Flutter SDK 3.38+ (Dart 3.10+)
- Google Chrome (for web execution)
- Android Studio / Xcode (optional, for native builds)

### Installation
```bash
# Clone or navigate to the project directory
cd dictapp

# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze

# Execute test suite
flutter test
```

### Running on Chrome (Web)
```bash
# Run in Google Chrome
flutter run -d chrome
```

---

## 6. AI Provider Configuration

1. Open the app and navigate to the **Ask Garuda** tab.
2. Tap the **Tune / Settings** icon (`tune_rounded`) in the upper-right corner.
3. Enter your **Google Gemini API Key** and select your preferred model (`gemini-1.5-flash` recommended).
4. Tap **Save Configuration**.
5. *Note: API keys are stored solely in local `SharedPreferences` and are never committed to version control.*

---

## 7. Data Sources & Attribution

- **Curated Indic & Literary Lexicon:** Authored for Garuda Lexicon with verified etymological notes distinguishing PIE cognates from loanwords.
- **Free Dictionary API:** `https://api.dictionaryapi.dev` (Standard definitions, phonetics, and audio endpoints).
- **Datamuse API:** `https://api.datamuse.com` (Prefix search and suggestions).

---

## 8. Verification & Test Results

- **Static Analysis:** `flutter analyze` completed with **0 errors, 0 warnings, 0 lints**.
- **Automated Tests:** 16 unit and widget tests covering:
  - `word_model_test.dart`: Serialization, Free Dictionary API parsing, relation type classifications.
  - `dictionary_service_test.dart`: Deterministic Word of the Day, curated lookups, suggestion matching.
  - `storage_service_test.dart`: Bookmark persistence, recent search recency and capping, chat history persistence.
  - `ai_service_test.dart`: Persona adherence, comparative analysis, Indian roots validation.
  - `widget_test.dart`: Main application boot, navigation bar, masthead, Word of the Day card rendering.
