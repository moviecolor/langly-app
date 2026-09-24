# Langly Release Ledger

Source of truth for every build shipped to App Store Connect. If a build number isn't
here, it didn't happen. Snapshots live in `RELEASES/` (gitignored, local-only).

| Date | Version | Build | ASC Build ID | Notes | Source commit |
|------|---------|-------|--------------|-------|---------------|
| 2026-09-24 | 1.2 | 3 | `8800045f-a5a6-42e5-a223-8d39996868ee` | Background-audio fix: UIBackgroundModes=[audio] added to Info.plist (was silently missing) | `fix/l1.2-phone-bugs` |
| 2026-09-19 | 1.2 | 2 | `d882019a-46c5-4027-83c5-88aff627e3d8` | Direction fixes (PT→EN word order, Match Madness columns, audio + screen sleep) | `fix/l1.2-phone-bugs` |

## Historical (pre-ledger, reconstructed from ASC)

| Date | Version | Build | ASC Build ID | Notes |
|------|---------|-------|--------------|-------|
| 2026-09-19 | 1.2 | 1 | `0537c4c8-9c72-4533-9fb8-63ea2414f582` | Initial 1.2 (bilingual onboarding, Premium, TestFlight) |