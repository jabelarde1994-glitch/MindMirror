# White Paper

_Part of the [Jabe Wellness AI](README.md) doc set._

## Reference

`[Files] Jabe Wellness AI/ Jabe Wellness AI - White Paper & Application Structure.docx` (+ .pdf) — full product/application structure document, kept alongside the code project.

## Corrections Applied

Fixes made to the white paper to keep it consistent with the shipped app:

- "Human Interference Guidelines" → **"Human Interface Guidelines"**
- GitHub URL corrected from `MindMirror` → **`JabeWellnessAI`** (see [DECISIONS.md](DECISIONS.md) for the rename background)
- Data Flow section corrected: sessions save **when the user starts a New Chat**, not on app close (see [ARCHITECTURE.md](ARCHITECTURE.md#data-flow))
- Model name typo fixed: `llama-3.3-70-versatile` → **`llama-3.3-70b-versatile`**
- Added bug-fix table entry for the message input box height fix (see [CHANGELOG.md](CHANGELOG.md))
