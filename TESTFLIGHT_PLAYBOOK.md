# Langly — TestFlight / App Store Upload Playbook

**Last updated:** 2026-09-19 — Langly **1.2 (1)** pushed to TestFlight successfully
**For:** anyone (or any LLM) who needs to ship a Langly build to TestFlight or App Store Connect without re-discovering the traps below.

---

## 1. The one-command recipe (verified working)

From `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT`:

```bash
bundle exec fastlane beta
```

The `beta` lane (in `fastlane/Fastfile`) does:
1. `build_app` — Release archive + App Store export, signing with the **Distribution identity**
2. `upload_to_testflight` — upload via **ASC API key**, set changelog, distribute to internal testers

**Before the first run on any machine** you need the four pieces in §3. After that, `bundle exec fastlane beta` is the whole job.

---

## 2. What went wrong on 2026-09-19 (four blockers that stalled 1.2 for over a session) — and the fixes

| # | Symptom | Root cause | Fix (one-time) | Prevents by |
|---|---------|-----------|----------------|-------------|
| 1 | `CSSMERR_TP_CERT_EXPIRED` / "No Account for Team" / code-signing failed | All **3 Distribution certs** in the login keychain were **expired**; only the Development cert was valid | Minted a fresh Distribution cert from the **ASC API key** (no portal clicks): `bundle exec fastlane cert --api_key_path ~/.appstoreconnect/keys/fastlane_api_key.json --team_id DW62VTMN2Z --output_path build/certs` → new cert `S6B546669G`, auto-imported to keychain | Automatically creates a new cert the moment none is valid — you never hand-roll certs again |
| 2 | "No existing profiles found… creating a new one" was NOT auto-happening before; upload also failed with expired signing | No **Distribution provisioning profile** for `com.langly.app` matched the valid cert | Generated + installed one via: `bundle exec fastlane sigh --api_key_path ~/.appstoreconnect/keys/fastlane_api_key.json --team_id DW62VTMN2Z --app_identifier com.langly.app --output_path build/profiles` → `AppStore_com.langly.app.mobileprovision` installed into `~/Library/MobileDevice/Provisioning Profiles/` | Profile is created/refreshed from the API key too — no portal, no dead Xcode-login path |
| 3 | `No Account for Team "69A6DE78DA"` + `No profiles for 'com.langly.app' were found` | **`DEVELOPMENT_TEAM = 69A6DE78DA`** in `project.pbxproj` — that's the **issuer ID**, not the team ID! Real team = **`DW62VTMN2Z`** | `sed s/69A6DE78DA/DW62VTMN2Z/g` on `Langly.xcodeproj/project.pbxproj` **and** added `DEVELOPMENT_TEAM: DW62VTMN2Z` to `project.yml` | project.yml is the source of truth; regeneration can't reintroduce the wrong ID |
| 4 | altool `Validation failed (409)`: first `UIInterfaceOrientationPortrait` only → iPad multitasking rejection; then flipping device family to iPhone-only → "must continue to support all devices" rejection | `TARGETED_DEVICE_FAMILY = 1,2` (iPhone + iPad — previous live version already supports iPad, so you **cannot** drop it) but only portrait was declared in `INFOPLIST_KEY_UISupportedInterfaceOrientations` | Keep `TARGETED_DEVICE_FAMILY = "1,2"` **and** declare **all four** orientations in both `project.pbxproj` and `project.yml` | The upload validation passes instead of ping-ponging between the two Apple errors |

### Secret/leak gotcha
- The ASC private key (`AuthKey_87CV539PA4.p8`) was copied inside the repo as `.appstoreconnect/` — **never commit it**. Canonical location is `~/.appstoreconnect/keys/` (see §3). `.appstoreconnect/` is now in `.gitignore`, and `fastlane/Fastfile` references the key via `File.expand_path("~/.appstoreconnect/keys/...")`.

---

## 3. The credentials/config that make the recipe work (all local — nothing to do per-build)

| Piece | Value / location |
|---|---|
| ASC API key file | `~/.appstoreconnect/keys/AuthKey_87CV539PA4.p8` |
| ASC API key JSON | `~/.appstoreconnect/keys/fastlane_api_key.json` (key_id `87CV539PA4`, issuer `69a6de78-dca8-47e3-e053-5b8c7c11a4d1`, **`in_house: false`** — add this if fastlane says "Cannot determine if team is App Store or Enterprise") |
| Team ID | **`DW62VTMN2Z`** (NOT `69A6DE78DA` — that's the issuer ID) |
| Bundle ID | `com.langly.app` |
| App Store Connect App ID | `6794917761` |
| Distribution identity | `Apple Distribution: Ryan Wuckert (DW62VTMN2Z)` (cert `S6B546669G` minted 2026-09-19; ~renew annually via `fastlane cert`) |
| Provisioning profile | App Store profile for `com.langly.app` installed locally (regen via `fastlane sigh` if ever missing) |
| fastlane | `bundle install` inside project (Gemfile pins `fastlane ~> 2.237`; lock currently `2.240.1`). Run with `bundle exec fastlane`. |

**Verification commands:**
- `security find-identity -v -p codesigning` → must show a VALID `Apple Distribution: Ryan Wuckert (DW62VTMN2Z)` (fruit of the fresh cert). If it only shows Development, re-run `fastlane cert`.
- `ls ~/Library/MobileDevice/Provisioning\ Profiles/` → must contain the App Store `.mobileprovision`.

---

## 4. Once tested: push 1.2 to App Review (instant, API-driven)

The 1.2 build exists in TestFlight, but **App Store Connect has NO appStoreVersion "1.2" yet** (only 1.0/1.1 are live). To submit for review:

```bash
python3 scripts/submit_release.py --dry-run   # preview (safe)
python3 scripts/submit_release.py --yes       # create 1.2 version → attach build → set What's New (en+pt) → submit
```

What the script does (verified against ASC API):
1. Creates `appStoreVersion` 1.2 (POST `/v1/appStoreVersions`)
2. Attaches build `0537c4c8-9c72-4533-9fb8-63ea2414f582` (1.2 (1))
3. Upserts `appStoreVersionLocalizations` en-US + pt-BR with What's New (text from `RELEASE_NOTES_LANGLY_1.2.md`)
4. Creates `appStoreReviewDetail` for 1.2 (copies values from the 1.1 version) if missing
5. Submits via `POST /v1/appStoreVersionSubmissions`

If that ever 403s, create/submit via App Store Connect web UI: **App Store → Langly → iOS App → 1.2 → Submit for Review** (build 1 attached, What's New already documented in `RELEASE_NOTES_LANGLY_1.2.md`).

---

## 5. Version bumps (how 1.2 became 1.2 (1))

- `project.yml` sets `MARKETING_VERSION` (currently `1.2`) and `CURRENT_PROJECT_VERSION` (currently `1`).
- `GENERATE_INFOPLIST_FILE: YES` + `INFOPLIST_KEY_CFBundleShortVersionString: $(MARKETING_VERSION)` — the build gets version from build settings, so bump by editing `project.yml` (or running `xcodegen`), then `bundle exec fastlane beta`.
- Fastfile's `beta` changelog comes from `EN_NEWS` / `PT_NEWS` constants.

---

## 6. After upload: getting it to testers

- **Internal testers** (your Apple account — e.g. Ryan's own iPhone): happens automatically via `upload_to_testflight` (this run: "Successfully distributed build to Internal testers").
- **External testers** (e.g. the Portuguese teacher): add them in App Store Connect **Beta → External testing** or via the ASC API key:
  1. Create (or reuse) an external beta group, e.g. "Langly Beta Testers".
  2. Add the tester's **Apple ID email** to the group and attach build 1.2 (1).
  3. Apple sends the TestFlight invite email. The tester installs the **TestFlight app from the App Store**, accepts the invite, and can then install Langly.
- Note: the first external-group submission goes through **Beta App Review** (Apple reviews ~1–2 days). Internal distribution does not.