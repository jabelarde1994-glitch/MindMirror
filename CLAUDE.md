# Claude Instructions

## Project

- Jabe Wellness AI — iOS emotional wellness AI chatbot (formerly MindMirror)
- SwiftUI, iOS 17.0+, built with Xcode 26.0.1 / Swift 5.0
- Single-file architecture: `ContentView.swift` (~2700 lines: models, views, view model, services) + `SecretsStore.swift`

## Important Files

- `JabeWellnessAI/ContentView.swift` — the entire app: `ChatMessage`/`ChatSession`/`JournalEntry` models, `JournalViewModel`, `AIService`, `StorageManager`, `StreakManager`, `PremiumManager`, `VoiceInputManager`, all views
- `JabeWellnessAI/SecretsStore.swift` — gitignored, holds the Groq API key. **Never read, cat, grep, or print this file's contents in a chat session, in any tool call, for any reason** — two separate keys have already been rotated specifically because they ended up pasted into a chat. If the key needs to change: ask the user to edit the file directly in their own editor (never paste the key into chat), then verify it works by building the app and running `JabeWellnessAIUITests/testChatSendAndNavigateTabs` (sends a real chat message, asserts a genuine AI reply appears) — this confirms the key works without ever reading the file. Exposure to a chat session is treated as compromised regardless of whether it ever reached GitHub — the transcript itself is the exposure surface.
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

## Testing

- Unit tests (`JabeWellnessAITests`, fast, no network): `xcodebuild test -project JabeWellnessAI.xcodeproj -scheme JabeWellnessAI -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:JabeWellnessAITests`
- UI tests (`JabeWellnessAIUITests`, hit the real Groq API, ~30s+ each): same command with `-only-testing:JabeWellnessAIUITests`
- For any bug fix: write a failing unit test that reproduces it first, confirm it fails, then fix, then confirm it passes — don't fix from a hunch
- For any change to `ContentView.swift` model/view-model logic (not just UI): add or extend a unit test in `JabeWellnessAITests.swift` covering it
- For any visible UI change: build and launch on the simulator (`xcrun simctl`) and confirm visually before claiming it's done — type-checking isn't feature verification
- `JabeWellnessAITests.swift` uses Swift Testing (`import Testing`, `@Test`, `#expect`), not XCTest

## Coding Style

- Match existing SwiftUI patterns in `ContentView.swift`
- Avoid force unwraps (`!`, `try!`, `as!`) — use `??` / `guard` / optional chaining instead
- Prefer `async`/`await` over completion handlers
- Storage is 100% on-device `UserDefaults` by design — no cloud sync, no third-party data sharing; don't introduce network persistence without discussing it first

## Current Priority

App Store launch — blocked on the Apple Developer Program account signup (see [docs/ROADMAP.md](docs/ROADMAP.md)). AI chat and premium purchase/restore are fully functional and verified as of 2026-07-30.

## Docs

Full doc set lives in `docs/`: README (overview), ARCHITECTURE, DECISIONS, CHANGELOG, APPLE_REVIEW, ROADMAP, SECURITY, MARKETING, WHITEPAPER.

## Non-Repo Assets

Two sibling folders outside this repo (`../[Files] Jabe Wellness AI`, `../[Screenshots:Video] Jabe Wellness AI Project`) hold marketing collateral (whitepaper, deck, portfolio, App Store screenshot panels/banners). They are **not** part of this git repo and are never touched by a commit/push here. Don't assume they need updating for a code change unless the change is visible on-screen or contradicts something they specifically describe — check before editing, most fixes affect neither.

## Git

- Only commit or push when explicitly asked — never proactively
- Match the existing log style: short, root-cause-focused subject line (what broke and why, not just what changed); body explains impact and how it was verified
- Never force-push, amend a pushed commit, or skip hooks without being explicitly told to
