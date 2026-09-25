# SESSION HANDOFF — Langly 1.2 Release Prep (2026-09-25)

## Current State
- **Branch:** `fix/l1.2-phone-bugs` (LANGLY_PROJECT root: `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT`)
- **1.2 (4)** build `4b530a1d-abb6-4b0b-97e3-5783cb494538` — **uploaded, VALID, attached to "Langly Internal" group** (verified: group→builds = `['4', '3', '1']`). Changelog now headlines Langly Premium (EN + PT).
- **1.2 (3)** build `8800045f-a5a6-42e5-a223-8d39996868ee` — still in TestFlight for beta testers. ⚠️ It references the DEAD product ID `com.langly.app.premium.monthly` (deleted V1 subscription) — testers tapping "Go Premium" in v3 see NO product. Fine for testing app/trial/2-block gate, NOT for paywall.
- **IAP/subscription: FULLY CONFIGURED → READY_TO_SUBMIT.**
  - Subscription **`6815736929`** "Langly Premium Monthly", product ID **`com.langly.app.premium.monthly.2`** (old ID tombstoned by Apple after V1 deletion), group `22293861`, ONE_MONTH, familySharable, state **READY_TO_SUBMIT**.
  - Localizations: en-US + pt-BR (≤55 char descriptions). Group localization en-US exists.
  - Pricing: **all 175 territories** — USA $8.99, BRA R$26.90 (manual override, restored AFTER the 174-territory equalization spread from USA), CAN $11.99, GBR $8.99, DEU $9.99, JPN ¥1500, etc.
  - **Intro offer:** PAY_UP_FRONT, ONE_MONTH, 1 period, USA only, **$2.99** (price point `...MTAwMzY`), startDate 2026-09-24. (7-day full-access trial is APP-SIDE via `AppSettings.installDate` — NOT an Apple free trial, Apple forbids stacking trial+price.)
  - Review screenshot: `AppStoreScreenshots/6.7in/02_Vocabulary.png` (1290×2796) → COMPLETE.
  - Availability: created with `--available-in-new-territories` + all 174 territories.
- **App code matches ASC:** `Sources/Services/IAPManager.swift` `premiumMonthlyID` = `com.langly.app.premium.monthly.2` (+ doc note). Build + **29/29 tests green** against it.
- **Monetization model (app-side, user-confirmed):** 7-day full access from first launch; then 2 oldest word blocks stay free (newer blocks visible + padlocked); Add Block → "Unlock Unlimited Blocks"; Match Madness + Audio Mode free forever; hard ceiling `maxBlocks = 10`. COMING SOON for modules 2–4 (Common Sentences, Pronunciation, Q&A) with mailto request (committed `b8d0070`).
- **1.2 version object** on ASC exists (PREPARE_FOR_SUBMISSION from earlier session) — build 4 not yet attached to it.

## Last Commits (pushed to `backup` mirror; `github` still blocked)
- `66b8f6a` fix(ios): Langly Premium subscription re-created via modern ASC API (product ID .monthly.2) + setup_subscription.py now documents verified `asccli` flow
- `e459a3b` feat(ios): 7-day full-access trial, then shrink to 2 free word blocks
- `6a86dd0` fix(ios): stop sandboxing HOME/CFFIXED_USER_HOME in xcbuild.sh
- `b8d0070` feat(ios): modules 2–4 COMING SOON + mailto request
- Earlier: `ca9d3e1`/`6078ed8` [SAVE ALL NOW] handoff/ledger, `159411c` What's New fixes
- `github` remote (moviecolor/langly-app.git) STILL failing `Invalid username or token` — user must `gh auth login` once. Non-urgent (backup mirror current).

## Simulator builds — root cause (2026-09-24, do not regress)
- `scripts/xcbuild.sh` must NOT export `CFFIXED_USER_HOME`/`HOME` (kills every sim destination). `scripts/resolve_sim_destination.sh` picks lowest buildable runtime (18.3.1). Known-good dest: `platform=iOS Simulator,name=iPhone 16 Pro,OS=18.3.1`. Full: TESTFLIGHT_PLAYBOOK.md §9.

## Immediate Next Actions
1. **Beta phase:** let testers run 1.2 (4) — it has the REAL paywall/subscription (build 4 attached to Langly Internal). v3 testers should be told to update.
2. **When testers are done on v4** → submit for review. v4 is the only build that can submit cleanly (v3 has dead product ID). Steps: attach build 4 to the 1.2 version page (`appStoreVersionLocalizations`/build relationship), verify screenshots on 1.2 version page are COMPLETE, then `subscriptions submit --subscription-id 6815736929` + submit app version for review together.
3. **GitHub auth still needed:** `gh auth login` (one-time, keychain). Then dual-push works to both remotes.
4. Consider `asccli` authed as `langly` for ANY ASC reads — raw `GET /v1/subscriptions/{id}` 404s ("path does not match a defined resource type"); use `asccli subscriptions list --group-id 22293861` instead.

## Key Files
- `fastlane/Fastfile` — `beta` lane: build + upload + `groups: ["Langly Internal"]` (REQUIRED, hasAccessToAllBuilds=false trap, §8), changelog from EN_NEWS/PT_NEWS (now Premium-focused for v4)
- `project.yml` — CURRENT_PROJECT_VERSION: 4, MARKETING_VERSION: 1.2
- `scripts/setup_subscription.py` — VERIFIED `asccli` command sequence (localizations, prices set-batch + equalizations, availability, intro offer, review screenshot, submit)
- `Sources/Services/IAPManager.swift` — premiumMonthlyID `.monthly.2`
- `TESTFLIGHT_PLAYBOOK.md` — §5 submit prerequisites, §7 store assets/missing version-page risk, §8 internal-group trap, §9 sim resolver
- `RELEASES.md` — release ledger; `RELEASE_NOTES_LANGLY_1.2.md` — What's New copy
- `~/.appstoreconnect/keys/fastlane_api_key.json` + `AuthKey_87CV539PA4.p8` — ASC API creds (team DW62VTMN2Z, app 6794917761)
- `asccli` CLI: `brew install asccli`, authed as `langly` — use `asc ___` subcommands for all ASC state