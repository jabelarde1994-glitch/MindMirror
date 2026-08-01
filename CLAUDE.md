# Claude Instructions

## Project

- Jabe Wellness AI — iOS emotional wellness AI chatbot (formerly MindMirror)
- SwiftUI, iOS 17.0+, built with Xcode 26.0.1 / Swift 5.0
- Single-file architecture: `ContentView.swift` (~2700 lines: models, views, view model, services) + `SecretsStore.swift`

## Important Files

- `JabeWellnessAI/ContentView.swift` — the entire app: `ChatMessage`/`ChatSession`/`JournalEntry` models, `JournalViewModel`, `AIService`, `StorageManager`, `StreakManager`, `PremiumManager`, `VoiceInputManager`, all views
- `JabeWellnessAI/SecretsStore.swift` — gitignored, holds the Groq API key. Never read this file into a chat session — a prior key was rotated specifically because it had been pasted into one.
- `JabeWellnessAI/Storekit.storekit` — StoreKit Testing config; intentionally committed (no secrets, just product IDs/prices)
- `JabeWellnessAI/Info.plist`, `JabeWellnessAI.entitlements`

## Never Change Without Asking

- **Purchase flow** (`PremiumManager`, `PremiumPaywallView`) — recently fixed after silent-failure bugs; StoreKit configuration wiring is finicky (must be set via Xcode's UI, not hand-edited XML)
- **Product/bundle IDs** — `com.jabe.premium`, `com.jabe.wellnessai`
- **`ChatSession` / `ChatMessage` / `JournalEntry` models** — Codable, persisted directly to UserDefaults; changing their shape can break existing users' saved data
- Anything in `SecretsStore.swift` or `Storekit.storekit`

## Build

- Xcode 26.0.1, Swift 5.0, deployment target iOS 17.0+
- iPhone only (`TARGETED_DEVICE_FAMILY = 1`) — see [docs/DECISIONS.md](docs/DECISIONS.md) before reintroducing iPad support
- StoreKit Configuration must be set via **Xcode → Edit Scheme → Run → Options → StoreKit Configuration**, not by hand-editing `.xcscheme` XML — Xcode's relative-path resolution for that field isn't safe to author manually

## Coding Style

- Match existing SwiftUI patterns in `ContentView.swift`
- Avoid force unwraps (`!`, `try!`, `as!`) — use `??` / `guard` / optional chaining instead
- Prefer `async`/`await` over completion handlers
- Storage is 100% on-device `UserDefaults` by design — no cloud sync, no third-party data sharing; don't introduce network persistence without discussing it first

## Current Priority

App Store launch — blocked on the Apple Developer Program account signup (see [docs/ROADMAP.md](docs/ROADMAP.md)). AI chat and premium purchase/restore are fully functional and verified as of 2026-07-30.

## Docs

Full doc set lives in `docs/`: README (overview), ARCHITECTURE, DECISIONS, CHANGELOG, APPLE_REVIEW, ROADMAP, SECURITY, MARKETING, WHITEPAPER.
