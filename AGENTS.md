# Agent workflow rules

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
