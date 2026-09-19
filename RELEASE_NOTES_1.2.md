# Langly — Release Notes (v1.2)

**Version (proposed):** 1.2 — build 1 (first submit)
**Basis:** This is the feature update on top of the EN 1.1 (build 2) LIVE baseline.
**Rationale for 1.2 over 1.1:** App Store rule — a user-facing update MUST be a higher
market version than the LIVE one. 1.1 is live → this ships as 1.2.
**Anchor truth ref:** master `aac2b6b` = "EN 1.1 (2) LIVE, PT no live app" (untouched).

---

## What's New in This Version (EN — App Store Connect "What's New" field)

Langly just became truly bilingual.

- **New bilingual onboarding** — a clean 2-card picker asks what language you speak up
  front, so Langly meets you in your language from the very first screen.
- **Full Brazilian Portuguese (pt-BR)** — every menu, module, setting, stat and screen
  text now has a polished Portuguese translation. Pick Portuguese at onboarding and the
  whole app flips to PT-BR instantly. Switch back to English any time in Settings.
- **Language-aware translation direction** — when you tell Langly you speak Portuguese,
  it automatically starts translating *from* Portuguese *into* the language you're
  learning, and uses voices tuned to the right direction. No more reverse-word guessing.
- **Your choice, remembered** — the home language you pick persists across launches and
  drives every screen. Nothing to reconfigure.

**This version's chrome layer ships both EN and PT-BR in one binary** — one download,
two fully-translated experiences, chosen by the person holding the phone.

---

## O que há de novo nesta versão (PT-BR — texto "O que há de novo" no App Store Connect)

O Langly acabou de se tornar verdadeiramente bilíngue.

- **Novo onboarding bilíngue** — um seletor simples de 2 cartões pergunta qual idioma você
  fala logo no início; o Langly fala a sua língua desde a primeira tela.
- **Português do Brasil completo (pt-BR)** — todos os menus, módulos, configurações,
  estatísticas e textos de tela agora têm tradução em português. Escolha Português no
  onboarding e o app inteiro muda para pt-BR na hora. Volte para o Inglês a qualquer
  momento em Configurações.
- **Direção de tradução inteligente** — ao dizer que você fala Português, o Langly começa
  automaticamente a traduzir *do* Português *para* o idioma que você está aprendendo, com
  vozes ajustadas para a direção certa. Chega de adivinhar palavras ao contrário.
- **Sua escolha, lembrada** — o idioma de origem escolhido fica salvo entre lançamentos e
  controla todas as telas. Nada de reconfigurar.

**A camada bilíngue desta versão entrega EN e PT-BR num único build** — um download, duas
experiências totalmente traduzidas, escolhidas por quem segura o telefone.

---

## Technical / Store metadata (for the submitter, not user-facing)

| Field | Value |
|-------|-------|
| MARKETING_VERSION (proposed) | 1.2 |
| CURRENT_PROJECT_VERSION (build) | 1 |
| CFBundleShortVersionString | 1.2 |
| CFBundleVersion | 1 |
| Localizations shipped in binary | en, pt-BR |
| Base live anchor (MAY NOT MOVE) | master `aac2b6b` |
| Feature branch (this work lives here) | `feat/langly-fixes-1-6` |
| Underlying code truth | Phase A (bilingual picker + direction) + Phase B (PT/EN chrome layer + tests), both green |

## Proposed "Promotional Text" (App Store Connect, <170 chars)

EN: "One download, two languages — Langly now speaks English AND Brazilian Portuguese,
starting from your very first screen."
PT: "Um download, dois idiomas — o Langly agora fala Inglês E Português do Brasil, desde
a sua primeira tela."
