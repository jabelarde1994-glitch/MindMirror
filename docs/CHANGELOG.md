# Changelog

_Part of the [Jabe Wellness AI](README.md) doc set. Reverse-chronological, grouped by topic within each day._

## 2026-08-01

### Code Review Fixes
- **Broken unit test target** — `JabeWellnessAITests.swift` still had `@testable import MindMirrorApp`, left over from the June 24 rename to JabeWellnessAI. The module no longer exists, so `xcodebuild build-for-testing` failed outright (confirmed by running it). The main app target itself built and archived fine — this only broke running the unit test suite / any CI that runs tests. Fixed the import and also renamed the stale `MindMirrorApp{,UITests,UITestsLaunchTests}` struct/class names across all three test files to match. Re-ran `build-for-testing` — now succeeds.
- **History tab could show sections out of chronological order** — `HistoryView.grouped` (`ContentView.swift`) grouped chat sessions by their `.medium`-formatted date **string** (e.g. `"Aug 1, 2026"`) and sorted those strings alphabetically. Month abbreviations don't sort alphabetically in calendar order (e.g. `"Jul 20, 2026" > "Aug 1, 2026"` as strings, since `J` > `A`), so once sessions spanned a month boundary, an older month's section could appear above a more recent one. Fixed by grouping on `Calendar.current.startOfDay(for:)` (an actual `Date`) and formatting only for the section header display text — sort order is now always correct regardless of month.

### UI Test Coverage
- Added permanent regression coverage in `JabeWellnessAIUITests.swift`, replacing the empty template test. Verified live on an iPhone 17 Pro Max simulator (`xcodebuild test`), all passing:
  - `testChatSendAndNavigateTabs` — sends a chat message, confirms mood detection and a real AI reply bubble appear, starts a new chat, then cycles through every tab.
  - `testHistoryShowsSavedSessions` — sends a message, archives it via New Chat, then confirms the session shows up in Insights → Chat History and opens its detail view. Directly guards against the date-grouping regression above.
  - `testLaunchPerformance` (pre-existing) — app launches in ~1.55s average on simulator.
  - Interactions use SF Symbol default accessibility labels (`"Up"` for the send button, `"Comment"` for new-chat) rather than hardcoded coordinates — coordinates broke once the on-screen keyboard shifted the input bar up during earlier manual testing.

## 2026-07-30

### Repository Hardening
- Un-ignored and committed `*.storekit` — holds no secrets (just product IDs/prices), and the shared Xcode scheme references it directly, so a fresh clone was missing a file the scheme depends on.
- Trimmed README security-notes wording for public visibility (at the time) — reworded specific credential-exposure incident narration into general credential-hygiene practice descriptions, while keeping engineering write-ups (StoreKit debugging, purchase-flow fixes) in full detail.
- Removed a broken global git credential helper: `~/.gitconfig` had a leftover `credential.https://github.com.helper` override from an unrelated prior session, pointing to a `gh` CLI binary in a deleted temp scratchpad path. It silently broke every `git push`/`pull` by shadowing the working `osxkeychain` helper. Removed directly (`git config --global --unset-all ...`) — pushes now work normally.
- Made the GitHub repository private (App hasn't launched yet, no upside to public visibility pre-launch) via repo Settings → Danger Zone. Confirmed via the GitHub API (unauthenticated requests now get `404`). Local push/pull access unaffected — only visibility to others changes. GitHub Pages confirmed not enabled beforehand, so no effect on the Apple-submission privacy policy URL.

### Purchase Flow
- **Root cause #1 — missing shared scheme.** The shared `.xcscheme` file had gone missing (first noticed 2026-07-29) and was never recreated, so Xcode had nothing wiring `Storekit.storekit` to the Run action — `Product.products(for:)` was hitting the real App Store instead of the local test config, which fails in the Simulator with no sandbox tester signed in. Recreating the file by hand wasn't enough: Xcode still reported "Product 'com.jabe.premium' wasn't found" after rebuilding, because Xcode's own path-resolution for `StoreKitConfigurationFileReference` isn't safe to hand-author. Fixed properly through Xcode's UI: **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → `Storekit.storekit`** — Xcode rewrote the reference with a different (correct) relative path itself.
- **Root cause #2 — silent error swallowing in `PremiumManager.purchase()`.** Used `try? await product.purchase()`, discarding any thrown error (or `.userCancelled`/`.pending` result) with no feedback — this is why the button did nothing. Rewritten to handle every `PurchaseResult` case and surface real errors via a new `purchaseError` published property, shown as an alert on the paywall. Same fix applied to `restorePurchases()`.
- **Missing `transaction.finish()`.** After a verified purchase, the old code never called `transaction.finish()`. StoreKit 2 requires this; skipping it leaves transactions permanently "unfinished," which Apple review flags as improper IAP handling (see [APPLE_REVIEW.md](APPLE_REVIEW.md)). Added `await transaction.finish()` on the verified-transaction path.
- Fixed `purchaseError` being set with a specific diagnostic message in `loadProduct()`, then immediately overwritten by a generic "Store isn't ready yet" message in `purchase()`'s fallback guard — masking the real failure reason. Guard now only sets the generic message if nothing more specific was already set.
- A duplicate "Storekit.storekit" briefly appeared in the StoreKit Configuration dropdown while debugging — confirmed via a full project scan that only one physical `.storekit` file and one project file-reference exist, so it was a stale Xcode UI/DerivedData cache artifact, not a real duplicate.
- **Confirmed fully working end-to-end (tested by Joel in Xcode):** tapped "Unlock for $3.99" → real StoreKit Testing purchase sheet appeared → completed with Apple's own "You're all set — [Environment: Xcode]" confirmation → paywall auto-dismissed → trial banner gone → Restore Purchase also tested and works cleanly.

### Apple Review Preparation
- `TARGETED_DEVICE_FAMILY` was `"1,2"` (iPhone + iPad) across all 6 build configs, conflicting with the iPhone-only decision (see [DECISIONS.md](DECISIONS.md)) — changed to `1` (iPhone only) in `project.pbxproj`.
- Added in-app disclaimer — new final onboarding page ("A Companion, Not a Clinician") states Jabe is not a licensed therapist and points to 988 for crisis support. Previously this rule only existed in the hidden AI system prompt, not shown to users.
- Added export compliance key — `ITSAppUsesNonExemptEncryption = false` in `Info.plist`, since the app only uses standard HTTPS/TLS (exempt). Avoids the export-compliance prompt on every App Store Connect upload.
- Removed a force-unwrap crash risk (`ContentView.swift`, paywall button) — `premium.product!.displayPrice` was gated by a preceding `!= nil` check so it wasn't actually crashing, but was fragile against future refactors. Rewritten as `premium.product?.displayPrice ?? "$3.99"`. Swept the rest of the file for `try!`/`as!`/other force unwraps — this was the only one found.
- Guarded debug logging — `print("GROQ RESPONSE:", raw)` was unconditionally logging the full AI reply to console on every chat message, including in release builds. Wrapped both Groq debug prints in `#if DEBUG` so they compile out of the shipped binary.

### Credential Rotation
- GitHub PAT rotated as part of a routine credential-hygiene pass — new token generated and stored in macOS Keychain Access.
- Ran a full-project secrets audit — scanned every file type for accidentally-committed API keys/tokens/private keys. Confirmed clean.
- Groq API key rotated to a fresh value in `SecretsStore.swift` (gitignored, never committed) as part of the same pass. Joel generated the new key at console.groq.com/keys and pasted it in, replacing the `REPLACE_WITH_NEW_GROQ_KEY` placeholder. Confirmed working: AI chat now returns real Groq-generated replies instead of the placeholder message.

## 2026-07-29

### Xcode Cleanup
- After the README was first committed (`b2e00b8`), `git status` showed two files reported as deleted: `JabeWellnessAI.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` and `JabeWellnessAI.xcodeproj/xcshareddata/xcschemes/JabeWellnessAI.xcscheme`. Confirmed harmless: the project's *shared* scheme no longer exists on disk (likely reset by Xcode at some point, possibly during the June rename), but a local user-level scheme (`xcuserdata/joelreamosioabelarde.xcuserdatad/xcschemes/xcschememanagement.plist`) is present and gitignored by design — this is what Xcode actually uses to build/run/archive on this Mac. App builds, runs, and archives fine; would only matter if the project were ever cloned onto a different machine.
- Removed a leftover `JabeWellnessAI copy.xcodeproj/` folder at the repo root — an untracked duplicate project generated during the June 24 MindMirror → JabeWellnessAI rename session, never cleaned up. Confirmed unused and deleted (`rm -rf`).
- The two deleted xcshareddata files still showed in `git status` as pending deletions at the time of this note — safe to commit, since they reflect the actual working-tree state.

## Undated — Code Changes & Bug Fixes

- **Holographic splash screen** — new `HolographicBrainView`: hue-cycling brain colors, 3 pulsing glow halos, neon lightning arcs (Canvas), shimmer sweep, ambient glow orb. Timer-driven (0.05s brain effects, 0.10s background hue). Splash-only, does not replace the existing `BrainLogoView` used elsewhere.
- **Splash screen centering bug fix** — root cause was `GeometryReader` defaulting to top-leading alignment. Fixed by removing GeometryReader entirely: particles moved to `Canvas`, ambient orb uses a fixed size, and the content `VStack` is a direct `ZStack` child (which centers correctly).
- **App icon** — added colorful rainbow-brain 1024×1024px icon (Claude-generated) to `Assets.xcassets → AppIcon → Any Appearance`.
- **Duplicate StoreKit build phase warning** — harmless Xcode warning ("Skipping duplicate build file in Copy Bundle Resources... Storekit"), fixed by removing the duplicate entry manually in Build Phases.
- **Message input box height fix** (commit `dc36fc3`) — the chat `TextEditor` had no height cap on its containing `ZStack`, so it expanded to fill most of the screen. Fixed by adding `.frame(minHeight: 44, maxHeight: 120)` directly on the ZStack (`ContentView.swift`, near the "Auto-sizing TextEditor with placeholder" section) — input now grows with typed text but caps at ~4 lines.
