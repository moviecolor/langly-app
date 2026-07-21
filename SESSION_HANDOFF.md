# SESSION HANDOFF — LANGLY

**Last Session:** 2026-07-21 17:20
**Agent:** OpenCode (deepseek-v4-flash-free)

---

## Session State

### ✅ Completed
1. **Screen sizing fix** — LaunchScreen.storyboard + 4 Info.plist keys added. App now fills full iPhone 17 screen.
2. **Vocabulary page reorder** — "Add Word Block" moved between Audio Mode and block cards.
3. **English words display** — block cards show English words in 3-column compact tag grid.
4. **Ghost block card** — dashed-border suggestion card at bottom to add new blocks.

### 🔄 In Progress
- Audio Mode playback verification not yet done.

### 📋 Pending
- Audio Mode testing (N reps per word + loop)
- More blocks/words for testing
- TD Bank PDF extraction

---

## Git State

**Branch:** `master`
**Latest commit:** `9c62c9c docs: session save 2026-07-21`
**Uncommitted:** 5 modified, 2 untracked (LaunchScreen.storyboard + build/)
**Remote (main):** `github` → `https://github.com/moviecolor/langly-app.git`
**Remote (backup):** Thunder drive mirror

## Key Files Changed This Session
```
Sources/LaunchScreen.storyboard          ← NEW - fixes screen sizing
Sources/Info.plist                       ← MODIFIED - added 4 iOS keys
project.yml                              ← MODIFIED - locked plist properties
Sources/Views/Modules/Vocabulary/VocabularyView.swift ← MODIFIED - reorder + word grid + ghost block
```

## How to Resume
```
git checkout master
git pull github master
# Open the project, build and run on iPhone 17 simulator
# Verify Vocabulary page layout
# Test Audio Mode playback
```
