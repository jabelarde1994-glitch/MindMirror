# Jabe Wellness AI — Project README

_Last updated: 2026-07-30 (Apple review prep, security rotation, purchase-flow fix, and repo hardening ahead of launch)_

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
| GitHub | https://github.com/jabelarde1994-glitch/JabeWellnessAI (private since 2026-07-30, pre-launch) |
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

## 3a. Session Notes — 2026-07-30 (Apple review prep fixes)

- **`TARGETED_DEVICE_FAMILY`** was `"1,2"` (iPhone + iPad) across all 6 build configs, conflicting with the iPhone-only decision in Section 5 — App Store Connect would have required iPad screenshots. Changed to `1` (iPhone only) in `project.pbxproj`.
- **In-app disclaimer added** — new final onboarding page ("A Companion, Not a Clinician") states Jabe is not a licensed therapist and points to 988 for crisis support. Previously this rule only existed in the hidden AI system prompt, not shown to users.
- **GitHub PAT rotated** as part of a routine credential-hygiene pass — new token generated and stored in macOS Keychain Access.
- **Full-project secrets audit** — scanned every file type in the project folder for accidentally-committed API keys/tokens/private keys. Confirmed clean.
- **Groq API key rotated** to a fresh value in `SecretsStore.swift` (gitignored, never committed) as part of the same hygiene pass.
- **Force-unwrap crash risk removed** (`ContentView.swift`, paywall button) — `premium.product!.displayPrice` was gated by a preceding `!= nil` check so it wasn't actually crashing today, but was fragile against future refactors. Rewritten as `premium.product?.displayPrice ?? "$3.99"` — no force unwrap, same behavior. Swept the rest of the file for `try!`/`as!`/other force unwraps — this was the only one found.
- **Debug logging guarded** — `print("GROQ RESPONSE:", raw)` was unconditionally logging the full AI reply (i.e. a reflection of the user's own conversation) to console on every single chat message, including in release builds. Wrapped both Groq debug prints in `#if DEBUG` so they compile out of the shipped binary.
- **Export compliance key added** — `ITSAppUsesNonExemptEncryption = false` added to `Info.plist` since the app only uses standard HTTPS/TLS (exempt). Avoids the export-compliance prompt on every App Store Connect upload.

## 3b. Session Notes — 2026-07-30 (manual QA found a real purchase bug — fixed)

- **Manually tested in Xcode (Joel):** confirmed the Groq placeholder message (expected, see 3a) and found premium purchase genuinely failing silently — tapping "Unlock for $3.99" did nothing, no error, no purchase sheet.
- **Root cause #1 — missing shared scheme.** The shared `.xcscheme` file had gone missing at some point (first noticed in Section 3, 2026-07-29) and was never recreated, so Xcode had nothing wiring `Storekit.storekit` to the Run action. Without that, `Product.products(for:)` was hitting the real App Store instead of the local test config, which fails in the Simulator with no sandbox tester signed in. **Fixed:** recreated `JabeWellnessAI.xcodeproj/xcshareddata/xcschemes/JabeWellnessAI.xcscheme` with a `StoreKitConfigurationFileReference` pointing at `Storekit.storekit`, plus proper Test/Profile/Archive actions.
- **Root cause #2 — silent error swallowing in `PremiumManager.purchase()`.** It used `try? await product.purchase()`, so any thrown error (or `.userCancelled`/`.pending` result) was discarded with no feedback — this is why the button just did nothing. **Fixed:** rewritten to handle every `PurchaseResult` case and surface real errors via a new `purchaseError` published property, shown as an alert on the paywall.
- **Also fixed — missing `transaction.finish()`.** After a verified purchase, the old code never called `transaction.finish()`. StoreKit 2 requires this; skipping it leaves transactions permanently "unfinished," which Apple review flags as improper IAP handling (relevant directly to the Apple review checklist's IAP requirement). Added `await transaction.finish()` on the verified-transaction path.
- **`restorePurchases()`** — same `try?`-swallowing issue, now also surfaces errors via `purchaseError`.
- **Rebuilt after all fixes — BUILD SUCCEEDED**, no new compiler errors introduced.
- **Reviewed while in there, no issues found:** `VoiceInputManager` mic/speech permission-denial flow (already shows a proper alert), `StorageManager`, `StreakManager`.
- **Still to do:** re-test the purchase flow in Xcode now that the scheme exists (Product → Run), and generate the new Groq key (see 3a) — the AI chat still won't respond until that's done.

## 3c. Session Notes — 2026-07-30 (Groq key rotated + purchase flow fully verified end-to-end)

- **New Groq API key added — DONE.** Joel generated a new key at console.groq.com/keys and pasted it into `SecretsStore.swift`, replacing the `REPLACE_WITH_NEW_GROQ_KEY` placeholder. Confirmed working: AI chat now returns real Groq-generated replies instead of the placeholder message.
- **Purchase flow — root cause fully resolved.** My hand-authored `StoreKitConfigurationFileReference` in the shared `.xcscheme` (see 3b) turned out not to be enough on its own — after rebuilding, Xcode still reported "Product 'com.jabe.premium' wasn't found," meaning the StoreKit config still wasn't actually wired into the running scheme. Fixed properly by setting it through Xcode's own UI: **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → `Storekit.storekit`.** Xcode rewrote the scheme's `StoreKitConfigurationFileReference` itself with a different (correct) relative path than my hand-written one — confirms Xcode's own path-resolution for this element isn't safe to hand-author; always set it via the UI, not by editing the `.xcscheme` XML directly.
- **A duplicate "Storekit.storekit" briefly appeared in the StoreKit Configuration dropdown** while debugging this — confirmed via a full project scan that only one physical `.storekit` file and one project file-reference exist, so it was a stale Xcode UI/DerivedData cache artifact, not a real duplicate. Not a project issue; clears on its own or after a DerivedData wipe.
- **Purchase flow confirmed fully working (2026-07-30, tested by Joel in Xcode):** tapped "Unlock for $3.99" → real StoreKit Testing purchase sheet appeared → completed with Apple's own "You're all set — [Environment: Xcode]" confirmation → paywall auto-dismissed → trial banner gone → **Restore Purchase** also tested and works cleanly.
- **Also found and fixed along the way:** `purchaseError` was being set with a specific, useful diagnostic message inside `loadProduct()`, then immediately overwritten by a generic "Store isn't ready yet" message in `purchase()`'s fallback guard right after — masking the real reason for a failure. Fixed so the guard only sets the generic message if nothing more specific was already set.
- **Status: both the AI chat and the premium purchase flow (including restore) are now fully functional and verified**, closing out the two remaining functional blockers from the Apple review prep pass.

## 3d. Session Notes — 2026-07-30 (repo hardening ahead of launch)

- **`*.storekit` un-ignored and committed.** It had been gitignored alongside `SecretsStore.swift`, but it holds no secrets (just product IDs/prices) — and since the shared Xcode scheme now references it directly (see 3c), a fresh clone was missing a file the scheme depends on. Fixed by removing it from `.gitignore` and committing `Storekit.storekit`.
- **README trimmed for public visibility** (at the time) — the security-notes sections previously narrated the specific credential-exposure incidents (which chat, which file, which flag). Since GitHub visibility was public at that point, reworded those sections to describe general credential-hygiene practices instead, while keeping all the substantive engineering write-ups (StoreKit debugging, purchase-flow fixes) in full detail.
- **Broken global git credential helper removed.** `~/.gitconfig` had a leftover `credential.https://github.com.helper` override from an unrelated prior session, pointing to a `gh` CLI binary in a deleted temp scratchpad path. It silently broke every `git push`/`pull` for this repo by shadowing the working `osxkeychain` helper. Joel removed it directly (`git config --global --unset-all ...`) — pushes now work normally without any workaround.
- **GitHub repository made private.** App hasn't launched yet, and there's no upside to public visibility pre-launch — flipped from public to private via repo Settings → Danger Zone. Confirmed via the GitHub API (unauthenticated requests now get `404`, as expected for a private repo). Local push/pull access is completely unaffected by this — only visibility to others changes. GitHub Pages was confirmed **not** enabled on this repo beforehand, so this had no effect on the Apple-submission privacy policy URL (which isn't hosted from here).

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

- `SecretsStore.swift` (Groq API key) is gitignored and confirmed **never committed** to any point in git history.
- `*.storekit` is intentionally **tracked**, not ignored — it holds no secrets (just product IDs/prices) and the shared Xcode scheme references it directly, so it must be committed for StoreKit Testing to work on a fresh clone.
- GitHub PAT and Groq API key are rotated periodically as routine credential hygiene.
- Practice followed: keys and tokens are set directly in their respective files/tools (Keychain Access, `SecretsStore.swift`, `git remote set-url`) rather than pasted anywhere else.
- **GitHub repo is private** (set 2026-07-30, pre-launch) — will likely go public again after the app ships, at which point this section should be re-reviewed for anything worth trimming before doing so.

---

## 9. Action Items (current status)

1. **[ACCOUNT]** Sign up for Apple Developer Program ($99/year) at developer.apple.com — Joel saving money
2. **[DONE ✅]** App Store screenshots — 12 per size, iPhone 15 Plus / 16 Plus / 17 Pro Max (completed 2026-07-17)
3. **[APP STORE CONNECT]** After account: Create app record → IAP → Non-Consumable → Product ID `com.jabe.premium`, Price $3.99, Name "Jabe Premium"
4. **[ARCHIVE + UPLOAD]** After account: Xcode → Any iOS Device → Product → Archive → Organizer → Distribute App → App Store Connect → Upload
5. **[DONE ✅ 2026-07-30]** Routine credential rotation completed — GitHub PAT and Groq API key both refreshed (see Section 8); AI chat confirmed returning real replies
6. **[DONE ✅ 2026-07-30]** Premium purchase flow fixed and verified end-to-end — StoreKit Configuration wired into the scheme via Xcode's UI, purchase/restore both tested successfully in Xcode
7. **[FUTURE]** WidgetKit extension — new Extension target in Xcode
8. **[POST-LAUNCH]** AI memory between sessions — premium feature (see Section 5)
9. **[VIDEO ADS]** Produce and publish 60s cinematic + 15s cut — publish order in Section 7 — do AFTER app ships
10. **[MARKETING — PRE-LAUNCH]** Post Claude Design banners on social media to build hype before launch
11. **[POST-LAUNCH ADS]** Apple Search Ads using the feature graphic/banner — only available after the app is live and the Developer account is active
12. **[DONE ✅ 2026-07-30]** Removed a stale/broken global git credential helper override that was blocking pushes (see Section 3d)
13. **[DONE ✅ 2026-07-30]** Made the GitHub repository private ahead of launch (see Section 3d) — revisit going public again post-launch

**Current blocker:** Item #1 (Apple Developer account, $99/year) gates items #3, #4, and #11. Everything else is either done or independently actionable — as of 2026-07-30, the app's core functionality (AI chat + premium purchase/restore) is fully working end-to-end.
