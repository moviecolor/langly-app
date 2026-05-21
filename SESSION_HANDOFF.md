# Langly — Session Handoff Document

> **Generated:** 2026-05-21
> **Purpose:** Complete record of this development session for the next session/developer to pick up immediately.
> **Previous Handoff:** SESSION_HANDOFF.md (2026-05-19)

---

## 1. PROJECT OVERVIEW

### What is Langly?
Langly is an **iOS language learning app** focused on teaching **English → Brazilian Portuguese (PT-BR)**. It is NOT a task management app.

### Tech Stack
| Layer | Technology |
|---|---|
| **UI Framework** | SwiftUI |
| **Persistence** | SwiftData |
| **Translation** | Apple native Translation framework (with MockTranslator fallback for simulator) |
| **In-App Purchases** | StoreKit 2 |
| **Text-to-Speech** | AVSpeechSynthesizer (via AudioEngine wrapper) |
| **Build System** | Xcode — direct project (Langly.xcodeproj) |

### Current Working Directory
`/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT/`

### Environment
| Item | Value |
|---|---|
| **Xcode** | `/Applications/Xcode.app` (full Xcode, NOT CommandLineTools) |
| **Xcode Build Path** | `/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild` |
| **Bundle ID** | `com.langly.app` |
| **Available Simulators** | iPhone 16, iPhone 16 Plus, iPhone 16 Pro, iPhone 16 Pro Max, iPhone 16e, iPhone 17, iPhone Air (OS 18.3.1 and 26.3.1) |

### Build Commands
```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# Build on iPhone 16 simulator
xcodebuild -project Langly.xcodeproj -scheme Langly \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1' build

# Launch on simulator
xcrun simctl launch booted com.langly.app

# Start a specific simulator
xcrun simctl boot "iPhone 16"
```

---

## 2. WHAT WAS DONE TODAY (May 21, 2026)

### Commit `58fcaba` — Fixed Three Broken Features

All three previously broken features now compile and build successfully. **YOU MUST TEST THESE AT RUNTIME** — there are no automated tests.

---

### FIX 1: Module Navigation Buttons

**File:** `Sources/Views/MainMenuView.swift`

**What was broken:**
- Module icons for Common Sentences, Pronunciation, and Q&A were **not working** — tapping them either did nothing or showed "Coming Soon" stub views instead of the intended flow.
- Locked modules showed plain text stubs instead of their branded loading screens.
- The old implementation used separate `NavigationStack`s with `.environment(\.moduleDismissal)` for each module view, which was fragile and unreliable for dismissal.

**What was implemented:**
- Replaced the per-module `NavigationStack` approach with a **single `moduleContent` @ViewBuilder** that switches between:
  - Active module views (CommonSentencesView, PronunciationView, QAView) when IAP-gated modules are unlocked
  - Stub `ZStack` placeholders for locked modules (still just text for now — full modules not built)
- Added `showModuleTab(_ tab: AppTab)` method that:
  1. Sets `showLoadingOverlay = true` and `loadingTab = tab`
  2. Checks `IAPManager` unlock status
  3. If **unlocked**: shows loading overlay for **0.8s** → switches `selectedTab` → hides overlay → displays module
  4. If **locked**: shows loading overlay for **1.5s** → hides overlay → stays on current tab (no navigation)
- Added full-screen loading overlay ZStack on `MainMenuView` body that renders `Image(tab.loadingImageName)` with a ProgressView tint.
- Added `loadingImageName` property to `AppTab` enum to map each tab to its branded loading asset.

**Current flow (verify at runtime):**
```
Tap "Common Sentences" (locked) →
  1. Branded CS loading image fades in (full screen) + progress indicator →
  2. Stays 1.5 seconds →
  3. Fades out →
  4. Returns to previous tab (Vocabulary)
     NOTE: No "Coming Soon" text should be visible
```

---

### FIX 2: Manual Translation Toggle in Vocabulary Module

**File:** `Sources/Views/Loading/VocabularyLoading.swift`

**What was broken:**
- `VocabularyLoading` had no `isLocked` parameter, so it always attempted to navigate to `VocabularyView` after the loading animation.
- The `#Preview` was calling `VocabularyLoading()` without parameters, causing a compile error.
- Vocabulary module was not gating navigation based on lock state.

**What was implemented:**
- Added `var isLocked: Bool` parameter to `VocabularyLoading`
- Added `guard !isLocked else { return }` in the `.task` block to skip navigation when locked
- Fixed `#Preview` to pass `isLocked: false`

**File:** `Sources/Views/Modules/Vocabulary/WordInputView.swift`

**Manual translation already existed in previous code.** The relevant state variable is:
```swift
@State private var useManualTranslation: Bool = false
```

Toggle behavior:
- **Toggle OFF (Auto Translate):** Shows native word field + "Translate" button + read-only result view + "Save Word"
- **Toggle ON (Manual):** Shows native word field + editable translation field + "Save Word"
- The `useManualTranslation` state controls visibility of `autoTranslateSection` vs `manualTranslationField` subviews

---

### FIX 3: Word Save to SwiftData

**File:** `Sources/Views/Modules/Vocabulary/WordInputView.swift`

**What was broken:**
- Words were being created and inserted into `modelContext` but never **persisted to disk** because `.save()` was not called on the context.
- No error handling existed for save failures.

**What was implemented:**
- Added explicit `try modelContext.save()` inside `saveWord()`
- Added error catch block that:
  - Prints error to console
  - Sets `showSaveError = true` to trigger an alert
- Added `showSaveError` state variable and `.alert("Save Failed", ...)` modifier
- Haptic feedback (`UINotificationFeedbackGenerator`) plays on success
- "Saved!" toast banner appears for 1.5s on success

**Save flow:**
```
User types native word + translation →
User selects block chip →
User taps "Save Word" →
  1. Validates: block selected, words non-empty, block not full (15 max) →
  2. Creates VocabularyWord and inserts into modelContext →
  3. Appends word to block.vocabularyWords →
  4. Calls modelContext.save() →
  5. Haptic success + "Saved!" toast →
  6. Clears input fields →
  7. @Query refreshes word list visually
```

---

## 3. WHAT STILL NEEDS WORK

### PRIORITY 1: Test Everything at Runtime
**No automated tests exist.** Every fix listed above MUST be verified by:
1. Building the app
2. Running on simulator
3. Testing each flow manually

### PRIORITY 2: Locked Module Loading Screens Need Validation
The loading overlay for locked modules works as a screen overlay, but:
- The user should **not** see any stub "Coming Soon" text behind the overlay
- Verify the dismissed state returns cleanly to the main menu
- The `ZStack` in `moduleContent` for locked modules still shows `Text("Common Sentences")` etc. — confirm the loading overlay fully covers this before hiding

### PRIORITY 3: Vocabulary Module Loading Screen
`VocabularyLoading` always shows because Vocabulary is always unlocked. Verify:
- Loading image appears for 1.5s
- Then navigates to `VocabularyView`
- Then shows the word bank UI

### PRIORITY 4: Common Sentences / Pronunciation / Q&A Modules
These are still **stubs** (just `Text("...")`). The IAP gate logic is in place, but the actual module views are empty:
- `CommonSentencesView` — stub only
- `PronunciationView` — stub only  
- `QAView` — stub only

These need full implementation if the paid features are to be delivered.

### PRIORITY 5: Real Device Translation Testing
- **Simulator** uses `MockTranslator` (dictionary-based). It will NOT use Apple's native Translation framework.
- On a **real iOS device**, Apple Translation should work natively for EN→PT-BR.
- `TranslatorManager` handles the fallback switch automatically — no code changes needed, but testing on device is critical.

---

## 4. CURRENT FILE STATE (As of May 21)

### Source Files — All Committed in `58fcaba`

| File | Status | Notes |
|---|---|---|
| `Sources/App.swift` | ✅ Good | Entry point, SwiftData container |
| `Sources/Views/ContentView.swift` | ✅ Good | Root view, launch screen |
| `Sources/Views/MainMenuView.swift` | ✅ **FIXED** | Module navigation with loading overlays |
| `Sources/Views/Loading/VocabularyLoading.swift` | ✅ **FIXED** | `isLocked` parameter + navigation gate |
| `Sources/Views/Loading/CommonSentencesLoading.swift` | ✅ Good | Stub loading screen |
| `Sources/Views/Loading/PronunciationLoading.swift` | ✅ Good | Stub loading screen |
| `Sources/Views/Loading/QALoading.swift` | ✅ Good | Stub loading screen |
| `Sources/Views/MainMenuView.swift` | ✅ **FIXED** | Complete module routing overhaul |
| `Sources/Views/Modules/Vocabulary/VocabularyView.swift` | ✅ Good | Word bank UI |
| `Sources/Views/Modules/Vocabulary/WordInputView.swift` | ✅ **FIXED** | Manual toggle + save persistence |
| `Sources/Views/Modules/Vocabulary/MatchMadnessGameView.swift` | ✅ Good | Word matching game |
| `Sources/Views/Modules/Vocabulary/AudioModeView.swift` | ✅ Good | TTS mode |
| `Sources/Views/Modules/CommonSentences/CommonSentencesView.swift` | ⚠️ Stub | Only shows IAP gate + stub text |
| `Sources/Views/Modules/Pronunciation/PronunciationView.swift` | ⚠️ Stub | Only shows IAP gate + stub text |
| `Sources/Views/Modules/QA/QAView.swift` | ⚠️ Stub | Only shows IAP gate + stub text |
| `Sources/Services/TranslatorManager.swift` | ✅ Good | Apple Translation + Mock fallback |
| `Sources/Services/MockTranslator.swift` | ✅ Good | 450+ word dictionary |
| `Sources/Services/IAPManager.swift` | ✅ Good | StoreKit 2 purchase gating |
| `Sources/Services/AudioEngine.swift` | ✅ Good | AVSpeechSynthesizer wrapper |
| `Sources/Services/IAPManager.swift` | ✅ Good | Purchase checks |
| `Sources/Models/WordBlock.swift` | ✅ Good | SwiftData model |
| `Sources/Models/VocabularyWord.swift` | ✅ Good | SwiftData model |
| `Sources/Extensions/Color+Hex.swift` | ✅ Good | Theme colors |

---

## 5. KEY STATE VARIABLES (For Debugging)

| View | Variable | Purpose |
|---|---|---|
| `MainMenuView` | `selectedTab: AppTab` | Currently shown module |
| `MainMenuView` | `showLoadingOverlay: Bool` | When true, shows branded loading screen |
| `MainMenuView` | `loadingTab: AppTab?` | Which tab's loading image to show |
| `VocabularyLoading` | `isLocked: Bool` | If true, show loading but DON'T navigate |
| `VocabularyLoading` | `isVisible: Bool` | Controls loading image opacity |
| `VocabularyLoading` | `shouldNavigate: Bool` | Triggers navigation destination |
| `WordInputView` | `useManualTranslation: Bool` | Toggle between auto-translate and manual mode |
| `WordInputView` | `nativeWordInput: String` | User-entered native word |
| `WordInputView` | `translatedWord: String` | Auto-filled or user-entered translation |
| `WordInputView` | `selectedBlockID: UUID?` | Target block for saving |
| `WordInputView` | `showSaveFeedback: Bool` | Show/hide "Saved!" toast |
| `WordInputView` | `showSaveError: Bool` | Show/hide "Save Failed" alert |
| `WordInputView` | `translateStatus: TranslationStatus` | idle / translating / success / failed |
| `IAPManager` | `isCommonSentencesUnlocked: Bool` | Purchase status for CS module |
| `IAPManager` | `isPronunciationUnlocked: Bool` | Purchase status for Pronunciation |
| `IAPManager` | `isQAUnlocked: Bool` | Purchase status for Q&A |

---

## 6. GIT STATUS

```
Branch: master
Latest commit: 58fcaba (HEAD)
Message: fix: module button navigation and manual word entry
Files changed: 3 (+167, -46 lines)
Status: ALL CLEAN — no uncommitted changes
```

---

## 7. NEXT SESSION — IMMEDIATE TASKS

### Task 1: Build and Run
```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
cd /Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT/
xcodebuild -project Langly.xcodeproj -scheme Langly -configuration Debug \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1' build
```

### Task 2: Manual Test Checklist
Run through these flows in the app:

1. **Tap "Common Sentences" icon** (locked):
   - [ ] Branded loading image appears for 1.5s
   - [ ] Then dismisses, returns to Vocabulary
   - [ ] No "Coming Soon" stub visible after dismiss

2. **Tap "Vocabulary" icon**:
   - [ ] Loading screen appears for 1.5s
   - [ ] Navigates to word bank view

3. **Add a word with Auto Translate**:
   - [ ] Type English word → tap "Translate" → translation appears → select block → "Save Word" → toast → word appears in list

4. **Add a word with Manual Translation**:
   - [ ] Toggle "Manual Translation" ON
   - [ ] See two text fields instead of translate button
   - [ ] Type both fields → select block → "Save Word" → toast → word appears

5. **Verify persistence**:
   - [ ] Add word, navigate away, return — word is still there
   - [ ] Close and reopen app — word is still there
   - [ ] Word count updates on block chip

6. **Test on real device** (if available):
   - [ ] Apple Translation framework works native (not MockTranslator)
   - [ ] TTS plays PT-BR voice

### Task 3: If Tests Pass — Next Development Steps

1. **Build Common Sentences module** — replace stub with working UI
2. **Build Pronunciation module** — replace stub with working UI
3. **Build Q&A module** — replace stub with working UI
4. **Integrate real IAP** — remove `IAPManager` defaults that simulate purchases
5. **Error handling audit** — verify edge cases for all user flows

---

## 8. CRITICAL NOTES

### Simulator Limitations
- **MockTranslator is used automatically** on simulator — Apple Translation models cannot be downloaded
- On real device, Apple Translation should work natively
- `TranslatorManager` handles fallback transparently

### Theme System
- Dark theme: `#1A1A2E` background
- Light mode: white background
- All colors in `Color+Hex.swift` as extensions on `Color`

### Module Navigation Architecture
- **Fixed top icon bar** (not `TabView`)
- Uses `@State selectedTab` + `ZStack` content switching
- Loading overlays managed via `showLoadingOverlay` + `loadingTab` state in `MainMenuView`
- All module views rendered inside `moduleContent` @ViewBuilder

### Xcode Path
- **Full Xcode:** `/Applications/Xcode.app` (NOT CommandLineTools)
- Build always uses: `/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild`
- If you get "xcodebuild requires Xcode" error, run:
  ```bash
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  ```

---

*End of Session Handoff. Date: 2026-05-21. Build confirmed green in commit `58fcaba`. Next session starts with manual testing.*
