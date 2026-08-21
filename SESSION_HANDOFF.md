# SESSION_HANDOFF.md
**Date:** 2026-08-08 (restored from backup)
**Branch:** master
**Remote:** github.com/moviecolor/langly-app.git

## Current State
**BOTH versions uploaded to App Store Connect.** English (`com.langly.app`) and PT-BR (`com.langly.app.pt`) are both processing. Subscription code has been restored from the August 8 backup into the live project.

### Monetization — Langly Premium Subscription
- **Subscription:** `com.langly.app.premium.monthly` (Apple product ID: `6799106330`)
- **Price:** USA **$8.99/month** | Brazil **R$ 26,90/month**
- **Group:** "Langly Premium" (`22293861`)
- **Code status:** IAPManager, ModuleRouter, MainMenuView (PaywallView), SettingsView all updated
- **ASC status:** MISSING_METADATA — needs review screenshots + notes before submit
- **Build:** Passed strict concurrency + warnings-as-errors

## What Was Accomplished (Aug 8 session + today's restore)
- Subscription code rewritten: one-time IAPs → auto-renewable Langly Premium
- PaywallView added inside MainMenuView.swift (green gradient, gold diamond, 4 benefits, live StoreKit price)
- Locked modules route to paywall via fullScreenCover
- SettingsView: "Como Usar" section + support email
- AppStoreMetadata.md updated to subscription model
- Langly_Overview.md, SUBMISSION_CHECKLIST.md updated
- All 5 files restored from `_BACKUP_LANGLY_PORT_ENGLISH_2026-08-08_082646` → live project

## What Was Accomplished (Previous Sessions)
- App Store Upload — English (com.langly.app) ✅
- App Store Upload — PT-BR (com.langly.app.pt) ✅ (REJECTED — separate fix pending)
- Security scan passed ✅
- Subscription code rewritten + build passed ✅

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
- ExportOptions.plist at `/tmp/ExportOptions.plist` (method: app-store-connect)

## Next Steps / Pending
1. Add StoreKit Configuration file for simulator testing (paywall shows real price)
2. Capture paywall screenshots for ASC subscription review
3. Complete ASC review metadata (MISSING_METADATA → READY_TO_SUBMIT)
4. Upload build 1.1 + submit for review
5. Fix LanglyPT REJECTED 1.0 (separate)
6. If appeal passes → apply same subscription to PT build

## How to Resume
> "Continue from session-log. Langly Premium subscription code is live in EN project. Need StoreKit config, paywall screenshots, ASC metadata, then upload 1.1."
