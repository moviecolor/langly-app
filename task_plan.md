# Task Plan: LANGLY_APP — Language Learning Assistant

## Goal
Build the Langly language learning assistant iOS app with:
- Loading screens + basic UI structure
- Vocabulary Module 1 (Match Madness + Audio Mode)
- Rough-in links to Modules 2, 3, 4
- Initial architecture for later expansion

## CRITICAL CONTEXT
- **LANGLY IS A LANGUAGE LEARNING APP** — NOT a task management app
- Tech Stack: SwiftUI + SwiftData + GoogleML Kit (offline translation) + StoreKit 2 + AVSpeechSynthesizer + SFSpeechRecognizer
- Pricing: $6.99 upfront + IAP bundles ($9.99 bundle)
- Overview Doc: `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/Langly_Overview.md`
- Project Dir: `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT/`
- Xcode: 26.3 at `/Applications/Xcode.app`

## Current Phase
Phase 0: Core Infrastructure & Vocabulary Module (in progress)

## Active Subagent Jobs
| Job # | Subagent | Task | Status |
|-------|----------|------|--------|
| Job 1 | @implementation-specialist | **Project Structure & Core Services** — Clean scaffolding, project.yml, SwiftData models (AppSettings, SentenceGroup, Sentence, VocabularyWord, QASession, ModuleProgress, WordBlock), TranslatorManager (ML Kit), IAPManager (StoreKit 2), AudioEngine (AVSpeechSynthesizer) | **IN PROGRESS — DELEGATING NOW** |
| Job 2 | @architect-designer | **UI Architecture & Loading Screens** — LaunchScreen (Desert Highway neon), MainMenu tabBar, 4 Loading Screens (Vocab=tangerine/turquoise, CommonSentences=baby pink/mint green, Pronunciation=lavender/warm cream, Q&A=midnight blue/neon yellow), Module Router | **IN PROGRESS — DELEGATING NOW** |
| Job 3 | @implementation-specialist | **Vocabulary Module 1** — Match Madness game engine (8x8 grid, timer, scoring, jumble toggle), Match Madness UI, Audio Mode (gap, repeat, loop logic), VocabularyViewModel, stubs for Modules 2-4 navigation | **COMPLETE** |

## Phases

### Phase 0: Project Structure & Infrastructure (NOW)
- [ ] Old scaffolding cleaned (**DONE**)
- [ ] Directory structure created (**DONE**)
- [ ] **Job 1**: SwiftData models + core services (**DONE**)
- [ ] **Job 2**: LaunchScreen, MainMenu, Loading Screens (**DONE**)
- [ ] **Job 3**: Vocabulary Module (Match Madness + Audio Mode) (**DONE**)
- [ ] Update project.yml with GoogleMLKit + StoreKit dependencies
- [ ] Verify project compiles

### Phase 1: Vocabulary Module — Complete
- [x] Match Madness game fully implemented
- [x] Audio Mode fully implemented
- [ ] Cross-module wiring (profile/search stubs)
- [ ] In-App Purchase stubs (StoreKit 2)

### Phase 2: Modules 2-4 Architecture (Stubs)
- [ ] Common Sentences module stub
- [ ] Pronunciation module stub
- [ ] Q&A module stub
- [ ] Navigation between modules

### Progress Update Queue
- [x] Job 1 output received → Reviewed & integrated
- [x] Job 2 output received → Design reviewed
- [x] Job 3 output received → All 6 files created, no code errors
- [ ] Build complete project (blocked on MLKitTranslate CocoaPods install)
| Job # | Subagent | Task | Status |
|-------|----------|------|--------|
| Job 1 | @xcode-web-reviewer | Clean old code, create correct directory structure, update project.yml for Langly | IN PROGRESS |
| Job 2 | @implementation-specialist | All SwiftData models + core services from Langly spec | READY |
| Job 3 | @architect-designer | Launch Screen, Main Menu, 4 Loading Screens (stubs), Module Router | READY |

### Progress Update Queue
- [ ] **Job 1**: IN PROGRESS
- [ ] **Job 2**: READY — will execute after structure is complete
- [ ] **Job 3**: READY — will execute in parallel with Job 2
- [ ] Review outputs → Verify compiles → Wire + test
- [ ] Next module

### Active Subagent Jobs