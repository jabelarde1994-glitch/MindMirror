# Apple Review Readiness

_Part of the [Jabe Wellness AI](README.md) doc set. Consolidates everything relevant to App Store submission — see [CHANGELOG.md](CHANGELOG.md) for the full fix narratives and dates._

## Device Support

- **iPhone-only.** `TARGETED_DEVICE_FAMILY` set to `1` (was `"1,2"` across all 6 build configs) so App Store Connect does not require iPad screenshots. Rationale in [DECISIONS.md](DECISIONS.md).
- Deployment target: iOS 17.0+.

## StoreKit / In-App Purchase

- Product: `com.jabe.premium` — Non-Consumable, $3.99 one-time, 7-day free trial.
- `PremiumManager` (StoreKit 2) handles purchase, restore, and entitlement state.
- **`transaction.finish()`** is called on the verified-transaction path after a successful purchase — required by StoreKit 2; skipping it leaves transactions permanently "unfinished," which Apple review flags as improper IAP handling.
- Purchase and restore flows surface real errors to the user via a `purchaseError` published property — no silently-swallowed failures.
- StoreKit Configuration (`Storekit.storekit`) is wired into the shared Xcode scheme via **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration**, and the file is committed to the repo (not gitignored) so a fresh clone has it available.

## Export Compliance

- `ITSAppUsesNonExemptEncryption = false` set in `Info.plist` — the app only uses standard HTTPS/TLS (exempt). Avoids the export-compliance prompt on every App Store Connect upload.

## In-App Disclaimer

- Final onboarding page ("A Companion, Not a Clinician") states Jabe is not a licensed therapist and points to 988 (Suicide & Crisis Lifeline) / Crisis Text Line for crisis support. This is shown directly to users, not just present in the hidden AI system prompt.
- `SafetyChecker` also surfaces crisis resources reactively during chat when crisis language is detected.

## Purchase Testing

Verified end-to-end in Xcode with the StoreKit Testing configuration (2026-07-30):

- Tapped "Unlock for $3.99" → real StoreKit Testing purchase sheet appeared → completed with Apple's "You're all set — [Environment: Xcode]" confirmation → paywall auto-dismissed → trial banner gone.
- Restore Purchase tested and works cleanly.
- Both flows now surface specific error messages on failure rather than failing silently.

## App Store Connect Assets

- **Screenshots — DONE (2026-07-17):** 12 per size × 3 device sizes (iPhone 15 Plus, 16 Plus, 17 Pro Max), covering Splash, Chatbox, Exercises (Breathing/Grounding/Reframe), Insights, Journal. Full detail in [MARKETING.md](MARKETING.md).
- **Important distinction:** the July 17 screenshots are for App Store submission only. Claude Design–generated banners/panels are marketing/social-only — Apple requires actual app UI in submission screenshots, not stylized mockups.

## Submission Checklist

| Item | Status |
|---|---|
| iPhone-only device family | ✅ Done |
| Export compliance key | ✅ Done |
| In-app clinician disclaimer | ✅ Done |
| IAP `transaction.finish()` | ✅ Done |
| Purchase/restore error handling | ✅ Done |
| Purchase flow tested end-to-end | ✅ Done |
| App Store screenshots | ✅ Done (2026-07-17) |
| Apple Developer Program account | ⬜ Not yet purchased — **current blocker** |
| App Store Connect app record + IAP setup | ⬜ Blocked on account |
| Archive + upload build | ⬜ Blocked on account |

Full status tracking lives in [ROADMAP.md](ROADMAP.md).
