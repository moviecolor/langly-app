# SESSION_HANDOFF.md
**Date:** 2026-07-24  
**Branch:** master  
**Commit:** 57b3799  
**Remote:** github.com/moviecolor/langly-app.git (synced)

## Current State
The app builds and runs on iPhone 16 Pro simulator (iOS 18.3). All features working: vocabulary module with audio playback, game mode, scores, spaced repetition. Loading graphics for locked modules now working with full-screen neon backgrounds.

## What We Accomplished This Session

### Loading Graphics (COMPLETED ✅)
- Fixed navigation bug: `lockedModuleView` was intercepting all locked modules — now all modules always route to their full views
- Removed `.disabled(!isUnlocked)` so locked modules are tappable
- Added full-screen loading graphics to Common Sentences, Pronunciation, and Q&A pages
- Graphics sourced from `Resources/LANGLY_ICONS_LOAD_PGS/LOADING_PROMO/`:
  - Common Sentences → `CS_003.png`
  - Pronunciation → `P_001.png`
  - Q&A → `Q_005.png`
- Layout: description at top (110pt), "COMING SOON" badge + title at bottom (40pt)
- Gradient overlay (`.clear` → `.black.opacity(0.5)`) for readability
- Root cause found: XcodeGen's `resources: - Resources` doesn't copy loose PNGs — images MUST be in Assets.xcassets

### Other Fixes (committed earlier)
- IAPManager retain cycle fix
- AudioEngine delegate memory leak fix
- WordInputView GCD → Task.sleep fix

## Files Modified
- `Sources/Views/MainMenuView.swift` — removed lockedModuleView routing, removed `.disabled`
- `Sources/Views/Modules/CommonSentences/CommonSentencesView.swift` — loading graphic + layout
- `Sources/Views/Modules/Pronunciation/PronunciationView.swift` — loading graphic + layout
- `Sources/Views/Modules/QA/QAView.swift` — loading graphic + layout
- `Sources/Assets.xcassets/CommonSentencesLoading.imageset/` — CS_003.png as loading.png
- `Sources/Assets.xcassets/PronunciationLoading.imageset/` — P_001.png as loading.png
- `Sources/Assets.xcassets/QALoading.imageset/` — Q_005.png as loading.png

## Deleted (cleanup)
- `Sources/Views/Modules/BundleImage.swift` — unused bundle image loader
- `Resources/CS_Loading.png`, `P_Loading.png`, `Q_Loading.png` — moved to asset catalog

## Key Learnings
- **XcodeGen `resources:` does NOT copy loose files** — only works for folder references. Images must go in Assets.xcassets.
- `UIImage(named:)` only works with asset catalog images, not bundle resources
- To load a PNG from the bundle at runtime, it must be explicitly added to a build phase
- The `.car` (compiled asset catalog) can be inspected with `xcrun assetutil --info Assets.car`

## Known Issues
- `commit-msg` hook has an unbound variable error (`VALID_Types`)
- `gh` CLI not installed
- iPhone 17 Pro simulators can't build (iOS 26.2 runtime not available)

## Next Steps
- App Store metadata: screenshots, description, keywords, privacy policy
- PrivacyInfo.xcprivacy manifest
- IAP product registration in App Store Connect
