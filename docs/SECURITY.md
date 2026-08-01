# Security Notes

_Part of the [Jabe Wellness AI](README.md) doc set._

- `SecretsStore.swift` (Groq API key) is gitignored and confirmed **never committed** to any point in git history.
- `*.storekit` is intentionally **tracked**, not ignored — it holds no secrets (just product IDs/prices) and the shared Xcode scheme references it directly, so it must be committed for StoreKit Testing to work on a fresh clone.
- GitHub PAT and Groq API key are rotated periodically as routine credential hygiene.
- Practice followed: keys and tokens are set directly in their respective files/tools (Keychain Access, `SecretsStore.swift`, `git remote set-url`) rather than pasted anywhere else.
- **GitHub repo is private** (set 2026-07-30, pre-launch) — will likely go public again after the app ships, at which point this section should be re-reviewed for anything worth trimming before doing so.

See [CHANGELOG.md](CHANGELOG.md) for the dated history of credential rotations and hardening work.
