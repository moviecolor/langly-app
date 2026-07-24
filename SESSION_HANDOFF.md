# SESSION HANDOFF — LANGLY

**Last Session:** 2026-07-24 12:45
**Agent:** OpenCode (big-pickle)

---

## Session State

### ✅ Completed
1. **Jumble mode rewrite** — All words appear in BOTH columns. Each word randomly either normal (EN→PT) or flipped (PT→EN). Both columns get SAME flip decision, shuffled independently.
2. **Translation API** — MyMemory free API added as fallback between Apple Translation and MockTranslator.
3. **Word input restructured** — Both English and Portuguese fields always visible. "Auto-Translate" button as convenience.
4. **Tappable block cards** — VocabularyView block cards open WordInputView with block preselected.
5. **Voice picker** — Real pt-BR voices from AVSpeechSynthesisVoice in Settings. Saved to AppSettings.selectedVoice.
6. **Audio mode fixed** — English spoken once, Portuguese repeated N times (repetitions setting).
7. **Audio display update** — Display now shows current word being spoken in real time (nil-then-reassign + .id() modifiers).
8. **Game stop/done navigation** — Stop/Done buttons dismiss back to VocabularyView with score shown. Player can pick new block.
9. **Dark mode + settings** — Dark mode toggle, app backgrounds, launch screen, settings appearance section.

### 🔄 In Progress
- None

### 📋 Pending
- ReMyk server issues (separate project — microphone not live/muted/ended)
- More blocks/words for testing
- TD Bank PDF extraction

---

## Git State

**Branch:** `master`
**Latest commit:** `a4a4afa fix: audio display now updates as words play`
**Remote:** `github` → `https://github.com/moviecolor/langly-app.git`

## Commits This Session
```
a4a4afa fix: audio display now updates as words play
0e70e18 fix: audio mode — English once, Portuguese repeated N times
87abf34 fix: game stop/done navigates back to VocabularyView with score
875010a fix: jumble mode — same flip per word across both columns
dabcc22 fix: jumble mode — all words in both columns, correct odd counts
23ba466 feat: voice picker in Settings + AudioMode reads saved voice
7ebc2f3 feat: restructure word input — both fields always visible, translate as helper
75671fd feat: jumble bug fix + translation API + tappable blocks
```

## How to Resume
```
git checkout master
git pull github master
# Open the project, build and run on iPhone 17 simulator
# Test Audio Mode: words should display as they play
# Test Match Madness: Stop/Done should go back to VocabularyView
```

## Known Issues
- **ReMyk**: Microphone track not live / muted / ended — separate project, may need MBP restart
- **System performance**: Sluggish today — possibly RustDesk or AC Studio consuming resources
