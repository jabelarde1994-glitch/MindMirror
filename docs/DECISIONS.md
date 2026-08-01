# Key Decisions

_Part of the [Jabe Wellness AI](README.md) doc set. Product/architecture decisions and the reasoning behind them._

## Fresh chat every launch (Option B)

Each app open starts a fresh chat; old conversations remain accessible via the Chat History tab (saved when tapping "New Chat"). Considered Option A (auto-restore last conversation) but Joel deliberately kept Option B — a clean check-in on open fits the wellness-app UX better than resurfacing unfinished emotional conversations. **No code change was made for this** — it was a conscious choice to keep the existing behavior.

## Groq free tier at launch

Groq API stays on the free tier (30 RPM / 14,400 RPD) at launch, independent of the Apple Developer account — sufficient for early users. Upgrade only if users consistently hit rate limits.

## iPhone-only app

No iPad screenshots needed for App Store submission; `TARGETED_DEVICE_FAMILY` set accordingly. See [APPLE_REVIEW.md](APPLE_REVIEW.md) for the build-config side of this decision.

## AI memory between sessions (deferred)

Deferred to post-launch; planned as a **premium feature** — summarize the last 2–3 `ChatSession`s from UserDefaults and inject them as context into the Groq system prompt. Tracked in [ROADMAP.md](ROADMAP.md).
