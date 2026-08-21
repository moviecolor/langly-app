# 🏨 LANGLY — iOS Architecture & Business Strategy

## 1. BUSINESS MODEL

**Free to download with 7-day free trial. Subscription required to use the app.**
All features unlock immediately upon subscription — no partial access, no tiered gating. The user subscribes, they get everything: Match Madness game, Audio Mode loops, Common Sentences, Pronunciation, and Q&A. Period.

### Pricing Strategy:
| Product | Price | Notes |
|-----|-----|------|
| **Langly (App Download)** | **Free** | 7-day free trial, then subscription required |
| **Langly Premium** | **$8.99/month** (USA) / **R$ 26,90/month** (Brazil) | Unlocks everything — all modules, all modes |
| **Free Trial** | **7 days free** | Full access, no restrictions, then auto-renews |

**Revenue Model:** Free trial → auto-renewable subscription via StoreKit 2.
- 7-day trial lets users experience the full app before committing
- All features available from day one — no bait-and-switch
- Single subscription = simple, honest, no confusion
- Short trial = less revenue lost to forgetters/cancellers
- Auto-renewal after trial = predictable recurring revenue

**Special cases:** 3-month trial available for negotiated partnerships (not public-facing).

**Revenue Model:** Recurring monthly subscription via StoreKit 2 auto-renewable.
- Free entry removes download friction — users experience value first
- Single subscription simplifies purchasing (no per-module decisions)
- Auto-renewable = predictable recurring revenue
- 3-month free trial builds habit before payment kicks in
- Cross-market pricing: USA $8.99, Brazil R$ 26,90

## 2. TECH STACK

| Layer | Technology |
|-----|-----|
| **UI Framework** | SwiftUI (iOS 16+) |
| **Data Persistence** | SwiftData (SQLite-backed) |
| **Translation** | Google ML Kit `GoogleMLKit/Translate` (on-device, offline) |
| **Audio Playback** | Apple `AVSpeechSynthesizer` (built-in TTS) |
| **Speech Recognition** | Apple `SFSpeechRecognizer` (online + offline fallback) |
| **Purchasing** | StoreKit 2 (`SKProduct`, `SKPaymentQueue`, receipt validation) |
| **Cross-Promo** | StoreKit 2 (`SKOverlay`) |
| **Packaging** | Swift Package Manager + CocoaPods (ML Kit) |

## 3. ARCHITECTURE OVERVIEW

```
┌──────────┬───┬───┬─────────┐
│            Langly App           │
├─────┬─────┬───┬───┬───┬───┬───┤
│  LaunchScreen (Welcome to Langly)│
│          ↓                        │
│  Main Menu                        │
│          ↓                        │
│  Module Router (Feature Flags)    │
│  ┌─ Vocabulary ─┐                │
│  ├── Common     │  StoreKit 2    │
│  ├── Pronunc.   │  IAP Gate Logic│
│  └── Q&A        │  + Cross-Promo│
├─────┬─────┬───┬───┬───┬───┬───┤
│  TranslatorManager (ML Kit)       │
│  ├── pt-BR Model (30MB, Wi-Fi)   │
│  └── cachedTranslations dict     │
├─────┬─────┬───┬───┬───┬───┬───┤
│  FileManager (Data)               │
│  ├── sentences, vocabwords, qa    │
│  └── mastery, progress sets       │
├─────┬─────┬───┬───┬───┬───┬───┤
│  FileManager (Audio)              │
│  ├── AVSpeechSynthesizer (TTS)    │
│  └── SFSpeechRecognizer           │
└─────┬─────┬───┬───┬───┬───┬───┘
```

## 4. MODULE-BY-MODULE BREAKDOWN

### MODULE 1: VOCABULARY
**Two Modes:**
| Mode | Behavior |
|-----|-----|
| **Match Madness (Game)** | 8 English words (left column) + 8 Portuguese words (right column), shuffled. Match by selection. Pairs remove themselves and are replaced by new random words until 1min 45s time runs out or all words are matched. Optional: Jumble Columns toggle (either language can appear in either column). |
| **Audio Mode** | User selects one or more blocks → sets repetitions (1–9x per word) + gap (seconds between words) → presses Play. Words play in continuous loop until Stop. English word plays, then target-language word plays N times. The core practice tool — memorize through repetition. |

**Data Entry:** Up to 10 blocks of 15 words each. User types native-language word → app auto-translates + saves.

---

### MODULE 2: COMMON SENTENCES
**Flow:** User enters up to 10 dynamic groups of sentences (7 groups to start, expandable up to 50). Types an English sentence into a text field (ghost text: "Add sentence to translate") → ML Kit translates to Portuguese → saves to SQLite. Playback: English plays once, 1.75s gap, Portuguese plays → user gap between sentences → repeat N times. Mastery tracking: unlearned → learning → mastered. Sentences can be toggled on/off.

---

### MODULE 3: PRONUNCIATION
**Flow:** User activates one or more blocks. App presents a random word. User has 3 seconds to pronounce it. App listens, evaluates, and provides feedback: ✅ Good (word removed from round) or 🤨 Needs Work (word shuffled back into the mix). Continues until all words pronounced correctly OR user presses Stop. Can later re-activate "Needs Work" words.

---

### MODULE 4: Q&A
**Flow:** User enters English Question → app translates to Portuguese. User enters English Answer → app translates to Portuguese. Each Q+A pair is saved with audio. User activates one or more Q&A blocks → presses Play → app presents questions/answers in Portuguese with a configurable gap/answer timer. Loop continues until Stop.

## 5. LOGO & LOADING SCREEN STRATEGY

**Initial App Launch (Splash):**
- "Welcome to" (small, top)
- "Langly" (very large, center, Las Vegas-style)
- "your language learning assistant" (small bottom sign board)
- Style: Desert Highway concept (tangerine + turquoise)
- Display: Minimum 2.5s

**Module Loading Screens (one per module, each shown when module is loaded):**
All follow the same base sign architecture but with different motel sign concepts:

| Module | Concept | Colors |
|-----|-----|-----|
| **Vocabulary** | Desert Highway | Tangerine + turquoise |
| **Common Sentences** | Downtown Neon | Baby pink + mint green |
| **Pronunciation** | Forest Lodge | Lavender + warm cream |
| **Q&A** | 50s Atomic/Rocket Ship | Midnight blue + neon yellow |

**Animation:** Smooth fade-in (like a neon sign flickering on), 1s display per sign. No audio, no flicker effect.

## 6. DATA MODEL

```
SwiftData Schema:

User → Settings → AppSettings {homeLanguage, targetLanguage, selectedVoice, playbackGap, loopEnabled}

Module Data:
├── SentenceGroup → {groupName, sentences: [Sentence], isActive}
├── Sentence → {english, translation, mastered, lastPracticed}
├── VocabularyWord → {nativeWord, translatedWord, masteryLevel}
└── QASession → {englishQ, portugueseQ, englishA, portugueseA, mastered}

ModuleProgress:
├── masteredItems (Set)
├── learningItems (Set)
└── unlearnedItems (Set)

TranslationCache:
├── cachedTranslations [String: String]
└── downloadCount, lastDownloaded
```

**All data stored locally.** Zero APIs for the app to run. ML Kit runs on-device. No ongoing costs.

## 7. DEVELOPMENT STRATEGY

**Phase 1: Core Infrastructure (Weeks 1-3)**
- Xcode project setup (SwiftUI + SwiftData + ML Kit + StoreKit 2)
- App architecture (launch screen, main menu, module router)
- Feature flag system (IAP gate logic for modules 2-4)
- Cross-promo carousel implementation

**Phase 2: Module 1 — Vocabulary (Weeks 4-7)**
- Word input system (up to 10 blocks × 15 words)
- ML Kit translation integration
- Match Madness game engine (timer, matching, shuffle, jumble toggle)
- Audio Mode engine (gap, repeat, loop)

**Phase 3: Module 2 — Common Sentences (Weeks 8-10)**
- Dynamic group system (7 groups, up to 50)
- Sentence input + ML Kit translation
- Playback engine (EN → gap → PT, repeat, loop)
- Mastery tracking

**Phase 4: Module 3 — Pronunciation (Weeks 11-13)**
- SFSpeechRecognizer integration
- Word presentation + 3-second answer timer
- Feedback system (✅ Good / 🤨 Needs Work)
- Progress tracking

**Phase 5: Module 4 — Q&A (Weeks 14-16)**
- Q&A input (EQ/PQ/AE/PA)
- Playback engine (question/answer loop, gap/answer timer)
- Shuffle, block toggle, play/stop

**Phase 6: Testing + Submission (Weeks 17-18)**
- Unit + UI tests
- IAP receipt validation testing
- Offline testing
- App Store submission

**Estimated Total Timeline:** 18 weeks (~4.5 months)

## 8. DEVELOPMENT CHECKLIST

- [Xcode project with SwiftUI + SwiftData framework
- [StoreKit 2 integration (IAP + Cross-Promo)
- [ ] ML Kit on-device translation setup (pt-BR model)
- [ ] SwiftData models for all modules
- [ ] FileManager (TTS + Speech Rec)
- [ ] LaunchScreen + Module Loading Screens
- [ ] Module 1 (Vocabulary) — Match Madness + Audio Mode
- [ ] Module 2 (Common Sentences) — group input + playback
- [ ] Module 3 (Pronunciation) — speech recognition + feedback
- [ ] Module 4 (Q&A) — Q&A input + playback loop
- [ ] Unit + UI tests
- [ ] App Store submission**

## 9. LOGO CREATION — HOW TO GET THEM MADE

**You asked how the logos/loading screens should be made. Here's what I recommend:**

### Tools to create the logos:
1. **Image generation:** Best for retro/vintage/motel sign imagery. Prompt examples:
   - `"vintage 1950s desert highway motel neon sign, Welcome to Langly, your language learning assistant, retro americana tangerine turquoise"`
   - `"vintage 1950s downtown neon motel sign, Welcome to Langly, your language learning assistant, downtown neon, red + green"`
   - `"vintage 1950s forest lodge motel sign, Welcome to Langly, your language learning assistant, forest green cream"`
2. **Canva / Figma:** Semi-automatic but very flexible

### The 4 Loading Page concepts (for the logo creation):
1. **"Vocabulary" (Desert Highway):** Tangerine + turquoise retro motel sign
2. **"Common Sentences" (Downtown Neon):** Baby pink + mint green 60s motel sign
3. **"Pronunciation" (Forest Lodge):** Lavender + warm cream mountain lodge sign
4. **"Q&A" (50s Atomic/Rocket):** Midnight blue + neon yellow atomic/rocket ship sign

**Next Steps for Logos:**
A) Generate the 4 images
B) Export as SVG/PNG (for use in SwiftUI as Asset Catalog)
C) Place all 4 logos in `/Resources` folder
D) Use `Image("name")` to load them

## 10. FINAL DECISIONS & LOCKED-IN

| Decision | Status |
|-----|-----|
| **App Model** | Free app + Langly Premium subscription |
| **Pricing** | Free (Module 1) + $8.99/month / R$ 26,90 (Modules 2–4) |
| **Free Trial** | 7 days free, then auto-renew |
| **Module 1** | Match Madness + Audio Mode (locked) |
| **Module 2** | Common Sentences (locked) |
| **Module 3** | Lock |
| **Module 4** | Lock |
| **4 Logo Concepts** | Desert Highway, Downtown Neon, Forest Lodge, Atomic (locked) |
| **Loading Animations** | Fade-in, no audio, no flicker (locked) |
| **Tech Stack** | SwiftUI, SwiftData, ML Kit, StoreKit 2 (locked) |
| **Data Storage** | Offline-first (SwiftData) (locked) |
| **Translation** | On-device (locked) |
| **Audio/Speech** | TTS + Speech Recognition (locked) |
