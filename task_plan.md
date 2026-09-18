# Langly — Bilingual Pivot (Option A: ONE app, both stores)

**Mission:** Turn the existing single EN↔PT Langly app into the one bilingual
app that serves BOTH audiences — an English speaker (UI English, learn PT,
EN→PT translation) and a Brazilian speaker (UI Português, learn English,
PT→EN translation) — distributed as ONE bundle `com.langly.app` available
simultaneously in US/Canada + Brazil storefronts with regional pricing.
Eliminates **Guideline 4.3(a)** permanently (no second app = no duplication).

**Status:** PLANNED — no code written yet (awaiting GO)

---

## Locked decisions
- ✅ **Locked:** ONE app (com.langly.app), same name "Langly" in both storefronts
- ✅ **Locked:** Regional pricing: $8.99 US · R$ 26,90 BR (per-storefront, same bundle)
- ✅ **Locked:** First-launch 2-card picker: "🇺🇸 I speak English → learn PT" /
  "🇧🇷 Eu falo Português → aprenda Inglês"
- ✅ **Locked:** `com.langly.app.pt` bundle retired — EN app untouched, not re-submitted
- ✅ **Locked:** 6 UX fixes + IAP hardening + translator/audio bugfixes stay on
  `feat/langly-fixes-1-6` — NOT touched by this pivot
- ✅ **Locked:** Onboarding `selectedLanguage` picker REPURPOSED → 2-card chooser
- ✅ **Locked:** Translator `source`/`target` becomes direction-aware (currently
  hardcoded en→pt at TranslationSessionView.swift:49-50)

---

## Phase 1 — UI Language + Direction (the "who are you" gate)
- [ ] `OnboardingView`: replace 8-language chips with 2 big cards, persists
      homeLanguage (UI) + targetLanguage (learning direction) into AppSettings
- [ ] `AppSettings`: ensure `homeLanguage`/`targetLanguage`/`uiLanguage` fields
      exist + survive migration (SwiftData)
- [ ] Settings: allow changing direction later (not locked at onboarding)

## Phase 2 — Text layers (the "PT UI" work)
- [ ] Add lightweight PT translations for menu/settings/paywall/onboarding
      strings (EN + PT string pairs; no full i18n framework — keep it small)
- [ ] UI renders in homeLanguage — English default, Português when Brazilian picks it

## Phase 3 — Translator direction flip
- [ ] `TranslatorManager` / `TranslationSessionProvider`: source/target from
      settings instead of hardcoded en→pt
- [ ] Keep Apple→MyMemory→Google racing + offline fallback behavior identical

## Phase 4 — Voice direction
- [ ] Reverse direction: pick best **en-US** voice (current code only sorts best
      pt-BR). Both directions play correct language voice.

---

## Testing / release (unchanged fast path)
- [ ] Bump to **1.2 (build 3)** in project.yml (+ pbxproj sync — xcodegen footgun)
- [ ] Archive (iOS device, strict) → upload → **TestFlight internal** (you test ~30 min)
- [ ] Teacher = internal tester for zero-gate, OR external (one-time beta review)
- [ ] Submit 1.2 for App Store release once verified

## Files touched (planned)
- `Sources/Views/OnboardingView.swift` (picker → 2 cards)
- `Sources/Services/TranslatorManager.swift` + `TranslationSessionProvider.swift` (direction)
- `Sources/Services/AudioEngine.swift` + `AudioModeViewModel.swift` (en-US voice)
- `Sources/Models/AppSettings.swift` (language fields)
- New: PT strings layer (EN/PT pairs)

## Not touched (guaranteed)
- IAPManager, IAP timeout, local-first seeding
- NetworkMonitor, connectivity-aware translator
- Block editor, background audio, all 6 UX fixes
- Tests (AudioOrdering, Vocabulary)

## Edge cases
- First-launch before migration: picker must not re-show once `hasCompletedOnboarding`
- Direction switch later: translation + voice + UI all flip consistently
- Offline: picker + seeding still work (local-first — no StoreKit gate)
