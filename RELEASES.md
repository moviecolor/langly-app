# Langly Release Ledger

Source of truth for every build shipped to App Store Connect. If a build number isn't
here, it didn't happen. Snapshots live in `RELEASES/` (gitignored, local-only).

| Date | Version | Build | ASC Build ID | Notes | Source commit |
|------|---------|-------|--------------|-------|---------------|
| 2026-09-24 | 1.2 | 4 | `4b530a1d-abb6-4b0b-97e3-5783cb494538` | **Langly Premium LIVE on TestFlight** — product ID `com.langly.app.premium.monthly.2` (old V1 ID tombstoned); ASC subscription `6815736929` fully configured, READY_TO_SUBMIT (175 territories, USA $8.99/BRA R$26.90, $2.99 US intro, localizations, review screenshot, availability). Changelog headlines Premium. Attached to Langly Internal. THE build to submit when testers finish v3. | `fix/l1.2-phone-bugs` |
| 2026-09-24 | 1.2 | 3 | `8800045f-a5a6-42e5-a223-8d39996868ee` | Background-audio fix: UIBackgroundModes=[audio] added to Info.plist (was silently missing). **Audio-on-screen-lock CONFIRMED WORKING on device 2026-09-24.** ⚠️ References DEAD product ID — no paywall/product for testers. | `fix/l1.2-phone-bugs` |
| 2026-09-24 | 1.2 | 3 | `8800045f-a5a6-42e5-a223-8d39996868ee` | Screenshots inherited from 1.1 (all COMPLETE); What's New corrected to direction+audio fixes (was stale "Premium subscription" text); 1.2 version object created on ASC (PREPARE_FOR_SUBMISSION); build attached to Langly Internal group | `fix/l1.2-phone-bugs` |
| 2026-09-19 | 1.2 | 2 | `d882019a-46c5-4027-83c5-88aff627e3d8` | Direction fixes (PT→EN word order, Match Madness columns, audio + screen sleep) | `fix/l1.2-phone-bugs` |

## Historical (pre-ledger, reconstructed from ASC)

| Date | Version | Build | ASC Build ID | Notes |
|------|---------|-------|--------------|-------|
| 2026-09-19 | 1.2 | 1 | `0537c4c8-9c72-4533-9fb8-63ea2414f582` | Initial 1.2 (bilingual onboarding, Premium, TestFlight) |