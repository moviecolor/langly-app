# SESSION HANDOFF — Langly 1.2 Release Prep (2026-09-24)

## Current State
- **Branch:** `fix/l1.2-phone-bugs` (LANGLY_PROJECT root: `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT`)
- **1.2 (3)** build `8800045f-a5a6-42e5-a223-8d39996868ee` — **audio-on-screen-lock fix CONFIRMED WORKING on device** (user tested 2026-09-24)
- 1.2 version object created on ASC, state **PREPARE_FOR_SUBMISSION**
- Screenshots: **inherited from 1.1 automatically — all COMPLETE** (6.1": 02_MatchMadness, 03_AudioMode; 6.7": 01_MainMenu→05_QA). Do NOT re-upload; local `AppStoreScreenshots/` PNGs are 1170×2532 (6.1") which the 2026 API REJECTS for APP_IPHONE_61 (IMAGE_INCORRECT_DIMENSIONS).
- What's New corrected to **direction+audio fixes** in `scripts/submit_release.py` + `RELEASE_NOTES_LANGLY_1.2.md` (was stale "Premium subscription" text).
- **IAP/subscription: NOT LIVE.** ASC subscription group "Langly Premium" → "Langly Premium Monthly" `com.langly.app.premium.monthly` state **MISSING_METADATA** (test prices $0.29/0.39/0.49, never approved). No build with the IAP has ever reached App Review. **Nobody has ever paid.**
- **COMING SOON change IMPLEMENTED but uncommitted** (Localization.swift + MainMenuView.swift): modules 2–4 (Common Sentences, Pronunciation, Q&A) show **COMING SOON** + mailto request button (`support@langly.app`, "Yes, I want this module released") instead of premium paywall. **No paywall exists for Audio Mode** (user directive: audio mode "just available"). PaywallView remains in MainMenuView (~line 312) but is now unreferenced — keep as future home for a first-launch subscription gate.
- **Simulator resolver FIXED for good** (see below + playbook §9).

## Last Commits (all pushed to `backup` mirror; `github` blocked on stale auth)
- `6078ed8` docs(release): [SAVE ALL NOW] ledger
- `159411c` fix(ios): what's new + upload helper + 1.2 PREPARE_FOR_SUBMISSION
- `06046ba` docs(ios): playbook §8 — beta group attachment required
- `e200226` fix(ios): fastlane beta attaches builds to Langly Internal group
- `f11c511` chore(ios): ship 1.2 (3) with background-audio plist fix

## Git Remote Status
- `backup` = THUNDER mirror: **current** (all pushed)
- `github` = moviecolor/langly-app.git: **still failing** `Invalid username or token`. User must `gh auth login` / refresh PAT. Blocked but non-urgent.

## Simulator builds — TRUE root cause found & fixed (2026-09-24, do not regress)
- **The real bug was never the resolver:** `scripts/xcbuild.sh` exported `CFFIXED_USER_HOME` (and before that `HOME`) into a sandbox dir → xcodebuild lost ALL simulator destinations (only physical placeholders remained) → "Unable to find a destination ... iOS 26.2 is not installed" even with a correct destination. Bisected: `CFFIXED_USER_HOME` alone = FAIL; all other sandbox vars alone = SUCCEED.
- **Fixed:** `scripts/xcbuild.sh` no longer exports `CFFIXED_USER_HOME`/`HOME` (keeps module caches, TMPDIR). `scripts/resolve_sim_destination.sh` also fixed (name+OS, full version from runtimes -j, lowest buildable runtime 18.3.1). Both carry dated NOTE blocks.
- **Verified end-to-end:** `make build` ✅, `make test` ✅ (12/12: AudioOrderingTests 6, LanglyTests 1, LocalizationTests 5).
- Known-good destination verbatim: `platform=iOS Simulator,name=iPhone 16 Pro,OS=18.3.1`. Full root cause + fix: **TESTFLIGHT_PLAYBOOK.md §9**.
- **Do NOT** re-add CFFIXED_USER_HOME/HOME to xcbuild.sh, pin a UDID, use OS=26.3, or "temporarily" edit the resolver — that's how this bit twice (2026-09-18, 2026-09-24).

## Immediate Next Actions (after this compaction)
1. **Audit the uncommitted diff** (Localization.swift + MainMenuView.swift, coming-soon work) — already builds + tests green above; review the change, then commit e.g. `feat(ios): modules 2-4 COMING SOON + mailto request` (hook scope).
2. **Decide monetization entry model** — user wants "asked to buy subscription at App Store entry, then everything available". Apple does NOT allow charging a subscription pre-download; closest compliant option is free download + first-launch gate (PaywallView kept in MainMenuView for exactly this). User has NOT confirmed this yet. Audio Mode: never paywalled.
3. **Decide build**: submit existing 1.2 (3) for App Review (`python3 scripts/submit_release.py --yes`) OR build 1.2 (4) after committing the coming-soon change for internal test first.
4. **GitHub auth still needed**: `gh auth login` (one-time, keychain — never a token in markdown). Also wiring a `gh auth status` + dual-push step into SAVE ALL NOW per user request (pending in GLOBAL_RULES.md).

## Key Files
- `scripts/submit_release.py` — BUILD_ID = 8800045f (1.2 (3)); `--yes` submits to App Review
- `scripts/verify_bgmode.sh` — regression gate for background-audio plist
- `fastlane/Fastfile` — `beta` lane now has `groups: ["Langly Internal"]`
- `TESTFLIGHT_PLAYBOOK.md` — §8 = internal-group attachment trap; §7 = store assets; **§9 = phantom iOS 26.3 sim runtimes + resolver fix**
- `RELEASES.md` — release ledger (1.2 builds 1–3)
- `Support/Info.plist` — UIBackgroundModes=[audio] (the audio-lock fix)