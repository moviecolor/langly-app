# SESSION HANDOFF — Langly 1.2 Release Prep (2026-09-25)

## Current State
- **Branch:** `fix/l1.2-phone-bugs` (LANGLY_PROJECT root: `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT`)
- **1.2 (4)** build `4b530a1d-abb6-4b0b-97e3-5783cb494538` — **uploaded, VALID, engine for beta**: attached to "Langly Internal" (Ryan) AND **"Langly Beta Testers" external group** (Juliana Longo `jlongosilva@gmail.com` + Rafa Grip `cabral2017rafa@gmail.com`, both **INVITED** 2026-09-25). Beta App Review was already **APPROVED** for this build (`betaReviewState: APPROVED`, `externalBuildState: IN_BETA_TESTING`) → no review delay, invites went out via Apple email.
- **1.2 (3)** build `8800045f-a5a6-42e5-a223-8d39996868ee` — still in TestFlight for other beta testers. ⚠️ References DEAD product ID `com.langly.app.premium.monthly` — paywall/product unworkable in v3. App/trial/2-block gate work fine.
- **IAP/subscription: FULLY CONFIGURED → READY_TO_SUBMIT.**
  - Subscription **`6815736929`** "Langly Premium Monthly", product ID **`com.langly.app.premium.monthly.2`** (old ID tombstoned after V1 deletion), group `22293861`, ONE_MONTH, familySharable, state **READY_TO_SUBMIT**.
  - Localizations: en-US + pt-BR (≤55 char). Group localization en-US.
  - Pricing: **all 175 territories** — USA $8.99, BRA R$26.90 (manual override restored AFTER the 174-territory equalization), CAN $11.99, GBR $8.99, DEU $9.99, JPN ¥1500.
  - **Intro offer:** PAY_UP_FRONT, ONE_MONTH, 1 period, USA only, **$2.99** (price point `...MTAwMzY`). 7-day trial is APP-SIDE (installDate) — NOT an Apple free trial.
  - Review screenshot: `AppStoreScreenshots/6.7in/02_Vocabulary.png` → COMPLETE.
  - Availability: created, all-new-territories + 174 explicit.
- **App code matches ASC:** `IAPManager.premiumMonthlyID` = `.monthly.2`. Build + **29/29 tests green**.
- **GitHub push auth FIXED (2026-09-25)** — was blocked since 2026-09-18. `gh auth login --web` MUST use **Waterfox** (moviecolor session lives there; Chrome silently fails). Then `gh auth setup-git`. Both remotes now current. See **TESTFLIGHT_PLAYBOOK.md §10**.
- **Juliana outreach SENT (2026-09-25):** WhatsApp letter built as pretty Palatino PDF (`docs/Langly_WhatsApp_Juliana.pdf` + HTML source `docs/langly_letter_juliana.html`, committed). Sent via WhatsApp + TestFlight invite email already delivered. Teacher free-access mechanism NOT yet built — next task when she responds.
- **Monetization model (app-side):** 7-day full access; then 2 oldest blocks free (newer visible+padlocked); Add Block → paywall; Match Madness + Audio free; ceiling maxBlocks=10. Modules 2–4 COMING SOON + mailto.
- **1.2 version object** on ASC exists (PREPARE_FOR_SUBMISSION) — build 4 not yet attached.

## Last Commits (both remotes pushed — backup AND github, both current)
- `fb7abb4` docs(marketing): WhatsApp letter Juliana (Palatino PDF + HTML)
- `a1f220f` docs(release): playbook §10 — GitHub push auth fix (Waterfox flow)
- `1b89b50` docs(release): [SAVE ALL NOW] ship 1.2 (4) with working Langly Premium subscription
- `66b8f6a` fix(ios): subscription re-created via modern ASC API (product ID .monthly.2)
- `e459a3b` feat(ios): 7-day full-access trial → 2 free blocks
- Earlier: `6a86dd0` sim resolver fix, `b8d0070` COMING SOON modules

## Immediate Next Actions
1. **Wait for Juliana + Rafa to accept/install** (`state` → INSTALLED). Then they can test the REAL paywall ($2.99 intro → $8.99) on build 4.
2. **When testers wrap up v4** → submit for review: attach build 4 to 1.2 version page, verify screenshots COMPLETE on version page, then `asc subscriptions submit --subscription-id 6815736929` + submit app version together.
3. **Build teacher free-access mechanism** (promised in the Juliana letter: "I'll set up a way for all of your students to get free access"). Not started — design decision: promo-code/one-time-unlock redeemable in-app vs teacher-beta flag. Small feature in IAPManager/PremiumAccess.
4. Keep both remotes in sync (auth now works — dual-push from here on).

## Key Files
- `fastlane/Fastfile` — beta lane: build + upload + `groups: ["Langly Internal"]` (REQUIRED, §8)
- `project.yml` — CURRENT_PROJECT_VERSION: 4, MARKETING_VERSION: 1.2
- `scripts/setup_subscription.py` — VERIFIED `asccli` command sequence (localizations, prices set-batch + equalizations, availability, intro offer, review screenshot, submit)
- `docs/langly_letter_juliana.html` + `docs/Langly_WhatsApp_Juliana.pdf` — Juliana outreach letter
- `Sources/Services/IAPManager.swift` — premiumMonthlyID `.monthly.2`
- `TESTFLIGHT_PLAYBOOK.md` — §5 submit prereqs, §7 store assets, §8 internal-group trap, §9 sim resolver, **§10 GitHub auth (Waterfox)**, [NEW] external tester group flow
- `RELEASES.md` — 1.2 (4) ledger entry
- `~/.appstoreconnect/keys/fastlane_api_key.json` + `AuthKey_87CV539PA4.p8` — ASC creds (team DW62VTMN2Z, app 6794917761)
- `asccli` CLI authed as `langly` — for all ASC state reads (`GET /v1/subscriptions/{id}` 404s; use `asccli subscriptions list --group-id 22293861`)