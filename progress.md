# Progress Log

## 2026-08-08 (restored from backup)
- [x] Subscription code rewritten: one-time IAPs → Langly Premium auto-renewable
- [x] IAPManager.swift — `isPremiumActive` from `Transaction.currentEntitlements`
- [x] ModuleRouter.swift — modules 2–4 gate on single premium entitlement
- [x] MainMenuView.swift — PaywallView added (green gradient, gold diamond, 4 benefits, live StoreKit price)
- [x] SettingsView.swift — "Como Usar" section + support email
- [x] AppStoreMetadata.md — $6.99 one-time → $8.99/month subscription
- [x] Build passed (strict concurrency + warnings-as-errors)
- [x] All 5 files restored from backup → live project
- [x] Langly_Overview.md updated (pricing table, business model)
- [x] SUBMISSION_CHECKLIST.md updated (IAP → subscription)
- [x] SESSION_HANDOFF.md updated

## Pending
- [ ] StoreKit Configuration file for simulator testing
- [ ] Paywall screenshots for ASC review
- [ ] ASC review metadata (MISSING_METADATA → READY_TO_SUBMIT)
- [ ] Upload build 1.1 + submit
- [ ] Fix LanglyPT REJECTED 1.0
- [ ] Privacy policy URL in ASC (both apps)

## 2026-07-26
- [x] Fixed iPad multitasking orientation validation
- [x] Archived + uploaded English version to App Store Connect ✅
- [x] Archived + uploaded PT-BR version to App Store Connect ✅
- [x] Security/memory scan passed
- [x] Git commit + push to github (1b3d096)
