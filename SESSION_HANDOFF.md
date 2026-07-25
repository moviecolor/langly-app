# SESSION_HANDOFF.md
**Date:** 2026-07-24  
**Branch:** master  
**Commit:** ea8783d  
**Remote:** github.com/moviecolor/langly-app.git (synced)

## Current State
The app builds and runs on iPhone 16 Pro simulator (iOS 18.3). All features working: vocabulary module with audio playback, game mode, scores, spaced repetition. Loading graphics for locked modules working. App Store submission materials prepared.

## What We Accomplished This Session

### App Store Submission Materials (COMPLETED ✅)
- **PrivacyInfo.xcprivacy** — Created, in build, verified in Assets.car
- **Info.plist** — Updated with display name, export compliance
- **AppStoreMetadata.md** — Full listing: name, subtitle, description, keywords, categories, IAP pricing
- **PRIVACY_POLICY.md** — Ready to host at any URL
- **SUBMISSION_CHECKLIST.md** — Step-by-step guide for submission
- **Screenshots** — 10 images captured:
  - 6.7" (1290×2796) — 5 screens: Main Menu, Vocabulary, Common Sentences, Pronunciation, Q&A
  - 6.1" (1206×2622) — 5 screens: Same

### Loading Graphics (COMPLETED ✅)
- Fixed navigation: removed `lockedModuleView` interception — all modules now route to their full views
- Added full-screen neon loading graphics to Common Sentences, Pronunciation, Q&A
- Layout: description at top (110pt), "COMING SOON" badge at bottom (40pt)
- Root cause: XcodeGen `resources:` doesn't copy loose PNGs — images must be in Assets.xcassets

### Other Fixes (committed earlier)
- IAPManager retain cycle fix
- AudioEngine delegate memory leak fix
- WordInputView GCD → Task.sleep fix

## Files Modified
- `Sources/Views/MainMenuView.swift` — Removed lockedModuleView routing, removed `.disabled`
- `Sources/Views/Modules/CommonSentences/CommonSentencesView.swift` — Loading graphic + layout
- `Sources/Views/Modules/Pronunciation/PronunciationView.swift` — Loading graphic + layout
- `Sources/Views/Modules/QA/QAView.swift` — Loading graphic + layout
- `Sources/Assets.xcassets/CommonSentencesLoading.imageset/` — CS_003.png
- `Sources/Assets.xcassets/PronunciationLoading.imageset/` — P_001.png
- `Sources/Assets.xcassets/QALoading.imageset/` — Q_005.png
- `Sources/PrivacyInfo.xcprivacy` — NEW: Apple privacy manifest
- `Sources/Info.plist` — Updated with App Store entries
- `project.yml` — Added PRIVACY_MANIFEST_FILE, display name, export compliance
- `AppStoreMetadata.md` — NEW: Full App Store listing
- `PRIVACY_POLICY.md` — NEW: Privacy policy
- `SUBMISSION_CHECKLIST.md` — NEW: Submission guide
- `AppStoreScreenshots/` — NEW: 10 screenshot images

## Key Learnings
- **XcodeGen `resources:` does NOT copy loose files** — only works for folder references. Images must go in Assets.xcassets.
- `UIImage(named:)` only works with asset catalog images
- `xcrun simctl io screenshot` captures exact device resolution
- AppleScript `click at {x, y}` works for simulator navigation but coordinates are window-relative
- Apple requires PrivacyInfo.xcprivacy since Spring 2024
- Archive requires development team (active $99/year membership)

## What's Blocked (needs $99/year Apple Developer membership)
- Upload build to App Store Connect
- Create app listing
- Set up IAP products
- Submit for review
- TestFlight distribution

## What Can Be Done Without Membership
- Host privacy policy on GitHub Pages
- Improve app features/UI
- Add more screenshots
- Create app preview video
- Localize the app
- Test on physical device (free provisioning, 7 days)
- Add more vocabulary content
- Improve audio mode
- Add achievements/streaks
- Polish UI animations

## Known Issues
- `commit-msg` hook has an unbound variable error (`VALID_Types`)
- `gh` CLI not installed
- iPhone 17 Pro simulators can't build (iOS 26.2 runtime not available)
