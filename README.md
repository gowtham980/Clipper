# Clipper

Native macOS clipboard manager — lightweight, fast, and private.

- Menu bar icon with a clean popover UI
- Auto-captures text you copy anywhere on macOS
- Search, pin, delete, and re-copy history items
- Global hotkey (⌘⇧V) to toggle the popover
- Persists history across restarts
- No cloud, no telemetry — everything stays on your Mac

## Requirements

- macOS 13 Ventura or later
- Xcode Command Line Tools (or full Xcode)

## Quick Start

```bash
git clone https://github.com/gowtham980/Clipper.git
cd Clipper
swift run
```

The first run builds the app and launches it in the menu bar.

## Usage

1. Copy anything (text) on your Mac.
2. Click the Clipper icon in the menu bar (or press ⌘⇧V).
3. Search or browse history, pin important clips, or tap any row to re-copy it.
4. Open **Settings…** from the footer to change the global hotkey.

## Build from Source

```bash
swift build -c release
```

The binary is at `.build/release/Clipper`.

## License

MIT — feel free to use, modify, and distribute.