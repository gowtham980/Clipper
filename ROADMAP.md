# ROADMAP

## Shipped in 0.2.x (this cycle)

- Menu bar popover + global hotkey (⌘⇧V, rebindable)
- Text + image history with search, pin, delete, clear unpinned
- Concealed / transient pasteboard skip
- Ignore-app list (password managers by default)
- SecretDetector (AWS, PEM, JWT, GitHub tokens, high-entropy) with skip / redact / keep
- Session “skipped secrets” counter
- Context-menu transforms (trim, JSON pretty, Base64, URL encode/decode)
- Settings window (hotkey, secrets, ignore apps, history limit, launch at login)
- XCTest coverage for pure policy / transforms / history limit

## Next

- **Accessibility auto-paste** into the frontmost app (explicit opt-in, usage string already reserved)
- Snippets / pinned collections with quick expand
- File URL and rich content types beyond text/image
- Optional Touch ID to reveal redacted clips
- Swift 6 strict concurrency cleanup when CI toolchains catch up

## Maybe later

- iCloud sync **off by default** (only if there is clear demand and a privacy write-up)
- OCR on image clips
- Browser extension companion (still local-first)

## Explicit non-goals

- Cloning Maccy’s overlay chrome or Deck’s kitchen-sink surface
- Telemetry or account systems
- Electron / Tauri rewrite
