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

## Install (no Xcode needed)

### Homebrew (recommended)

```bash
brew install --cask gowtham980/tap/clipper
```

### Direct download

1. Download the latest `Clipper-*.dmg` from the [Releases](https://github.com/gowtham980/Clipper/releases) page.
2. Open the DMG and drag `Clipper.app` to `/Applications`.
3. First launch: Right-click the app → **Open** (one-time Gatekeeper step because the app is ad-hoc signed).

After that, Clipper lives in your menu bar.

## Usage

1. Copy anything (text) on your Mac.
2. Click the Clipper icon in the menu bar (or press ⌘⇧V).
3. Search or browse history, pin important clips, or tap any row to re-copy it.
4. Open **Settings…** from the footer to change the global hotkey.

## Build from Source (developers)

```bash
git clone https://github.com/gowtham980/Clipper.git
cd Clipper
swift run
```

Or build a release binary:

```bash
swift build -c release
# binary at .build/release/Clipper
```

## License

MIT — feel free to use, modify, and distribute.