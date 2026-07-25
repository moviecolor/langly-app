# Langly — App Store Submission Checklist

## Pre-Submission (DO THIS FIRST)

### App Store Connect Setup
- [ ] Create Apple Developer account ($99/year) if not already done
- [ ] Create new app in App Store Connect
- [ ] Set app name: "Langly — AI Language Learning"
- [ ] Set subtitle: "Learn Languages Faster"
- [ ] Set primary category: Education
- [ ] Set secondary category: Reference
- [ ] Set price: $6.99
- [ ] Add app description (see AppStoreMetadata.md)
- [ ] Add keywords (see AppStoreMetadata.md)
- [ ] Upload app icon (1024×1024 PNG, no alpha, no rounded corners)

### IAP Products (in App Store Connect)
- [ ] Create "Common Sentences" IAP — $3.99, non-consumable
- [ ] Create "Pronunciation" IAP — $3.99, non-consumable
- [ ] Create "Q&A" IAP — $3.99, non-consumable
- [ ] Create "All Modules Bundle" IAP — $9.95, non-consumable
- [ ] Set product IDs to match code: `com.langly.app.commonsentences`, etc.

### Privacy & Legal
- [ ] Host PRIVACY_POLICY.md at a public URL (e.g., GitHub Pages, your site)
- [ ] Add privacy policy URL in App Store Connect
- [ ] Fill out App Privacy nutrition labels (Data Not Collected)
- [ ] Confirm PrivacyInfo.xcprivacy is in the build (already done ✅)
- [ ] Set export compliance: "No" for encryption (ITSAppUsesNonExemptEncryption: false)

### Screenshots (REQUIRED)
- [ ] iPhone 6.7" (1290×2796) — at least 3 screenshots, max 10
  - [ ] Main menu with module cards
  - [ ] Vocabulary learning screen
  - [ ] Audio playback screen
  - [ ] Score/progress screen
- [ ] iPhone 6.5" (1242×2688) — same screenshots, different crop
- [ ] iPad 12.9" (2048×2732) — optional but recommended

### Build
- [ ] Archive build: `xcodebuild archive` or Xcode → Product → Archive
- [ ] Upload to App Store Connect via Xcode Organizer
- [ ] Select uploaded build in App Store Connect version
- [ ] Ensure build passes Apple's automated review checks

## App Information
- [ ] Support URL — create a simple page or email
- [ ] Marketing URL — optional, your website
- [ ] App version: 1.0
- [ ] Copyright: © 2026 Langly App
- [ ] Age rating: 4+

## Final Review
- [ ] Test all IAP products in sandbox
- [ ] Test on real device (not just simulator)
- [ ] Verify no crashes on launch
- [ ] Verify all module screens render correctly
- [ ] Check app icon displays correctly
- [ ] Verify app description has no typos
- [ ] Double-check pricing matches IAP setup

## Submission
- [ ] Click "Submit for Review" in App Store Connect
- [ ] Respond to any reviewer questions promptly
- [ ] Typical review time: 24-48 hours

## Post-Approval
- [ ] Monitor crash reports in Xcode Organizer
- [ ] Respond to user reviews
- [ ] Plan updates for next version
- [ ] Set up analytics (optional, privacy-compliant)

---

## Common Rejection Reasons to Avoid
1. **Broken links** — all URLs must work
2. **Placeholder content** — no "Lorem ipsum" or TODO text
3. **Missing privacy policy** — must be accessible at a URL
4. **In-app purchase issues** — products must be purchasable in sandbox
5. **Crashes** — app must not crash during review
6. **Incomplete metadata** — screenshots, description, etc. must be filled
7. **Guideline violations** — no misleading descriptions, no hidden features
