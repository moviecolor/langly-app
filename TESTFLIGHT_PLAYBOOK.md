# Langly — TestFlight / App Store Upload Playbook

**Last updated:** 2026-09-24 — Langly **1.2 (3)** pushed to TestFlight (incl. internal-group attachment fix, §8)
**For:** anyone (or any LLM) who needs to ship a Langly build to TestFlight or App Store Connect without re-discovering the traps below.

---

## 1. The one-command recipe (verified working)

From `/Volumes/16TB_LARGE_NVME/OpenCODE_Projects/LANGLY_PROJECT`:

```bash
bundle exec fastlane beta
```

The `beta` lane (in `fastlane/Fastfile`) does:
1. `build_app` — Release archive + App Store export, signing with the **Distribution identity**
2. `upload_to_testflight` — upload via **ASC API key**, set changelog, distribute to internal testers (via `groups: ["Langly Internal"]` — see §8 for why this param is mandatory)

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

- **Internal testers** (your Apple account — e.g. Ryan's own iPhone): builds are only visible if they're **attached to the beta group**. Since "Langly Internal" has `hasAccessToAllBuilds: false`, an uploaded build that is not explicitly linked to the group is **invisible to every tester** even though TestFlight says "Successfully distributed". The `beta` lane MUST pass `groups: ["Langly Internal"]` (see §8).
- **External testers** (e.g. the Portuguese teacher): add them in App Store Connect **Beta → External testing** or via the ASC API key:
  1. Create (or reuse) an external beta group, e.g. "Langly Beta Testers".
  2. Add the tester's **Apple ID email** to the group and attach build 1.2 (3) (any build — see §8 for why attachment must be explicit).
  3. Apple sends the TestFlight invite email. The tester installs the **TestFlight app from the App Store**, accepts the invite, and can then install Langly.
- Note: the first external-group submission goes through **Beta App Review** (Apple reviews ~1–2 days). Internal distribution does not.

---

## 7. Store assets — verify BEFORE pushing a build (the 2026-09-20 lesson)

On 2026-09-20, "The Key to Me" pushed **build 4** to TestFlight and later discovered the App Store **icon and screenshots weren't in place** — the icon hunt consumed a whole session, and the screenshot sets had to be created and uploaded *after* the build had already been pushed. **Do not relearn this. For ANY app, confirm the store assets exist in App Store Connect BEFORE (or at the same moment as) the first build push.**

### 7.1 App icon — iOS has NO web upload slot anymore

- **iOS App Store icons are taken from the binary** (the 1024×1024 marketing icon in the app's asset catalog). There is **no "App Icon" drag box in App Store Connect** for iOS apps — Apple removed it. If you don't see a slot, you're not missing it; the icon comes from the build itself.
- **Pre-push check:** make sure your asset catalog contains the full AppIcon set INCLUDING the 1024 marketing slot (`Assets.xcassets/AppIcon.appiconset` with `icon-1024.png` or equivalent, no alpha, RGB). Verify after building, before uploading:
  ```bash
  unzip -p App.ipa "Payload/App.app/Assets.car" > /tmp/Assets.car
  assetutil --info /tmp/Assets.car | grep -i marketing   # must show a 1024x1024 rendition
  ```
- **Changing the icon post-push requires a new build** — Apple's docs: "If you want to change your app icon after publishing, you must create and upload a new version of your app." That is exactly the trap to avoid.

### 7.2 Screenshots — upload with the build, not after

- Screenshot sets are created in ASC under **App Store → <App> → iOS App → <version> → 1.0**, and are **display-size-typed**. Matching the wrong type = permanent FAILED states that need delete + recreate.
- **Valid sets (2026 API):** iPhone 6.7" class = `APP_IPHONE_67` (1320×2868); iPad Pro 12.9" class = `APP_IPAD_PRO_129` (2048×2732). **There is no 13"-native slot** — resize 13" iPad captures (2064×2752) down to 2048×2732 or Apple rejects with `IMAGE_INCORRECT_DIMENSIONS`.
- **API upload must send the `uploaded: true` flag** on the final checksum PATCH, or you get "Uploaded flag is not set!" and the asset stays `AWAITING_UPLOAD`.
- **Pre-push check:** after `fastlane beta`, poll each screenshot's `assetDeliveryState` — every slot must read **COMPLETE**, not `AWAITING_UPLOAD` / `FAILED`, before you tell anyone the build is ready.

### 7.3 The fixed checklist (add to any "ship a build" SOP)

- [ ] 1024 marketing icon present in asset catalog, no alpha, RGB
- [ ] Icon set is included in **this** build (verify from the .ipa, not the source dir)
- [ ] Screenshot sets created for the display sizes you ship (iPhone AND iPad if Universal — iPad is **mandatory**)
- [ ] Screenshots uploaded AND every slot shows `COMPLETE`
- [ ] (If store submission is the goal, not just beta) version page has: build attached, description, keywords, promo, release notes, copyright, review notes, App Privacy, age rating, categories — done BEFORE pushing, so no re-push is needed later

---

## 8. Internal-test group attachment — the "Successfully distributed" lie (the 2026-09-24 lesson)

**Symptom:** the build uploads, ASC shows it VALID, fastlane prints "Successfully distributed build to Internal testers" — but the tester's TestFlight app never shows the new build (only an old one, or nothing).

**Root cause:** `upload_to_testflight` without a `groups:` parameter uploads the build to App Store Connect but does **not** attach it to any beta group. On this account, the internal group **"Langly Internal" has `hasAccessToAllBuilds: false`** (`GET /v1/betaGroups/{id}` → `attributes.hasAccessToAllBuilds`). With that flag off, a build that isn't explicitly linked to a group is **invisible to every tester in every group**, no matter the processing state. The fastlane "Successfully distributed" message refers to the *upload*, not to group distribution — it lies.

This silently bit Langly twice: 1.2 (2) and 1.2 (3) were both uploaded + VALID, but neither was attached to the group, so Ryan's phone only ever showed 1.2 (1) (which had been manually attached earlier).

**The one-command fix inside the lane** (already applied in `fastlane/Fastfile`):

```ruby
upload_to_testflight(
  api_key: api_key,
  changelog: EN_NEWS + "\n" + PT_NEWS,
  skip_waiting_for_build_processing: false,
  groups: ["Langly Internal"],   # <-- REQUIRED on this account
)
```

**Manual rescue (if a build was already pushed without the param):**

```python
# POST /v1/betaGroups/{GROUP_ID}/relationships/builds
# {"data": [{"type": "builds", "id": "{BUILD_ID}"}]}  → 204
```

**Post-push verification (never trust the fastlane message):**

```bash
# builds actually inside the group?
GET /v1/betaGroups/{GROUP_ID}/builds       # v3 must be listed
GET /v1/builds/{BUILD_ID}?include=betaGroups
# tester is installed (not INVITED)?
GET /v1/betaTesters/{TESTER_ID}            # attributes.state == "INSTALLED"
```

**Checklist addition for ANY app's build SOP (not just Langly):**

- [ ] `upload_to_testflight` passes `groups:` matching the app's internal group name
- [ ] After push, confirm the new build is listed under the group (`GET /v1/betaGroups/{id}/builds`)
- [ ] Confirm the tester's `betaTesterState` is `INSTALLED`, not `INVITED` (an unaccepted invite = still nothing on the phone)

---

## 9. iOS 26.3 phantom simulator runtimes — the local-build blocker (2026-09-18, re-hit 2026-09-24, FIXED IN `scripts/resolve_sim_destination.sh`)

**Symptom:** any local `xcodebuild`/`make build`/`make test` run for the simulator fails instantly with one of:

```
xcodebuild: error: Unable to find a device matching the provided destination specifier:
		{ platform:iOS Simulator, OS:26.3, name:iPhone 16 Pro }
Available destinations for the "Langly" scheme:
		{ platform:iOS Simulator, ..., OS:18.3.1, name:iPhone 16 Pro }
```

or

```
xcodebuild: error: Unable to find a destination matching the provided destination specifier:
	{ platform:iOS Simulator, id:3B70BB3B-... }
Ineligible destinations ... iOS 26.2 is not installed. Please download and install the platform from Xcode > Settings > Components.
```

The build never starts — zero compile errors, just this destination error.

**Root cause:** `xcrun simctl list devices -j` lists **phantom iOS 26.3 simulator runtimes** (26.3.1 — they exist in CoreSimulator as "available") that Xcode 26.3's iPhoneOS platform on this machine **cannot build against**. xcodebuild only ever accepts the **iOS 18.3.1** runtime for Langly's sim builds. The old auto-resolver (`scripts/resolve_sim_destination.sh`) compounded it two ways:
1. It emitted `platform=iOS Simulator,id=<udid>` — xcodebuild refuses the `id=` form here even when `xcodebuild -showdestinations` lists that exact UDID (duplicate same-name/arch entries across runtimes break matching).
2. It ranked candidate sims by **highest** runtime version, so it selected the always-unbuildable 26.3 device over the buildable 18.3 one.
3. (Third subtlety, 2026-09-24) even with `name=`+`OS=18.3`, xcodebuild matches the **full installed version string** (`18.3.1`), not the runtime key's truncated `18.3` — `OS=18.3` fails identically.

**The permanent fix (already in `scripts/resolve_sim_destination.sh`, verified 2026-09-24: BUILD SUCCEEDED + 12/12 tests green):**
- Always emit `platform=iOS Simulator,name=<name>,OS=<os>` — **never `id=`**.
- Source the **full** OS version from `xcrun simctl list runtimes -j` (`"version": "18.3.1"`), not the truncated device-runtime key.
- Rank by **lowest** available iOS runtime first (18.3.1 over 26.3.1), then newest iPhone model within that runtime. Booted-sim preference kept but still lowest-runtime-first.

**Known-good destination (use verbatim if the resolver is ever bypassed):**

```bash
-destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.3.1"
```

**Do NOT:** fix a similar symptom by manually pinning a UDID, by passing `OS=26.3`, or by "temporarily" editing the resolver per-run — that is exactly how this bit twice. Change the resolver once, run `bash -n scripts/resolve_sim_destination.sh`, re-run `make build`, and document any new fact here.