# 📋 Task Plan — Langly App UI Overhaul + Settings Page

## Objective
1. Center the title text across all views  
2. Fix page scrolling (elements running off bottom of page)  
3. Build a Settings/Sub page for user data entry  
4. Add hamburger menu access in top-right corner (fixed position)  

---

## Phase 1: Title Centering + Scroll Fix
**Status:** `complete` ✅  
**Completed:** 2026-05-21  

### What was done:
- Added `.navigationTitle("Langly")` to main view with `.toolbar(.visible, for: .navigationBar)` or used centered alignment patterns
- Fixed layout structure so content area is scrollable when it exceeds screen height
- Changed the module content container to use `ScrollView` with proper frame constraints

**Files Modified:**
- `Sources/Views/MainMenuView.swift` — Restructured layout, added scrolling, centered title  
- `Sources/Views/ContentView.swift` — Added navigation bar with centered title  

### Errors Encountered:
| Error | Attempt | Resolution |
|-------|---------|------------|
| ScrollView with NavigationStack conflict | 1 | Used `.navigationTitle("Langly")` in root + wrapped content properly |

---

## Phase 2: Data Model — UserRoutineSettings  
**Status:** `pending` ⏳  

### Tasks:
- [x] Extend AppSettings with new fields
- [ ] Create `UserRoutineEntry.swift` model for pre-work activities

### Fields needed:
- showName (String)
- homeGPSCoordinates (String - "lat,lon")  
- workLocationCoordinates (String - "lat,lon")
- startTime (Date/Time)
- wrapTime (Date/Time)  
- preWorkActivities ([PreWorkActivity])

---

## Phase 3: Settings View UI  
**Status:** `pending` ⏳  

### Tasks:
- [ ] Create `SettingsView.swift` with all form fields
- [ ] Add save/dark mode support
- [ ] Form-based layout for proper scrolling

---

## Phase 4: Hamburger Menu + Integration
**Status:** `pending` ⏳  

### Tasks:
- [ ] Add hamburger menu icon to MainMenuView top-bar  
- [ ] Wire up navigation to Settings View
- [ ] Test on multiple simulators

---

## Files Modifying/Creating:
| File | Action | Description |
|------|--------|-------------|
| `Sources/AppMain.swift` | Modify | Main entry point, add NavigationStack wrapper |
| `Sources/Models/AppSettings.swift` | Extend | Add new fields for user data  
- [ ] New file for pre-work activity model

---

## CRITICAL CONTEXT:
// THIS FILE HAS BEEN MODIFIED AND THE ORIGINAL CONTENT WAS:
**This is the Langly language learning app (iOS SwiftUI SwiftData)**
Project Structure:**
- `Langly.swift` - Main App structure  
- `ContentView.swift` - Main view with navigation stack and module router
- `MainMenuView.swift` - Main menu with vocabulary, common sentences, and Q&A tabs
- `SettingsView.swift` - Settings screen for user data entry
