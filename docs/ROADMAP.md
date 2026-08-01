# Roadmap

_Part of the [Jabe Wellness AI](README.md) doc set. Current status as of 2026-08-01._

## Blocking

- ⬜ **[ACCOUNT]** Sign up for Apple Developer Program ($99/year) at developer.apple.com — Joel saving money. This gates everything under "App Store Launch" below.

## App Store Launch (blocked on account)

- ⬜ **[APP STORE CONNECT]** Create app record → IAP → Non-Consumable → Product ID `com.jabe.premium`, Price $3.99, Name "Jabe Premium"
- ⬜ **[ARCHIVE + UPLOAD]** Xcode → Any iOS Device → Product → Archive → Organizer → Distribute App → App Store Connect → Upload
- ⬜ **[POST-LAUNCH ADS]** Apple Search Ads using the feature graphic/banner — only available once the app is live and the Developer account is active

Full submission checklist in [APPLE_REVIEW.md](APPLE_REVIEW.md).

## Future Features

- ⬜ **[FUTURE]** WidgetKit extension — new Extension target in Xcode
- ⬜ **[POST-LAUNCH]** AI memory between sessions — premium feature, see [DECISIONS.md](DECISIONS.md)

## Marketing (independently actionable now)

- ⬜ **[PRE-LAUNCH]** Post Claude Design banners on social media to build hype before launch
- ⬜ **[POST-LAUNCH]** Produce and publish 60s cinematic video + 15s cut — publish order in [MARKETING.md](MARKETING.md), do after app ships

## Completed

- ✅ App Store screenshots — 12 per size, iPhone 15 Plus / 16 Plus / 17 Pro Max (2026-07-17)
- ✅ Routine credential rotation — GitHub PAT and Groq API key both refreshed (2026-07-30), see [SECURITY.md](SECURITY.md)
- ✅ Premium purchase flow fixed and verified end-to-end — StoreKit Configuration wired into the scheme via Xcode's UI, purchase/restore both tested (2026-07-30)
- ✅ Removed a stale/broken global git credential helper that was blocking pushes (2026-07-30)
- ✅ Made the GitHub repository private ahead of launch (2026-07-30) — revisit going public again post-launch
- ✅ Fixed broken unit test target (stale `MindMirrorApp` module import from the June rename) and a History-tab chronological-ordering bug (2026-08-01), see [CHANGELOG.md](CHANGELOG.md)
- ✅ Added permanent UI test regression coverage — chat send/mood detection/tab navigation and History session persistence, verified live on simulator (2026-08-01), see [CHANGELOG.md](CHANGELOG.md)

Full history in [CHANGELOG.md](CHANGELOG.md).

---

**Current blocker:** Apple Developer Program account gates App Store Connect setup, archive/upload, and Search Ads. Everything else is done or independently actionable — as of 2026-08-01, the app's core functionality (AI chat + premium purchase/restore) is fully working end-to-end.
