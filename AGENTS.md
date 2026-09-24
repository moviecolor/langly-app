# Agent workflow rules

## 📖 READ THIS FIRST — build/release knowledge base (do NOT skip)

**Before ANY build, test, TestFlight upload, App Store submission, or release task, READ these files:**

1. **`TESTFLIGHT_PLAYBOOK.md`** — THE canonical ship-playbook for this repo. Contains: the one-command release recipe (§1), credential locations (§3), the four 2026-09-19 release blockers + fixes (§2), store-asset checklist (§7), internal-beta-group trap (§8), and **the phantom iOS 26.3 simulator runtime trap + permanent resolver fix (§9)**.
2. **`SESSION_HANDOFF.md`** — current release state, last commits, immediate next actions, known-good build destinations. Update it after ANY release-affecting change.
3. **`RELEASES.md`** — release ledger (every build ever shipped + its ASC id).
4. **`SUBMISSION_CHECKLIST.md`** — everything that must be verified before submitting for App Review.

**Golden rule for simulator builds (learned twice: 2026-09-18 and 2026-09-24):**
- `scripts/xcbuild.sh` is the ONLY sanctioned build wrapper and it already embeds the real fix: it must NEVER export `CFFIXED_USER_HOME` or replace `HOME`, or xcodebuild loses ALL simulator destinations (see playbook §9). If someone "fixes" xcbuild.sh back with a sandbox HOME, simulator builds die instantly with "Unable to find a destination ... iOS 26.2 is not installed".
- `scripts/resolve_sim_destination.sh` is the ONLY sanctioned way to get an `-destination`. NEVER pass `platform=iOS Simulator,id=<udid>` directly, NEVER use `OS=26.3` — the 26.3 sims are phantom/unbuildable on this machine.
- Known-good destination verbatim: `platform=iOS Simulator,name=iPhone 16 Pro,OS=18.3.1`.
- If a build fails at destination resolution, do NOT invent a workaround — read playbook §9 first.

## ⚠️ CANONICAL VERSION RULE (do not contradict this)

**This repo (`LANGLY_PROJECT`) is the single source of truth for App Store code.**

| App | Bundle ID | Version | Status |
|---|---|---|---|
| Langly EN | `com.langly.app` | **1.1 (build 2)** | ✅ LIVE (READY_FOR_SALE) on App Store |
| LanglyPT BR | `com.langly.app.pt` | App Store v1.0 (build 6) — **REJECTED** · newest TestFlight binary is 1.1 (build 6) but was NEVER submitted as a 1.1 version | ❌ **NO live app** |

- Any fix/bug must be applied **here first**. `Langly_PORT_ENGLISH/` is an older mirror — do NOT edit it unless asked.
- **The live-code anchor commit is `560598f`** ("checkpoint — sync subscription code") = the code behind EN 1.1 (2): PaywallView, IAPManager, MainMenuView, SettingsView changes. Everything after (`dd45384`) is docs-only.
- Current model = **subscription** (PaywallView in MainMenuView.swift, StoreKit 2). EN is NOT the old free `$6.99` paid model.
- ⚠️ FOOTGUN: `project.yml` checked in as 1.0 (1) — the live build was versioned via pbxproj at 1.1 (2). Before any `xcodegen generate`, verify project.yml matches the target version, else the pbxproj version silently regresses to 1.0 (1).
- Before any release: verify against App Store Connect (`ruby /tmp/langly_ver.rb` style ASC API query — see Fraturday runbook §9) and update this table + SESSION_HANDOFF.md so the next session always knows exactly what is live.

## Task workflow

- Use `scripts/task.sh` as the single task entrypoint.
- Use `AGENT_NAME` when claiming and completing work.
- Keep committed task backlog in `tasks/TASKS.md`.
- Put deeper task notes in `tasks/details/<id>.md`.

Task workflow commands:
- `scripts/task.sh plan <slug> --scope "..." --files "..." --note "..."`
- `AGENT_NAME=CODEX scripts/task.sh claim <number|id> --note "Starting work"`
- `AGENT_NAME=CODEX scripts/task.sh done <number|id> --note "Finished + build/test status"`
- `scripts/task.sh summary --last-24h`

## ⚠️ RELEASE/BUILD TASK GATE (mandatory, all agents + subagents)

If the task touches **any** of: builds, tests, TestFlight, App Store Connect, submissions, screenshots, version bumps, provisioning, or the playbook files — **do NOT start coding**. First:

1. Read `TESTFLIGHT_PLAYBOOK.md` (esp. §1 recipe, §3 credentials, §7 store assets, §8 beta groups, §9 build environment — xcbuild.sh HOME trap + resolver).
2. Read `SESSION_HANDOFF.md`, `RELEASES.md`, `SUBMISSION_CHECKLIST.md`.
3. Build/test via `make build` / `make test` (or `scripts/xcbuild.sh`), with destination from `scripts/resolve_sim_destination.sh` (NEVER a hardcoded `id=` UDID; never `OS=26.3`; NEVER re-add CFFIXED_USER_HOME/HOME to xcbuild.sh).
4. After finishing: verify against ASC (see playbook §1/§4), then update `SESSION_HANDOFF.md` + `RELEASES.md`, and commit with a valid `fix(ios):` / `feat(ios):` / `docs(release):` scope.

Failing to read the playbook before a release task is how this repo burns half a session on problems that are already documented.
