<p align="center">
  <img src="../JabeWellnessAI/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" width="120" alt="Jabe Wellness AI app icon" />
</p>

<h1 align="center">Jabe Wellness AI</h1>
<p align="center"><em>Your Emotional Wellness Companion</em></p>

Jabe Wellness AI is an iOS emotional wellness companion built with SwiftUI. Users talk naturally with Jabe as they would a trusted friend. Powered by a large language model (LLM), Jabe provides empathetic conversations, mood tracking, guided wellness exercises, and journaling.

Unlike meditation timer apps or scripted wellness chatbots, Jabe delivers genuine open-ended AI conversations tailored to each interaction.

Formerly named **MindMirror** — renamed to **Jabe Wellness AI** on 2026-06-24.

---

## Project Overview

| | |
|---|---|
| Platform | iOS 17.0+, built with Xcode 26.0.1 |
| Bundle ID | `com.jabe.wellnessai` |
| StoreKit product | `com.jabe.premium` — $3.99 one-time, 7-day free trial |
| AI backend | Groq API, `llama-3.3-70b-versatile` |
| Status | Core functionality complete. App Store submission pending Apple Developer account (see ROADMAP.md). |

---

## Features

### Free
- AI chatbot with full open-ended conversation
- Mood detection with color-coded bubbles
- Safety checker (988 Lifeline + Crisis Text Line) for crisis language
- Onboarding with clinician disclaimer, splash screen
- Chat history, Journal
- Settings, theming

### Premium ($3.99 one-time, 7-day trial)
- Mood Trends Chart (7-day)
- Streak tracking
- AI Weekly Insights
- Guided Exercises (Box Breathing, Grounding, CBT Reframing)
- Voice Input
- Journal Export (ShareSheet)

---

## Screenshots

App Store screenshots have been completed for all supported device sizes.

They will be added to the `docs/screenshots/` directory before the repository is made public.

See [MARKETING.md](MARKETING.md) for the complete marketing asset inventory and publishing plan.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jabelarde1994-glitch/JabeWellnessAI.git
   cd JabeWellnessAI
   ```
2. Open `JabeWellnessAI.xcodeproj` in Xcode 26+.
3. Create the (gitignored) secrets file — a fresh clone will **not** build without this:
   `JabeWellnessAI/SecretsStore.swift`
   ```swift
   enum SecretsStore {
       static let groqAPIKey = "gsk_YOUR_KEY_HERE"
   }
   ```
   Get a free key at [console.groq.com/keys](https://console.groq.com/keys).
   
---

## Build Instructions

1. Select the **JabeWellnessAI** scheme and an iPhone simulator or device (iPhone-only — no iPad support).
2. Confirm the scheme's StoreKit Configuration is set: **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → `Storekit.storekit`**. This must be set through Xcode's UI, not by hand-editing the `.xcscheme` file — see [APPLE_REVIEW.md](APPLE_REVIEW.md) for why.
3. Build and run with **⌘R**, or from the command line:
   ```bash
   xcodebuild -project JabeWellnessAI.xcodeproj -scheme JabeWellnessAI -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```
4. Run tests with **⌘U**, or:
   ```bash
   xcodebuild test -project JabeWellnessAI.xcodeproj -scheme JabeWellnessAI -destination 'platform=iOS Simulator,name=iPhone 16'
   ```
---

## Project Structure

```
JabeWellnessAI/
├── JabeWellnessAI.xcodeproj/
│   └── xcshareddata/xcschemes/JabeWellnessAI.xcscheme
├── JabeWellnessAI/                      # App target
│   ├── ContentView.swift                # Entire app: models, view model, services, views (~2700 lines)
│   ├── SecretsStore.swift               # Gitignored — Groq API key (create locally, see Installation)
│   ├── Storekit.storekit                # StoreKit Testing config (committed, no secrets)
│   ├── Info.plist
│   ├── JabeWellnessAI.entitlements
│   └── Assets.xcassets/                 # App icon, accent color
├── JabeWellnessAITests/                 # Unit tests
├── JabeWellnessAIUITests/               # UI tests
└── docs/                                # This documentation set
```

---

## Documentation Index

| Doc | Contents |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | App architecture, models, view model, services, storage, data flow |
| [DECISIONS.md](DECISIONS.md) | Key product/architecture decisions and rationale |
| [CHANGELOG.md](CHANGELOG.md) | Dated development history, grouped by topic |
| [APPLE_REVIEW.md](APPLE_REVIEW.md) | App Store submission readiness checklist |
| [ROADMAP.md](ROADMAP.md) | Current and future work, grouped by theme |
| [SECURITY.md](SECURITY.md) | Secrets handling, credential rotation, repo visibility |
| [MARKETING.md](MARKETING.md) | Video ad script, social captions, screenshot/publish plan |
| [WHITEPAPER.md](WHITEPAPER.md) | White paper reference and corrections log |
| [../CLAUDE.md](../CLAUDE.md) | Instructions for Claude Code when working in this repo |

---

## Technology Stack

- **UI:** SwiftUI (iOS 17.0+)
- **Concurrency:** Swift `async`/`await`
- **AI:** Groq API (`llama-3.3-70b-versatile`), free tier — 30 RPM / 14,400 RPD
- **In-App Purchase:** StoreKit 2, tested via a committed `Storekit.storekit` configuration
- **Speech:** `SFSpeechRecognizer` + `AVAudioEngine` for voice input
- **Persistence:** `UserDefaults` only — no cloud sync, no backend, no third-party data sharing
- **Testing:** XCTest (`JabeWellnessAITests`, `JabeWellnessAIUITests`)

---

## Architecture Summary

Single-file SwiftUI app (`ContentView.swift`, ~2700 lines) organized MVVM-style:

- **Models** — `ChatMessage`, `ChatSession`, `JournalEntry` (all `Codable`)
- **ViewModel** — `JournalViewModel` (chat send/receive, mood detection, session lifecycle)
- **Services** — `AIService` (Groq calls), `StorageManager` (UserDefaults), `StreakManager`, `PremiumManager` (StoreKit 2), `VoiceInputManager`, `SentimentAnalyzer` / `EmotionDetector` / `SafetyChecker`

Full breakdown, data flow, and the free/premium split live in [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Requirements

- macOS with Xcode 26.0.1+ installed
- An iOS 17.0+ simulator or physical iPhone
- A free [Groq](https://console.groq.com/keys) account for an API key
- No CocoaPods / Swift Package dependencies — the app has none
