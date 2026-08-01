# Architecture

_Part of the [Jabe Wellness AI](README.md) doc set._

## Overview

- **Single-file SwiftUI app** — `ContentView.swift`, ~2500+ lines, MVVM-inspired
- **Models:** `ChatMessage`, `ChatSession` (Codable, stored in UserDefaults), `JournalEntry`
- **ViewModel:** `JournalViewModel` — handles chat send/receive, mood detection, session lifecycle
- **Services:** `AIService` (Groq API calls), `StorageManager` (UserDefaults persistence), `StreakManager`, `PremiumManager` (StoreKit 2), `VoiceInputManager` (SFSpeechRecognizer + AVAudioEngine)
- **Storage:** 100% on-device via `UserDefaults` — no cloud sync, no user accounts, no third-party data sharing
- **API key:** stored in `SecretsStore.swift` — gitignored, never committed (verified clean via `git log --all -- '*SecretsStore*'`)

## Free vs Premium feature split

| Free | Premium ($3.99 one-time) |
|---|---|
| AI chatbot, full conversation | Mood Trends Chart (7-day) |
| Mood detection, color bubbles | Streak tracking |
| Safety checker (988 Lifeline + Crisis Text Line) | AI Weekly Insights |
| Onboarding, splash screen | Guided Exercises (Box Breathing, Grounding, CBT Reframing) |
| Chat history, Journal | Voice Input |
| Settings, theming | Journal Export (ShareSheet) |

---

## Data Flow

1. User types in `InputBar` → `JournalViewModel` appends a `ChatMessage` to the active `ChatSession`.
2. `JournalViewModel` calls `AIService`, which sends the conversation to the Groq API (`llama-3.3-70b-versatile`) using the key from `SecretsStore.swift`.
3. The Groq reply is parsed (`GroqResponse`), appended as a `ChatMessage`, and run through `SentimentAnalyzer` / `EmotionDetector` for mood detection and through `SafetyChecker` for crisis-language detection (988 Lifeline / Crisis Text Line).
4. `ChatSession`s are persisted via `StorageManager` to `UserDefaults` **when the user starts a New Chat** — not continuously and not on app close. See [DECISIONS.md](DECISIONS.md) for why.
5. `StreakManager` and `PremiumManager` (StoreKit 2) run independently, gating premium-only views (Mood Trends, Weekly Insights, Guided Exercises, Voice Input, Journal Export).

For the rationale behind these choices (fresh chat per launch, Groq free tier, iPhone-only, deferred AI memory), see [DECISIONS.md](DECISIONS.md).

---

## Known harmless SourceKit false positives (Xcode 26 bug — do NOT fix)
`SecretsStore` not in scope · `.warning/.success/.error` member inference · `UINotificationFeedbackGenerator` · `UIRectCorner` / `UIBezierPath` · `.systemGray6` · `.topLeft`/`.topRight`. App compiles and runs fine despite these.
