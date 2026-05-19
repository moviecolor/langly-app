# Langly — Session Handoff Document

> **Generated:** 2026-05-19
> **Purpose:** Complete record of this development session for the next session/developer to pick up immediately where we left off.

---

## 1. PROJECT OVERVIEW

### What is Langly?
Langly is an **iOS language learning app** focused on teaching **English → Brazilian Portuguese (PT-BR)**. It is NOT a task management app — the original scaffold was completely replaced.

### Tech Stack
| Layer | Technology |
|---|---|
| **UI Framework** | SwiftUI |
| **Persistence** | SwiftData |
| **Translation** | Apple native Translation framework (with MockTranslator fallback for simulator) |
| **In-App Purchases** | StoreKit 2 |
| **Text-to-Speech** | AVSpeechSynthesizer (via AudioEngine wrapper) |
| **Build System** | XcodeGen + `project.yml` (NOT standard Xcode project files) |

### Environment
| Item | Value |
|---|---|
| **Xcode Version** | 26.3 |
| **Xcode Path** | `/Applications/Xcode.app` |
| **Project Path** | `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT/` |
| **Bundle ID** | `com.langly.app` |
| **Simulator** | iPhone 17 Pro Max |
| **Simulator UUID** | `BDAEA7EA-8A1F-432E-9BBF-90210F199DDC` |

### Build Commands
```bash
# Build
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project Langly.xcodeproj -scheme Langly \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build

# Launch on simulator
xcrun simctl launch BDAEA7EA-8A1F-432E-9BBF-90210F199DDC com.langly.app
```

---

## 2. COMPLETED WORK (Chronological Order)

### 2.1 Translation Framework Migration
- **Replaced Google MLKit** with Apple native Translation framework due to iOS 26 SDK `SwiftUICore` linking conflicts with MLKit frameworks.
- Created **`MockTranslator.swift`** with ~450 EN→PT word pairs across 15+ categories for simulator testing (simulator cannot download Apple Translation models).
- Created **`TranslatorManager.swift`** that attempts Apple Translation first, falls back to MockTranslator automatically.

### 2.2 Asset Integration
- Integrated 4 custom loading page images into `Assets.xcassets`:
  - `V_001.png` — Vocabulary loading screen
  - `CS_001.png` — Common Sentences loading screen
  - `P_001.png` — Pronunciation loading screen
  - `Q_001_.png` — Q&A loading screen

### 2.3 Navigation & Layout Overhaul
- **Replaced TabView** with a fixed top module icon bar (SF Symbols rendered on white circles).
- **Removed GeometryReader anti-pattern** from `MainMenuView`.
- **Fixed full-screen layout:**
  - Added `UILaunchScreen` key to `Info.plist` for proper launch screen behavior.
  - Added `.ignoresSafeArea()` to `ContentView`.
- **Fixed bottom white bar** by wrapping `ScrollView` in a `GeometryReader` with `.scrollContentBackground(.hidden)`.
- Added `toolbarBackground` color to match dark theme.

### 2.4 Theme System
- Created **adaptive light/dark theme** system:
  - Light mode: white background
  - Dark mode: `#1A1A2E` background with bright green accent text
- Added custom **Color extensions** in `Color+Hex.swift`:
  - `appBackground`, `appSurface`, `appText`, `appAccent`, `appSecondaryText`, `appCardBackground`, `appInputBorder`, `appSuccess`, `appError`, `appWarning`

### 2.5 Vocabulary Module (Fully Built)
- **`VocabularyView.swift`** — Word bank with block management, mode switching (Word Bank / Match Madness / Audio Mode).
- **`WordInputView.swift`** — Sheet for adding new words with auto-translation (has known bugs — see Section 3).
- **`MatchMadnessGameView.swift`** — Timed word-matching game (native ↔ translated).
- **`AudioModeView.swift`** — TTS audio playback mode for vocabulary words.

### 2.6 In-App Purchases
- Created **`IAPManager.swift`** using StoreKit 2 for module purchase gating.
- Modules (Common Sentences, Pronunciation, Q&A) are locked behind IAP.

### 2.7 Stub Module Views
- Created "Coming Soon" stub views for:
  - `CommonSentencesView.swift` — with IAP gate check
  - `PronunciationView.swift` — with IAP gate check
  - `QAView.swift` — with IAP gate check

### 2.8 Dictionary Expansion
- Expanded `MockTranslator` dictionary from ~150 to **450+ words** across 15+ categories.

### 2.9 Git
- All changes committed as **commit `6ea69b8`**.
- Note: The failed attempts (Section 3) are also included in this commit.

---

## 3. FAILED ATTEMPTS — WHERE NEXT SESSION MUST START

> **CRITICAL:** The last 3 attempts to implement the features below DID NOT WORK. The subagents made changes that compiled but did NOT produce the expected runtime behavior. The next session MUST read the current state of these files and implement these features correctly from scratch.

---

### FAILED ATTEMPT 1: Manual Translation Toggle in WordInputView

**File:** `Sources/Views/Modules/Vocabulary/WordInputView.swift`

**What was attempted:**
Added a toggle (`@State private var isManualMode = false`) to switch between "Auto Translate" and "Manual Translation" modes. In manual mode, the user should see TWO text fields: one for the native word (English) and one for the translated word (Portuguese) to type both manually.

**What went wrong:**
- The toggle was added to the UI, but the manual text field for the translated word either:
  - Did not appear when the toggle was switched ON
  - Did not bind correctly to the state variable
  - The save flow did not capture the manually typed translation
- Subagents kept making incremental edits (adding/removing `if isManualMode` blocks, adjusting bindings) that never resulted in a working implementation.

**What needs to work:**
```
Toggle OFF (Auto Translate mode):
  1. User types native word in single text field
  2. Taps "Translate" button
  3. Translation result appears in a read-only text view
  4. Taps "Save Word" → saves both values to the selected WordBlock

Toggle ON (Manual mode):
  1. User sees TWO text fields (native + translated)
  2. User types both values manually
  3. Taps "Save Word" → saves both values to the selected WordBlock
```

**Key implementation notes:**
- The `@State` variables for `nativeWord` and `translatedWord` must be properly bound to their respective `TextField` views.
- The save logic must read from the correct state variables depending on the mode.
- Consider using a `@FocusState` to manage keyboard dismissal between the two fields.

---

### FAILED ATTEMPT 2: Word Save Button Not Working

**File:** `Sources/Views/Modules/Vocabulary/WordInputView.swift`

**What was attempted:**
The save button should save words to SwiftData when tapped. Subagents added haptic feedback, toast notifications, and validation logic.

**What went wrong:**
- Words are **not actually persisting** to the `WordBlock`.
- Possible root causes:
  - `modelContext.insert()` and `block.vocabularyWords.append()` may not be wired correctly.
  - The `@Query` in `VocabularyView` may not be refreshing after the insert.
  - The save button's `.disabled()` condition may be preventing the action from firing.
  - The `WordBlock` reference passed into `WordInputView` may be a copy rather than a managed object reference.
- Haptic feedback and toast notifications were added but are meaningless if the data isn't persisting.

**What needs to work:**
```
1. User types native word + translation
2. User selects a block from the picker
3. User taps "Save Word"
4. Word appears IMMEDIATELY in the word list
5. Word persists in SwiftData (survives app restart)
6. The word count on the block card updates
```

**Key implementation notes:**
- Ensure the `modelContext` is being passed correctly through the view hierarchy.
- Verify that `VocabularyWord` is being created with `@Model` attributes correctly.
- After `modelContext.insert(word)` and `block.vocabularyWords.append(word)`, call `try? modelContext.save()`.
- The `@Query` in `VocabularyView` should automatically refresh, but if it doesn't, consider using `@Bindable` or triggering a manual refresh.
- Test by adding a word, navigating away, and returning — the word should still be there.

---

### FAILED ATTEMPT 3: Module Loading Image + IAP Gate

**Files:** `Sources/Views/MainMenuView.swift`, `Sources/Views/Loading/*.swift`

**What was attempted:**
When user taps Common Sentences / Pronunciation / Q&A icons:
1. Show the loading image for 1.5 seconds
2. Check IAP unlock status
3. If unlocked → navigate to the module view
4. If locked → dismiss back to main menu

**What went wrong:**
- The loading images are **NOT showing** when module buttons are pressed.
- The dismiss back to main menu for locked modules is **not working**.
- Subagents created a custom `ModuleDismissalAction` environment value, but it may not be wired correctly through the `NavigationStack` hierarchy in `MainMenuView`.
- The timing/sequencing of "show loading → wait 1.5s → check IAP → navigate or dismiss" is broken.

**What needs to work:**
```
1. User taps a module icon (Common Sentences / Pronunciation / Q&A)
2. Loading image appears IMMEDIATELY (full screen, centered)
3. After 1.5 seconds:
   a. If module is unlocked (IAP purchased) → show the module view
   b. If module is locked (not purchased) → smoothly dismiss back to main menu
4. User should NEVER see the "Coming Soon" view for unpurchased modules
```

**Key implementation notes:**
- The loading screen transition needs to be managed at the `MainMenuView` level, not inside each module view.
- Consider using a `@State` variable in `MainMenuView` to track which module is loading, and overlay the loading image conditionally.
- The IAP check should happen during the loading period, not after navigation.
- If locked, the loading image should fade out and return to the main menu — no navigation should occur.
- The `NavigationStack` in `MainMenuView` may be causing issues with programmatic dismissal. Consider using `NavigationLink(isActive:)` or a custom navigation coordinator.

---

## 4. CURRENT FILE STATE

### Source Files

| File | Purpose | Status |
|---|---|---|
| `Sources/App.swift` | `@main` entry point, sets up SwiftData container | Working |
| `Sources/Views/ContentView.swift` | Root view with launch screen + `TranslationSessionProvider` | Working |
| `Sources/Views/MainMenuView.swift` | Top icon bar + module switching via `NavigationStack`s | Working (needs IAP gate fix) |
| `Sources/Views/Loading/VocabularyLoading.swift` | Loading screen with `V_001.png` | Working |
| `Sources/Views/Loading/CommonSentencesLoading.swift` | Loading screen with `CS_001.png` | Working |
| `Sources/Views/Loading/PronunciationLoading.swift` | Loading screen with `P_001.png` | Working |
| `Sources/Views/Loading/QALoading.swift` | Loading screen with `Q_001_.png` | Working |
| `Sources/Views/Modules/Vocabulary/VocabularyView.swift` | Word bank, block management, mode switching | Working |
| `Sources/Views/Modules/Vocabulary/WordInputView.swift` | Add words sheet | **BROKEN** — manual translation toggle + save not working |
| `Sources/Views/Modules/Vocabulary/MatchMadnessGameView.swift` | Word matching game | Working |
| `Sources/Views/Modules/Vocabulary/AudioModeView.swift` | TTS audio playback mode | Working |
| `Sources/Views/Modules/CommonSentences/CommonSentencesView.swift` | Coming Soon stub with IAP | Stub only |
| `Sources/Views/Modules/Pronunciation/PronunciationView.swift` | Coming Soon stub with IAP | Stub only |
| `Sources/Views/Modules/QA/QAView.swift` | Coming Soon stub with IAP | Stub only |
| `Sources/Services/TranslatorManager.swift` | Apple Translation framework + mock fallback | Working |
| `Sources/Services/MockTranslator.swift` | 450+ word dictionary for simulator | Working |
| `Sources/Services/IAPManager.swift` | StoreKit 2 purchases | Working |
| `Sources/Services/AudioEngine.swift` | `AVSpeechSynthesizer` wrapper | Working |
| `Sources/Models/WordBlock.swift` | SwiftData model for word blocks | Working |
| `Sources/Models/VocabularyWord.swift` | SwiftData model for individual words | Working |
| `Sources/Extensions/Color+Hex.swift` | Color extensions + adaptive theme colors | Working |

### Key Directories
```
Sources/
├── App.swift
├── Models/
│   ├── WordBlock.swift
│   └── VocabularyWord.swift
├── Views/
│   ├── ContentView.swift
│   ├── MainMenuView.swift
│   ├── Loading/
│   │   ├── VocabularyLoading.swift
│   │   ├── CommonSentencesLoading.swift
│   │   ├── PronunciationLoading.swift
│   │   └── QALoading.swift
│   └── Modules/
│       ├── Vocabulary/
│       │   ├── VocabularyView.swift
│       │   ├── WordInputView.swift        ← BROKEN
│       │   ├── MatchMadnessGameView.swift
│       │   └── AudioModeView.swift
│       ├── CommonSentences/
│       │   └── CommonSentencesView.swift  ← Stub
│       ├── Pronunciation/
│       │   └── PronunciationView.swift    ← Stub
│       └── QA/
│           └── QAView.swift               ← Stub
├── Services/
│   ├── TranslatorManager.swift
│   ├── MockTranslator.swift
│   ├── IAPManager.swift
│   └── AudioEngine.swift
└── Extensions/
    └── Color+Hex.swift
```

---

## 5. NEXT SESSION PRIORITIES

### Priority 1 — FIX WordInputView (Manual Translation + Save)
- Fix the manual translation toggle so it correctly shows/hides the second text field.
- Fix the save button so words actually persist to SwiftData.
- Verify the word count updates on the block card after saving.
- Test the full flow: type → translate (auto or manual) → save → appears in list → survives app restart.

### Priority 2 — FIX Loading Screens + IAP Gate
- Ensure loading images appear immediately when module icons are tapped.
- Ensure the IAP gate correctly blocks navigation for unpurchased modules.
- Ensure locked modules dismiss smoothly back to the main menu.
- User should NEVER see "Coming Soon" for unpurchased modules.

### Priority 3 — Test on Real Device
- Simulator uses `MockTranslator` (cannot download Apple Translation models).
- Test on a real iOS device to validate the Apple Translation framework integration.
- Verify TTS (AVSpeechSynthesizer) works with PT-BR voice on device.

### Priority 4 — Complete Common Sentences Module
- Currently a "Coming Soon" stub.
- Needs: sentence list, audio playback, practice mode, IAP-gated.

### Priority 5 — Complete Pronunciation Module
- Currently a "Coming Soon" stub.
- Needs: pronunciation exercises, audio recording/playback comparison, IAP-gated.

### Priority 6 — Complete Q&A Module
- Currently a "Coming Soon" stub.
- Needs: question/answer practice, conversation simulation, IAP-gated.

---

## 6. IMPORTANT NOTES

### Architecture
- The project was **originally scaffolded as a task management app** and was **completely replaced** with the language learning app. All old task management files were deleted.
- The build system uses **`project.yml` + XcodeGen**, not standard Xcode project files. After modifying `project.yml`, run `xcodegen generate` before building.

### Translation Framework
- **Simulator cannot download Apple Translation models.** `MockTranslator` is used automatically as a fallback.
- On a real device, the Apple Translation framework should work natively for EN→PT-BR.
- `TranslatorManager` handles the fallback logic transparently.

### Theme
- **Dark theme** (`#1A1A2E`) is the default background.
- **Light mode** uses white background with adaptive text colors.
- All colors are defined in `Color+Hex.swift` as extensions on `Color`.

### Module Icons
- Module icons are **SF Symbols rendered on white circles** at the top of the screen.
- They are NOT a `TabView` — they are a custom `HStack` with button actions.

### Git
- All completed work is in commit **`6ea69b8`**.
- The failed attempts (Section 3) are also included in this commit.
- The next session should work on a new branch or commit incrementally.

### Simulator
- **Device:** iPhone 17 Pro Max
- **UUID:** `BDAEA7EA-8A1F-432E-9BBF-90210F199DDC`
- **Bundle ID:** `com.langly.app`

---

## 7. QUICK REFERENCE

### Build & Run
```bash
cd /Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT/
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# Generate project from project.yml (if modified)
xcodegen generate

# Build
xcodebuild -project Langly.xcodeproj -scheme Langly \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build

# Launch
xcrun simctl launch BDAEA7EA-8A1F-432E-9BBF-90210F199DDC com.langly.app
```

### Key State Variables to Look For
| View | State Variable | Purpose |
|---|---|---|
| `WordInputView` | `nativeWord: String` | Native word input |
| `WordInputView` | `translatedWord: String` | Translated word (auto or manual) |
| `WordInputView` | `isManualMode: Bool` | Toggle between auto/manual translation |
| `WordInputView` | `selectedBlock: WordBlock?` | Target block for saving |
| `MainMenuView` | `selectedModule: Module?` | Currently active module |
| `IAPManager` | `isModuleUnlocked(moduleId: String)` | Check purchase status |

### SwiftData Models
- **`WordBlock`** — Container for vocabulary words (has `name`, `color`, `vocabularyWords` relationship).
- **`VocabularyWord`** — Individual word entry (has `nativeWord`, `translatedWord`, `wordBlock` relationship).

---

*End of Session Handoff. Next session: start with Priority 1 (WordInputView fixes).*
