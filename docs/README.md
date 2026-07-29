# Jabe Wellness AI — Project README

_Last updated: 2026-07-29 (evening — Xcode project cleanup session)_

An iOS emotional wellness AI chatbot built with SwiftUI by Joel Abelarde ("Jabe"). Formerly named **MindMirror** — fully renamed to **Jabe Wellness AI** on 2026-06-24. This document is a running reference of the project's architecture, all changes made, decisions taken, and open action items — intended so a new conversation/session can pick up full context quickly.

---

## 1. Project Overview

| | |
|---|---|
| App name | Jabe Wellness AI |
| Tagline | Your Emotional Wellness Companion |
| Platform | iOS 17.0+, built with Xcode 26.0.1 |
| Bundle ID | `com.jabe.wellnessai` |
| StoreKit product | `com.jabe.premium` — $3.99 one-time, 7-day free trial |
| AI backend | Groq API, `llama-3.3-70b-versatile` (free tier: 30 RPM / 14,400 RPD) |
| GitHub | https://github.com/jabelarde1994-glitch/JabeWellnessAI |
| Local repo path | `/Users/joelreamosioabelarde/Documents/Jabe - Project/[Code] Jabe Wellness AI/` |
| White paper | `[Files] Jabe Wellness AI/ Jabe Wellness AI - White Paper & Application Structure.docx` (+ .pdf) |

**What Jabe is:** an AI conversation-based wellness companion — not a meditation timer, not a scripted chatbot. Users talk to Jabe like a friend; it responds with real LLM-generated empathy, tracks mood, and offers guided exercises and journaling. Positioned as fundamentally different from meditation-timer apps (e.g. "Mindfulness") and from scripted rule-based wellness bots (Woebot, Wysa) because of its genuine open-ended AI conversation.

---

## 2. Architecture

- **Single-file SwiftUI app** — `ContentView.swift`, ~2500+ lines, MVVM-inspired
- **Models:** `ChatMessage`, `ChatSession` (Codable, stored in UserDefaults), `JournalEntry`
- **ViewModel:** `JournalViewModel` — handles chat send/receive, mood detection, session lifecycle
- **Services:** `AIService` (Groq API calls), `StorageManager` (UserDefaults persistence), `StreakManager`, `PremiumManager` (StoreKit 2), `VoiceInputManager` (SFSpeechRecognizer + AVAudioEngine)
- **Storage:** 100% on-device via `UserDefaults` — no cloud sync, no user accounts, no third-party data sharing
- **API key:** stored in `SecretsStore.swift` — gitignored, never committed (verified clean via `git log --all -- '*SecretsStore*'`)

### Free vs Premium feature split

| Free | Premium ($3.99 one-time) |
|---|---|
| AI chatbot, full conversation | Mood Trends Chart (7-day) |
| Mood detection, color bubbles | Streak tracking |
| Safety checker (988 Lifeline + Crisis Text Line) | AI Weekly Insights |
| Onboarding, splash screen | Guided Exercises (Box Breathing, Grounding, CBT Reframing) |
| Chat history, Journal | Voice Input |
| Settings, theming | Journal Export (ShareSheet) |

---

## 3. Session Notes — 2026-07-29 (Xcode project file cleanup)

- After the README was first committed (`b2e00b8`), `git status` showed two files reported as **deleted**: `JabeWellnessAI.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` and `JabeWellnessAI.xcodeproj/xcshareddata/xcschemes/JabeWellnessAI.xcscheme`. Investigated and confirmed **harmless**: the project's *shared* scheme no longer exists on disk (likely reset by Xcode at some point, possibly during the June rename), but a **local user-level scheme** (`xcuserdata/joelreamosioabelarde.xcuserdatad/xcschemes/xcschememanagement.plist`) is present and gitignored by design — this is what Xcode actually uses to build/run/archive on this Mac. App builds, runs, and archives fine; no action needed. This would only matter if the project were ever cloned onto a different machine by another developer.
- Also found a leftover **`JabeWellnessAI copy.xcodeproj/`** folder at the repo root — an untracked duplicate project generated during the June 24 MindMirror → JabeWellnessAI rename session, never cleaned up. Confirmed unused and **deleted** (`rm -rf`) on 2026-07-29.
- These two deleted xcshareddata files still show in `git status` as pending deletions (not yet committed as of this note) — safe to commit whenever, since they reflect the actual current state of the working tree.

## 4. Code Changes & Bug Fixes Log

- **Holographic splash screen** — new `HolographicBrainView`: hue-cycling brain colors, 3 pulsing glow halos, neon lightning arcs (Canvas), shimmer sweep, ambient glow orb. Timer-driven (0.05s brain effects, 0.10s background hue). Splash-only, does not replace the existing `BrainLogoView` used elsewhere.
- **Splash screen centering bug fix** — root cause was `GeometryReader` defaulting to top-leading alignment. Fixed by removing GeometryReader entirely: particles moved to `Canvas`, ambient orb uses a fixed size, and the content `VStack` is a direct `ZStack` child (which centers correctly).
- **App icon** — added colorful rainbow-brain 1024×1024px icon (Claude-generated) to `Assets.xcassets → AppIcon → Any Appearance`.
- **Duplicate StoreKit build phase warning** — harmless Xcode warning ("Skipping duplicate build file in Copy Bundle Resources... Storekit"), fixed by removing the duplicate entry manually in Build Phases.
- **Message input box height fix** (commit `dc36fc3`) — the chat `TextEditor` had no height cap on its containing `ZStack`, so it expanded to fill most of the screen. Fixed by adding `.frame(minHeight: 44, maxHeight: 120)` directly on the ZStack (`ContentView.swift`, near the "Auto-sizing TextEditor with placeholder" section) — input now grows with typed text but caps at ~4 lines.

### Known harmless SourceKit false positives (Xcode 26 bug — do NOT fix)
`SecretsStore` not in scope · `.warning/.success/.error` member inference · `UINotificationFeedbackGenerator` · `UIRectCorner` / `UIBezierPath` · `.systemGray6` · `.topLeft`/`.topRight`. App compiles and runs fine despite these.

---

## 5. Key Decisions (with rationale)

- **Active chat persistence — Option B chosen:** each app open starts a fresh chat; old conversations remain accessible via the Chat History tab (saved when tapping "New Chat"). Considered Option A (auto-restore last conversation) but Joel deliberately kept Option B — a clean check-in on open fits the wellness-app UX better than resurfacing unfinished emotional conversations. **No code change was made for this.**
- **Groq API stays free tier at launch** — independent of the Apple Developer account; free tier (30 RPM / 14,400 RPD) is sufficient for early users. Upgrade only if users consistently hit rate limits.
- **AI memory between sessions** — deferred to post-launch; planned as a **premium feature** (summarize last 2–3 `ChatSession`s from UserDefaults, inject as context into the Groq system prompt).
- **iPhone-only app** — no iPad screenshots needed for App Store submission.

---

## 6. White Paper Corrections Applied

- "Human Interference Guidelines" → **"Human Interface Guidelines"**
- GitHub URL corrected from `MindMirror` → **`JabeWellnessAI`**
- Data Flow section corrected: sessions save **when the user starts a New Chat**, not on app close
- Model name typo fixed: `llama-3.3-70-versatile` → **`llama-3.3-70b-versatile`**
- Added bug-fix table entry for the message input box height fix

---

## 7. Marketing / Video Ad Assets

Full captions, Claude Design prompts, and the video ad script live in:
`[Files] Jabe Wellness AI/Jabe Wellness AI - Instagram Captions & Ad Prompts.txt`

- **App Store screenshots — DONE (2026-07-17):** 12 screenshots per size × 3 device sizes (iPhone 15 Plus, iPhone 16 Plus, iPhone 17 Pro Max), covering Splash, Chatbox, Exercises (Breathing/Grounding/Reframe), Insights, Journal.
- **Important Apple policy distinction:** the real July 17 screenshots are for **App Store submission only**. Claude Design–generated banners/panels are for **marketing/social media only** — Apple requires actual app UI in submission screenshots, not stylized mockups.
- **Video ad script** — 60s cinematic 3D concept (soft piano + ambient pads music), structure: Hook → Problem → Arrival of Jabe → Features Showcase → Emotional Resolution → CTA. Two copy revisions made:
  - "Therapy is expensive" → **"Not everyone has someone to lean on."** (avoids sounding dismissive of therapy)
  - "Free on the App Store" → **"Coming Soon on the App Store"** (accurate pre-launch state; swap back to "Free" once live)
- **"It's 3 a.m. Jabe's awake." story-cover hook** — rationale documented in the prompts file: positions Jabe as a 24/7 companion available during the loneliest hours, when no therapist or friend is reachable.
- **Publish order after launch:** (1) App Store Preview Video, (2) Instagram Reels + TikTok, (3) YouTube, (4) Facebook/LinkedIn.
- **Pre-launch:** post Claude Design banners on Instagram/TikTok to build hype before the app ships.

---

## 8. Security Notes

- `SecretsStore.swift` and `*.storekit` are gitignored and confirmed **never committed** to the repo.
- ⚠️ **Open item:** an old GitHub PAT was exposed in prior chat history and still needs to be regenerated on GitHub.
- Reminder: never paste PAT tokens in chat — use `git remote set-url` directly via the shell.

---

## 9. Action Items (current status)

1. **[ACCOUNT]** Sign up for Apple Developer Program ($99/year) at developer.apple.com — Joel saving money
2. **[DONE ✅]** App Store screenshots — 12 per size, iPhone 15 Plus / 16 Plus / 17 Pro Max (completed 2026-07-17)
3. **[APP STORE CONNECT]** After account: Create app record → IAP → Non-Consumable → Product ID `com.jabe.premium`, Price $3.99, Name "Jabe Premium"
4. **[ARCHIVE + UPLOAD]** After account: Xcode → Any iOS Device → Product → Archive → Organizer → Distribute App → App Store Connect → Upload
5. **[SECURITY]** Regenerate GitHub PAT — old PAT was exposed in chat history
6. **[FUTURE]** WidgetKit extension — new Extension target in Xcode
7. **[POST-LAUNCH]** AI memory between sessions — premium feature (see Section 4)
8. **[VIDEO ADS]** Produce and publish 60s cinematic + 15s cut — publish order in Section 6 — do AFTER app ships
9. **[MARKETING — PRE-LAUNCH]** Post Claude Design banners on social media to build hype before launch
10. **[POST-LAUNCH ADS]** Apple Search Ads using the feature graphic/banner — only available after the app is live and the Developer account is active

**Current blocker:** Item #1 (Apple Developer account, $99/year) gates items #3, #4, and #10. Everything else is either done or independently actionable.
