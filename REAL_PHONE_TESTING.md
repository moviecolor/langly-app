# Real-Phone Testing Checklist

## 📱 Pre-Test Setup

- [ ] Install app on real device via Xcode
- [ ] Grant notification permission when prompted
- [ ] Test with AirPods or headphones (for audio quality)
- [ ] Have another device ready to call (to test background audio interruption)

---

## 🔊 Audio & Sound

- [ ] **Voice Quality** — Does the Portuguese voice sound natural? Male vs Female?
- [ ] **Speech Rate** — Is the default speed comfortable? Too fast/slow?
- [ ] **Volume Levels** — Are words loud enough? Quiet enough for public?
- [ ] **Background Audio** — Lock the phone while Audio Mode plays. Does it continue?
- [ ] **AirPods Switch** — Start playing, then put in AirPods. Does audio switch?
- [ ] **CarPlay/Bluetooth** — Does audio route to car speakers?
- [ ] **Silence Gap** — Does the 0.5s-5s gap feel natural between words?
- [ ] **Audio Session Conflicts** — Play music, then start Langly. Does it mix properly?

---

## 📳 Haptic Feedback

- [ ] **Word Save** — Light tap when saving a word
- [ ] **Game Match (Correct)** — Success vibration on correct match
- [ ] **Game Match (Wrong)** — Error vibration on wrong match
- [ ] **Button Taps** — Selection feedback on all buttons
- [ ] **Swipe Delete** — Impact feedback on swipe-to-delete
- [ ] **Game Complete** — Double notification on game over
- [ ] **Haptic Strength** — Is it noticeable but not annoying?

---

## 🎮 Game Experience

- [ ] **Match Madness Timer** — Is 1:45 enough time? Too much?
- [ ] **Word Display** — Can you read all words clearly? Font size OK?
- [ ] **Column Layout** — Are the two columns easy to scan?
- [ ] **Selection Feedback** — Orange highlight visible enough?
- [ ] **Score Tracking** — Does score update correctly?
- [ ] **Time Warning** — Does red color at 15s grab attention?
- [ ] **Game Complete Overlay** — Stats visible? Buttons clear?
- [ ] **Restart Flow** — Does Play Again work smoothly?

---

## 🔤 Vocabulary Management

- [ ] **Add Word Flow** — Type → Auto-Translate → Save. Smooth?
- [ ] **Translation Accuracy** — Are Apple translations good enough?
- [ ] **Block Selection** — Easy to pick the right block?
- [ ] **Word List** — Can you see all words clearly?
- [ ] **Swipe to Delete** — Does swipe gesture work? Haptic felt?
- [ ] **Mastery Badges** — New/Learning/Mastered colors visible?
- [ ] **Block Progress** — Does progress bar update correctly?
- [ ] **15-Word Limit** — Does "Full" indicator appear when block is full?

---

## 📊 Analytics & Stats

- [ ] **Stats Dashboard** — Does the chart icon appear in toolbar?
- [ ] **Overview Cards** — All 6 cards showing correct numbers?
- [ ] **Learning Stats** — Words Added/Reviewed/Mastered accurate?
- [ ] **Engagement Stats** — Session count, time, games correct?
- [ ] **Heatmap** — Does the 24-hour grid show activity?
- [ ] **Word Difficulty** — Tricky Words section tracking errors?
- [ ] **Privacy Notice** — "100% Private" badge visible?

---

## 🏆 Achievements

- [ ] **Trophy Icon** — Appears in toolbar?
- [ ] **Badge Grid** — All 10 badges visible?
- [ ] **Streak Display** — Current streak showing correctly?
- [ ] **Badge Unlock** — Do badges unlock as you practice?
- [ ] **Badge Colors** — Are unlocked badges colorful, locked greyed out?

---

## 🚀 Onboarding

- [ ] **First Launch** — Does onboarding appear on fresh install?
- [ ] **Skip Button** — Can you skip all 4 pages?
- [ ] **Language Selector** — All 8 languages visible?
- [ ] **Language Preview** — Does "Tap to hear it" play the sample word?
- [ ] **Continue Button** — Progresses through all pages?
- [ ] **Start Learning** — Dismisses onboarding, saves language?
- [ ] **Second Launch** — Onboarding does NOT appear again?

---

## 🎨 Visual & UI

- [ ] **Dark Mode** — Toggle in Settings. Does it look good?
- [ ] **Gradient Cards** — Do gradient borders render correctly?
- [ ] **Icon Backgrounds** — Are gradient icon backgrounds visible?
- [ ] **Tap Animations** — Do cards scale on tap?
- [ ] **Loading Graphics** — Do locked modules show loading screens?
- [ ] **Font Scaling** — Does Dynamic Type work? (Settings → Display)
- [ ] **Landscape Mode** — Does UI rotate correctly?
- [ ] **Notch/Dynamic Island** — Does UI respect safe areas?

---

## 🔔 Notifications

- [ ] **Permission Prompt** — Does the alert appear on first launch?
- [ ] **Daily Reminder** — Does 7 PM notification arrive?
- [ ] **Notification Content** — Title and body readable?
- [ ] **Tap Notification** — Opens the app when tapped?
- [ ] **Badge Count** — App icon badge shows correct number?

---

## ⚡ Performance

- [ ] **App Launch Time** — Does app open in < 2 seconds?
- [ ] **Word Save Speed** — Does save feel instant?
- [ ] **Game Start Speed** — Does game load quickly?
- [ ] **Memory Usage** — Check in Xcode Instruments. No leaks?
- [ ] **Battery Impact** — Play Audio Mode for 30 min. Battery drain reasonable?
- [ ] **Heat** — Does phone get warm during extended use?

---

## 🐛 Edge Cases

- [ ] **No Internet** — Does everything work offline?
- [ ] **Low Storage** — Does app handle low storage gracefully?
- [ ] **Rotate During Game** — Does game state preserve?
- [ ] **Background/Foreground** — Does game pause/resume correctly?
- [ ] **Multiple Blocks** — Play game with 5+ blocks. Performance OK?
- [ ] **135+ Words** — Load all starter words. Any lag?
- [ ] **Voice Download** — Download enhanced voice from Settings. Does it appear?
- [ ] **Empty State** — No words added yet. Are empty states helpful?

---

## 📋 Notes

**Testing Priority:**
1. Audio quality + background audio (highest value feature)
2. Haptic feedback (feels premium)
3. Onboarding flow (first impression)
4. Analytics accuracy (data integrity)
5. Performance + battery (usability)

**Known Limitations:**
- Enhanced voices require download from iOS Settings
- TTS quality varies by voice (some better than others)
- No camera OCR yet (future feature)
- No Siri Shortcuts yet (future feature)

---

*Last updated: July 25, 2026*
