# SESSION_HANDOFF.md
**Date:** 2026-07-25  
**Branch:** master  
**Remote:** github.com/moviecolor/langly-app.git (synced)

## Current State
App builds and runs on iPhone 16 Pro simulator (iOS 18.3). All features working: vocabulary module with audio playback, Match Madness game, Audio Mode, word blocks, achievements, streaks, analytics. Onboarding removed (caused infinite loop). Voice picker with male/female pitch differentiation.

## What We Accomplished This Session

### Match Madness Fixes (COMPLETED ✅)
- **Dark mode readability** — Tile backgrounds changed to 95% white with black text (was using `Color.appSurface` which is dark in dark mode)
- **Word font size** — Increased from `.callout.bold()` to `.body.bold()` (2pts bigger)
- **Swipe-to-delete word blocks** — Added swipe-left action on word block cards in VocabularyView

### Voice Picker (COMPLETED ✅)
- **Male voice always visible** — Section always shows, falls back to system voice if no male voice installed
- **Custom display names** — Female shows as "Valeria", Male shows as "Ryan"
- **Gender selection tracking** — `selectedGender` state + `@AppStorage("selectedVoiceGender")` persistence, independent selection per gender
- **Pitch differentiation** — Male at 0.5 pitch, Female at 1.15 pitch (applies in test button + Audio Mode playback)
- **AudioModeViewModel** — Added `selectedVoiceGender` property, applies pitch in `speakNextUtterance()`
- **AudioEngine** — Added gender/pitch support (not actively used by views but ready)

### Onboarding Removed (COMPLETED ✅)
- **Root cause of loop** — OnboardingView opened ContentView as fullScreenCover, creating nested LaunchScreen → onboarding cycle
- **Fix** — Removed onboarding entirely from ContentView (showOnboarding state, fullScreenCover, task check)

### Gender Detection
- Original `voiceGender()` function kept as-is (matches joão, lucas, felipe for Male; maria, fernanda, lucia for Female)
- Simulator only has Luciana (female) — male section shows fallback voice with lower pitch

## Files Modified This Session
- `Sources/Views/ContentView.swift` — Removed onboarding (showOnboarding, fullScreenCover, @Query settings)
- `Sources/Views/SettingsView.swift` — Voice picker: always-show sections, selectedGender state, @AppStorage persistence, voiceDisplayName(), voiceChip selection fix, pitch in testVoice()
- `Sources/Views/Modules/Vocabulary/MatchMadnessGameView.swift` — Dark mode: 95% white tile backgrounds, black text; font size increased to .body.bold()
- `Sources/Views/Modules/Vocabulary/VocabularyView.swift` — Swipe-to-delete word blocks, deleteBlock() method
- `Sources/Views/Modules/Vocabulary/AudioModeView.swift` — Added @AppStorage gender, passes to viewModel
- `Sources/ViewModels/AudioModeViewModel.swift` — Added selectedVoiceGender, pitch multiplier in speakNextUtterance()
- `Sources/Services/AudioEngine.swift` — Added selectedVoiceGender, pitch multiplier in makeUtterance()

## What Can Be Done Next
- Host privacy policy on GitHub Pages
- Localize the app into Brazilian Portuguese (~140 hardcoded English strings)
- Add more vocabulary content
- Polish UI animations
- Test on physical device
- App Store submission (when $99/year membership renewed)

## Known Issues
- `commit-msg` hook has unbound variable error (`VALID_Types`)
- `gh` CLI not installed
- iPhone 17 Pro simulators can't build (iOS 26.2 runtime not available)
- Simulator only has one Portuguese voice (Luciana) — male/female differentiation via pitch only
- Apple Developer membership expired — cannot upload/submit to App Store
