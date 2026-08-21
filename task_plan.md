# Task Plan — Langly App Store Release

## Phase 1: English Version ✅
- [x] All code features complete (vocabulary, game, audio, achievements, streaks)
- [x] Loading graphics for locked modules
- [x] Privacy policy on GitHub Pages
- [x] App Store metadata (description, keywords)
- [x] Screenshots captured (6.7" and 6.1")
- [x] Security audit passed
- [x] Orientation fix for iPad multitasking
- [x] Uploaded to App Store Connect

## Phase 2: PT-BR Version
- [x] All UI strings translated to Brazilian Portuguese
- [x] Word pairs flipped (Portuguese native, English target)
- [x] Phonetic pronunciation guide for English words
- [x] Audio TTS language fix (isNativePortuguese flag)
- [x] Code parity verified with English version
- [x] Archive and upload to App Store Connect
- [x] Create App Store Connect listing (com.langly.app.pt)

## Phase 3: Subscription Monetization ✅
- [x] ASC subscription group + pricing configured ($8.99/mo USA, R$ 26,90/mo BRA)
- [x] IAPManager rewritten for auto-renewable subscription
- [x] ModuleRouter updated (modules 2–4 → premium)
- [x] PaywallView added to MainMenuView
- [x] SettingsView "Como Usar" section
- [x] Build passed strict concurrency
- [x] All files restored from backup → live project

## Phase 4: App Store Submission
- [ ] StoreKit Configuration file for simulator testing
- [ ] Capture paywall screenshots for ASC review
- [ ] Complete ASC review metadata (MISSING_METADATA → READY_TO_SUBMIT)
- [ ] Upload build 1.1 + submit English for review
- [ ] Fix LanglyPT REJECTED 1.0
- [ ] Submit PT-BR for review
- [ ] Wait for Apple review (24-48 hours each)

## Phase 5: Post-Launch
- [ ] Monitor reviews
- [ ] Portuguese proofreader feedback
- [ ] Add more vocabulary content
- [ ] Common Sentences module
- [ ] Pronunciation module
- [ ] Q&A module
