# SESSION HANDOFF — Langly 1.2 Release Prep (2026-09-24)

## Current State
- **Branch:** `fix/l1.2-phone-bugs` (LANGLY_PROJECT root: `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT`)
- **1.2 (3)** build `8800045f-a5a6-42e5-a223-8d39996868ee` — **audio-on-screen-lock fix CONFIRMED WORKING on device** (user tested 2026-09-24)
- 1.2 version object created on ASC, state **PREPARE_FOR_SUBMISSION**
- Screenshots: **inherited from 1.1 automatically — all COMPLETE** (6.1": 02_MatchMadness, 03_AudioMode; 6.7": 01_MainMenu→05_QA). Do NOT re-upload; local `AppStoreScreenshots/` PNGs are 1170×2532 (6.1") which the 2026 API REJECTS for APP_IPHONE_61 (IMAGE_INCORRECT_DIMENSIONS).
- What's New corrected to **direction+audio fixes** in `scripts/submit_release.py` + `RELEASE_NOTES_LANGLY_1.2.md` (was stale "Premium subscription" text).
- **IAP/subscription: NOT LIVE.** ASC subscription group "Langly Premium" → "Langly Premium Monthly" `com.langly.app.premium.monthly` state **MISSING_METADATA** (test prices $0.29/0.39/0.49, never approved). No build with the IAP has ever reached App Review. **Nobody has ever paid.** Paywall currently cannot complete a real charge.

## Last Commits (all pushed to `backup` mirror; `github` blocked on stale auth)
- `6078ed8` docs(release): [SAVE ALL NOW] ledger
- `159411c` fix(ios): what's new + upload helper + 1.2 PREPARE_FOR_SUBMISSION
- `06046ba` docs(ios): playbook §8 — beta group attachment required
- `e200226` fix(ios): fastlane beta attaches builds to Langly Internal group
- `f11c511` chore(ios): ship 1.2 (3) with background-audio plist fix

## Git Remote Status
- `backup` = THUNDER mirror: **current** (all pushed)
- `github` = moviecolor/langly-app.git: **still failing** `Invalid username or token`. User must `gh auth login` / refresh PAT. Blocked but non-urgent.

## Immediate Next Actions (after this compaction)
1. **Decision pending from user** — change modules 2–4 (Common Sentences, Pronunciation, Q&A) from premium-locked to **"COMING SOON"**:
   - User's chosen mechanism: tapping the coming-soon button triggers an **email to support** prefilled "Yes I want this module to be released" (`mailto:` — support@langly.app already used in SettingsView.swift line 495)
   - User question to resolve: is 1.2 currently charging a subscription? **ANSWER: No — not live, MISSING_METADATA seed subscription.** So flipping to coming-soon loses zero revenue.
2. Implement change in `Sources/Views/MainMenuView.swift` (`moduleCard` locked state: "Available with Langly Premium" → "COMING SOON"; `lockedModuleView`: replace paywall button with mailto request button) + `Sources/Services/Localization.swift` strings (~4 keys). Small task, ~30-45 min. Optionally log in LocalAnalytics.
3. Decide what happens to the Premium subscription story once modules 2-4 become demand-gated (re-position, shelve IAP, or keep for Vocabulary extras).
4. After decisions: build 1.2 (4)? OR submit existing 1.2 (3) for App Review: `python3 scripts/submit_release.py --yes` (dry-run currently green).
5. GitHub auth still needed: `gh auth login`.

## Key Files
- `scripts/submit_release.py` — BUILD_ID = 8800045f (1.2 (3)); `--yes` submits to App Review
- `scripts/verify_bgmode.sh` — regression gate for background-audio plist
- `fastlane/Fastfile` — `beta` lane now has `groups: ["Langly Internal"]`
- `TESTFLIGHT_PLAYBOOK.md` — §8 = internal-group attachment trap; §7 = store assets
- `RELEASES.md` — release ledger (1.2 builds 1–3)
- `Support/Info.plist` — UIBackgroundModes=[audio] (the audio-lock fix)