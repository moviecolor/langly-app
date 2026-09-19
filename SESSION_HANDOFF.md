# SESSION_HANDOFF.md
**Date:** 2026-09-19 (SAVE ALL NOW)
**Branch:** master-1.2
**Remotes:** `github` = moviecolor/langly-app.git · `backup` = /Volumes/THUNDER/OpenCode BACKUP of 16tb/LANGLY_PROJECT

## Current State — Langly 1.2 (1) is IN TESTFLIGHT ✅
- Build **1.2 (1)** (`0537c4c8-9c72-4533-9fb8-63ea2414f582`) uploaded, processed, VALID.
- Internal beta group **"Langly Internal"** (`5faeb740-7617-4db2-ac81-75c7327057ad`) exists with build attached; tester **Ryan Wuckert (rynow@mac.com)** added → **visible + installable in TestFlight** (confirmed working by user).
- App Store versions: **1.0** and **1.1** are READY_FOR_SALE (live). **1.2 does NOT exist as an App Store version yet** — must be created before App Review submission.

## Signed/shipped today (one-time fixes, no longer blockers)
- Fresh **Apple Distribution cert** `S6B546669G` minted via `fastlane cert` (old certs expired) + App Store provisioning profile via `fastlane sigh` → both installed locally.
- Fixed `DEVELOPMENT_TEAM` in pbxproj + project.yml: `69A6DE78DA` (wrong, issuer ID) → **`DW62VTMN2Z`**.
- Fixed orientations: all 4 declared (iPad multitasking) — device family stays `"1,2"`.
- Fastfile `beta` lane wires ASC API key (`87CV539PA4`) into upload.
- `.appstoreconnect/` (private key) gitignored + removed from repo.

## How to resume / push 1.2 to App Review (ONE command once tested)
```bash
cd /Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT
python3 scripts/submit_release.py --dry-run   # preview
python3 scripts/submit_release.py --yes       # actually create version 1.2, attach build, set What's New, submit
```
Script: creates appStoreVersion 1.2, attaches build, upserts en-US + pt-BR What's New (from RELEASE_NOTES_LANGLY_1.2.md), copies review detail from 1.1, submits via `appStoreVersionSubmissions`.

## Credentials (all local, never push)
- ASC API: `~/.appstoreconnect/keys/AuthKey_87CV539PA4.p8` + `fastlane_api_key.json` (key `87CV539PA4`, issuer `69a6de78-dca8-47e3-e053-5b8c7c11a4d1`, `in_house: false`).
- Team ID `DW62VTMN2Z` · Apple ID `Rynow@mac.com` · ASC app `6794917761` · bundle `com.langly.app`.

## References
- `TESTFLIGHT_PLAYBOOK.md` (root) — full TestFlight/upload playbook + 2026-09-19 blocker fixes.
- Global index: `~/.config/opencode/PLAYBOOKS.md` (points everywhere).
- Teacher proposal draft: `Marketing the app/Teacher Proposal - Langly beta WhatsApp draft.odt`.
- Pending: teacher's Apple ID email → external beta group + Beta App Review invite (~1–2 days).

## Commit trail today
`579367f` fix(release): Langly 1.2 (1) ships to TestFlight · `26b2449` docs(release): TESTFLIGHT_PLAYBOOK · + this SAVE.