# SESSION_HANDOFF.md
**Date:** 2026-08-21
**Branch:** master
**Remote:** github.com/moviecolor/langly-app.git

## Current State
**Langly EN (com.langly.app) — READY_FOR_SALE at version 1.0.** Already approved and live on App Store.

**Langly PT-BR (com.langly.app.pt) — version 1.1 SUBMITTED FOR REVIEW.**
- Build uploaded + submitted with English + Portuguese What's New text.
- Subscription: Langly Premium $8.99/month (USA), R$ 26,90/month (Brazil).
- Waiting for Apple review.

### Monetization — Langly Premium Subscription
- **Subscription:** `com.langly.app.premium.monthly` (Apple product ID: `6799106330`)
- **Price:** USA **$8.99/month** | Brazil **R$ 26,90/month**
- **Group:** "Langly Premium" (`22293861`)
- **Code status:** IAPManager, ModuleRouter, MainMenuView (PaywallView), SettingsView all updated
- **Build:** Passed strict concurrency + warnings-as-errors

## What Was Accomplished (Aug 21 session)
- Resolved App Store Connect Portuguese (Brazil) "What's New" required field error
- Filled in both English and Portuguese What's New text on version 1.1
- Successfully submitted Langly PT-BR v1.1 for App Store review
- All changes committed + local backup created

## What Was Accomplished (Previous Sessions)
- Subscription code rewritten: one-time IAPs → auto-renewable Langly Premium
- PaywallView added inside MainMenuView.swift (green gradient, gold diamond, 4 benefits, live StoreKit price)
- Locked modules route to paywall via fullScreenCover
- SettingsView: "Como Usar" section + support email
- AppStoreMetadata.md updated to subscription model
- Langly_Overview.md, SUBMISSION_CHECKLIST.md updated
- App Store Upload — English (com.langly.app) ✅ READY_FOR_SALE
- App Store Upload — PT-BR (com.langly.app.pt) v1.1 — SUBMITTED FOR REVIEW

## Key Decisions
- English and PT-BR are completely separate Xcode projects in separate folders
- Privacy policy hosted at: https://moviecolor.github.io/langly-app/
- Pricing: Free (7-day trial) + Langly Premium $8.99/month
- Single subscription unlocks all modules (no per-module IAPs)
- PaywallView lives inside MainMenuView.swift (avoids pbxproj edits)

## Configuration
- Developer: Ryan Wuckert (Team ID: DW62VTMN2Z, Apple ID: Rynow@mac.com)
- ASC IDs: Langly `6794917761`, LanglyPT `6794930762`, subscription `6799106330`, group `22293861`
- ASC key: `/Users/mo-ry/.appstoreconnect/keys/AuthKey_87CV539PA4.p8`

## Next Steps / Pending
1. Wait for Apple review of PT-BR v1.1
2. If approved: Langly Premium subscription goes live in Brazil
3. Capture paywall screenshots for ASC subscription review (may still be needed)
4. If rejected: check resolution center for details + fix
5. Consider adding same subscription to EN app (currently free 1.0)

## How to Resume
> "Langly PT-BR v1.1 submitted for App Store review. EN v1.0 live. Waiting on Apple. Subscription code complete in both repos."
