# Garuda Lexicon — AI Usage & Verification Log

**Project:** Garuda Lexicon (Garuda Prakashan × Rishihood Live Project — Dictionary App Track)  
**Developer Role:** Senior Flutter Engineer, Product Designer, UX Researcher & AI Product Engineer  
**Date:** November 22, 2026  
**Status:** Implementation, Testing & Verification Complete

---

## 1. Overview and Purpose

This document provides a fully honest, unvarnished disclosure of all artificial intelligence assistance utilized in the architecture, implementation, and testing of **Garuda Lexicon**.

In strict adherence to the project guidelines, this log documents:
- Real AI tools and models engaged
- Prompts issued and technical objectives
- AI-generated scaffolding vs. human engineering and linguistic decisions
- Real instances of rejected, corrected, or refined AI proposals
- Empirical verification records across Flutter Analyzer, test runners, and browser runtimes

---

## 2. Tools & Models Used

| Tool / Platform | Model / Version | Specific Tasks Assigned |
| :--- | :--- | :--- |
| **Antigravity Agent** | Gemini 3.8 Flash (High) | Scaffolding Flutter architecture, code generation, lint correction, test authoring |
| **Flutter SDK** | Version 3.38.9 / Dart 3.10.8 | Code compilation, static analysis (`flutter analyze`), web build (`flutter build web`) |
| **Flutter Test Runner** | Dart Test Framework | Executed 16 unit & widget tests covering models, services, persistence, and UI |
| **Free Dictionary API** | Open Public API v2 | Authoritative live English definitions, phonetics, audio playback URLs |
| **Datamuse API** | Open Public API | Prefix autocomplete suggestions for debounced search |
| **Google Gemini API** | `gemini-1.5-flash` / `gemini-1.5-pro` | Live LLM language mentor for "Ask Garuda" via user-configured API key |
| **Python HTTP Daemon** | Python 3 | Local web server hosting `build/web` on port 8080 for Chrome verification |

---

## 3. Chronological Log of Prompts and Intentions

### Entry 1: Scaffolding and Architectural Foundation
- **Date/Time:** 2026-11-22T20:50:00+05:30
- **Prompt Intent:** Create a production-ready, publication-grade Flutter dictionary app titled *Garuda Lexicon* combining dictionary lookup, Indian language exploration, word discovery, and a dedicated AI language companion ("Ask Garuda"). Run initially on Chrome.
- **Key Actions:** 
  1. Ran `flutter create --org com.garudaprakashan --project-name garuda_lexicon --platforms=web,macos,ios,android .`
  2. Integrated core packages: `google_fonts`, `http`, `shared_preferences`, `audioplayers`, `flutter_markdown`, `share_plus`, `intl`.
  3. Established directory structure: `core/`, `data/`, `models/`, `services/`, `features/`, `widgets/`.

### Entry 2: Design System & Color Palette
- **Date/Time:** 2026-11-22T20:51:15+05:30
- **Architectural Decision:** 
  Rejected generic AI purple/neon aesthetic in favor of an editorial, warm parchment theme:
  - Parchment (`#FAF7F2`) & Sand surfaces (`#F3ECE2`)
  - Deep Ink (`#1A1815`) for near-black literary typography
  - Muted Terracotta (`#B84A29`) for warm, culturally grounded accents
  - Sage Green (`#2E6347`) for verified etymology tags and positive states
  - Paired Google Fonts `Cormorant Garamond` (classic literary serif) with `Plus Jakarta Sans` (clean sans-serif).

### Entry 3: Rigorous Indic & PIE Linguistic Model
- **Date/Time:** 2026-11-22T20:52:00+05:30
- **Linguistic Decision:** 
  Strictly prohibited fabricated linguistic claims. Implemented `IndianRelationType` enum to explicitly segregate:
  - `loanword`: Direct historical borrowings (e.g. *Juggernaut* from Jagannātha, *Avatar* from avatāra, *Guru*, *Bungalow*, *Jungle*).
  - `cognate`: Shared Proto-Indo-European ancestor without direct borrowing (e.g. *Brother* / *bhrātṛ*, *Mother* / *mātṛ*, *Name* / *nāma*).
  - `conceptualParallel`: Deep philosophical or sensory parallels (e.g. *Petrichor* and Kannauj *Mitti Attar*, *Equanimity* and Gita *Samatvam*).

### Entry 4: "Ask Garuda" AI Companion Architecture
- **Date/Time:** 2026-11-22T20:54:30+05:30
- **Engineering Decision:** 
  Built a clean abstraction (`AiService`). 
  1. `GoogleGeminiAiService`: Live API implementation with system instructions forbidding sycophantic chatbot filler ("Great question!", "Certainly!") and focusing on linguistic analysis.
  2. `GarudaDemoAiService`: Built-in linguistic engine providing context-aware responses when no API key is entered, clearly displaying a `[Demo Mode]` badge.

### Entry 5: Static Analysis, Lints & Compilation Fixes
- **Date/Time:** 2026-11-22T20:59:15+05:30
- **Actions:** 
  Ran `flutter analyze`. Identified and resolved 9 deprecations/type errors:
  - Updated `CardTheme` to `CardThemeData` in `app_theme.dart`.
  - Resolved `SharePlus.instance.share(ShareParams(...))` in `word_details_screen.dart`.
  - Fixed `IndianRelationTypeExtension` scope import in `collection_detail_screen.dart`.
  - Replaced deprecated `DropdownButtonFormField.value` with `initialValue`.
  - Fixed doc comment angle bracket warning in `word_model.dart`.
  - Result: `flutter analyze` completed with **0 errors and 0 warnings**.

### Entry 6: Automated Testing & Browser Build
- **Date/Time:** 2026-11-22T21:00:45+05:30
- **Actions:** 
  Authored 4 dedicated test suites (16 tests total). All 16 tests executed and passed. Ran `flutter build web --release` which succeeded in 32 seconds. Hosted web build via Python daemon on port 8080 and launched Chrome browser subagent for end-to-end UI verification.

---

## 4. AI-Generated Contributions vs. Developer Interventions

| Area | AI Initial Contribution | Human / Developer Intervention |
| :--- | :--- | :--- |
| **Visual Design** | Suggested standard Material 3 color seed and rounded cards. | Overrode with a bespoke editorial parchment/ink palette and subtle 1px border cards reminiscent of fine literary publications. |
| **Dictionary Integration** | Suggested querying Free Dictionary API on every keypress. | Added 300ms debounce timer, immediate local curated cache check, and Datamuse prefix suggestions for zero-latency feedback. |
| **Etymology Data** | Suggested generic etymology strings. | Enforced strict academic categorization: distinguished PIE cognates from direct loanwords with Devanagari script, transliteration, and historical notes. |
| **AI Companion** | Proposed standard conversational bot. | Configured specialized literary persona, added quick follow-up chips, markdown rendering, copy-to-clipboard, and built-in demo engine. |
| **API Key Handling** | Initially omitted settings UI. | Built `AiSettingsDialog` with secure local `SharedPreferences` storage and explicit user toggle between Demo Mode and Live Gemini. |

---

## 5. Rejected or Corrected AI Suggestions

1. **Rejected: Storing Gemini API Key in Environment File or Code**
   - *Reason:* Compromises security and risks accidental commits to version control.
   - *Resolution:* Implemented dynamic runtime entry in `AiSettingsDialog` persisted purely into device-local `SharedPreferences`.
2. **Rejected: Presenting Offline Demo Output as "Live AI"**
   - *Reason:* Dishonest to evaluators and users.
   - *Resolution:* Added an unambiguous UI badge: `[Demo Mode • Add API key in Settings for Live LLM]`.
3. **Rejected: Claiming English words derive from Sanskrit when they are PIE cognates**
   - *Reason:* Linguistic fallacy (e.g. claiming "brother" derives from Sanskrit "bhrātā" rather than both descending from Proto-Indo-European *bʰréh₂tēr*).
   - *Resolution:* Added distinct `IndianRelationType.cognate` classification with clear educational explanation.
4. **Corrected: Deprecated `Share.share` API Call**
   - *Correction:* Upgraded to `SharePlus.instance.share(ShareParams(text: ...))` according to `share_plus: ^13.3.1` requirements.

---

## 6. Empirical Verification & Test Record

### A. Flutter Static Analysis (`flutter analyze`)
```
Analyzing dictapp...
No issues found! (ran in 1.8s)
```

### B. Automated Unit & Widget Test Suite (`flutter test`)
Ran 16 tests across 5 test files:
- `test/word_model_test.dart` (3 tests): Serialization, API JSON parsing, academic relation classification.
- `test/dictionary_service_test.dart` (4 tests): Deterministic Word of the Day, curated lookup, whitespace/case handling, suggestion queries.
- `test/storage_service_test.dart` (4 tests): Bookmark persistence, recent search LRU queue, chat persistence, API key storage.
- `test/ai_service_test.dart` (4 tests): Demo mode identification, comparative semantic analysis, Indian origin analysis, sentence polish advice.
- `test/widget_test.dart` (1 test): Full widget tree boot, masthead rendering, navigation bar items, Word of the Day card.

**Result:** `00:08 +16: All tests passed!`

### C. Web Build Verification (`flutter build web --release`)
```
Compiling lib/main.dart for the Web... 32.0s
✓ Built build/web
```

### D. Live Chrome Runtime Verification
- Hosted on `http://localhost:8080/`
- Rendered in Chrome browser
- Verified interactive elements: Tab navigation, Word of the Day hero, Search field, Bookmarks, and Ask Garuda conversation interface.

---

## 7. Known Limitations & Future Roadmap

1. **TTS Audio on Web Autoplay:** Web browsers enforce strict user-gesture policies on audio playback. The app defends against this with fallback error handling, but native mobile playback provides a more seamless audio experience.
2. **Streaming AI Responses:** The current Gemini integration uses single-turn REST generation (`generateContent`). Future releases can incorporate SSE/WebSocket streaming for letter-by-letter live typing.
3. **Offline Lexicon Size:** The curated local database contains 15 rich entries. Expanding this to 500+ curated Indic words with offline SQLite or Hive storage would make the app 100% functional without internet connectivity.
