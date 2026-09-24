#!/usr/bin/env python3
"""Langly Premium subscription on App Store Connect — setup guide (2026-09-24).

This file is now a RECORD of what actually worked, because the raw ASC API
fails for subscriptions with weird legacy state. The WORKING path is the
`asccli` CLI (brew install asccli, `asc auth login`):

  EXPORT these (or use `asc auth login` once — it persists):
    ASC_API_KEY_ID=87CV539PA4
    ASC_API_ISSUER_ID=69a6de78-dca8-47e3-e053-5b8c7c11a4d1
    ASC_API_KEY_FILE=$HOME/.appstoreconnect/asc_key.p8  (symlink/copy of AuthKey key)

  LONG STORY (what happened, keep this for the next time):
  1. The ORIGINAL subscription com.langly.app.premium.monthly (ASC id 6799106330)
     was created via the DEPRECATED V1 inAppPurchases API. It was stuck in
     MISSING_METADATA: web UI would error on price editing, and modern API
     calls returned 409/422/405 (plan-type conflicts, no plan availabilities,
     UPFRONT tier-0 prices with no way to set real pricing).
  2. FIX: DELETE the broken subscription (DELETE /v1/subscriptions/6799106330 →
     204) and recreate via modern POST /v1/subscriptions (201) with SAME group
     (22293861). Apple TOMBSTONES deleted product IDs, so the new one took
     product id com.langly.app.premium.monthly.2 — the app's
     IAPManager.premiumMonthlyID was updated to match (+ a doc note).
  3. NEW subscription: ASC id 6815736929, state == READY_TO_SUBMIT.

  THE WORKING SETUP (all via asccli — verified 2026-09-24):
    SUB=6815736929  GROUP=22293861  APP=6794917761

    1) Localizations (sub-level, max description 55 chars!):
       asc subscription-localizations create --subscription-id $SUB \
           --locale en-US --name "Langly Premium" \
           --description "Unlimited word blocks plus all future modules."
       asc subscription-localizations create --subscription-id $SUB \
           --locale pt-BR --name "Langly Premium" \
           --description "Blocos ilimitados e todos os módulos futuros."

    2) Prices — FIRST PRICE must go through PATCH inline (set-batch), NOT post:
       Get the price-point IDs for your anchor price:
         asc subscriptions price-points list --subscription-id $SUB --territory USA
         # $8.99 = p=10114 (NOT the legacy "10093"), R$26.90 = p=10105
       Set USA+BRA to anchor:
         asc subscriptions prices set-batch --subscription-id $SUB \
             --price "USA=<pp 8.99>" --price "BRA=<pp 26.90>"
       Then equalize to ALL territories (required! submit 409s without it):
         asc subscription-equalizations list --price-point-id "<pp 8.99>" --limit 200
         # collect per-territory price point ids, then:
         asc subscriptions prices set-batch --subscription-id $SUB \
             --price "AFG=<pp>" --price "AGO=<pp>" ...  # all 174
       Finally RESTORE any manual overrides (equalize overwrites BRA):
         asc subscriptions prices set --subscription-id $SUB \
             --territory BRA --price-point-id "<pp 26.90>"

    3) Availability (MISSING this = stuck in MISSING_METADATA!):
       asc subscription-availability create --subscription-id $SUB \
           --available-in-new-territories --territory USA --territory BRA ...

    4) Intro offer $2.99 first month (PAY_UP_FRONT, NOT free trial — the 7-day
       full access is handled app-side via AppSettings.installDate):
       asc subscription-offers create --subscription-id $SUB \
           --duration ONE_MONTH --mode PAY_UP_FRONT --periods 1 \
           --territory USA --price-point-id "<pp 2.99>"

    5) Review screenshot (REQUIRED for READY_TO_SUBMIT):
       asc subscription-review-screenshot upload --subscription-id $SUB \
           --file "AppStoreScreenshots/6.7in/02_Vocabulary.png"

    6) Verify: asc subscriptions list --group-id $GROUP  → state READY_TO_SUBMIT
       Then submit with the app build:
         asc subscriptions submit --subscription-id $SUB

  WHY NOT THE RAW PYTHON FILE (previous version of this script):
  - POST /v1/subscriptionPrices      → 409 UNSUPPORTED_TERRITORY (legacy state)
  - POST /v1/subscriptionPlanAvailabilities → 409 (legacy UPFRONT plan conflict)
  - PATCH /v1/subscriptions/{id} inline price → 422 (wrong — inline resources
    live in the `included` array for setPrices, which set-batch implements)
  - POST /subscriptions/{id}/introductoryOffers → 405 (wrong route)
  The asccli SDKSubscriptionPriceRepository (setPrices) is the source of truth
  for the CORRECT shapes.
"""