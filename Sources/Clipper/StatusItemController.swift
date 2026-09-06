import AppKit
import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePopover = Self("togglePopover", default: .init(.v, modifiers: [.command, .shift]))
}

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private let store: ClipboardStore
    private var settingsWindowController: NSWindowController?

    init(store: ClipboardStore) {
        self.store = store
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "doc.on.clipboard",
                accessibilityDescription: "Clipper"
            )
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover.contentSize = NSSize(width: 380, height: 480)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: PopoverRoot(
                store: store,
                onClose: { [weak self] in self?.closePopover() },
                onOpenSettings: { [weak self] in self?.openSettings() }
            )
        )

        KeyboardShortcuts.onKeyUp(for: .togglePopover) { [weak self] in
            Task { @MainActor in
                self?.togglePopover(nil)
            }
        }
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover()
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
    }

    private func openSettings() {
        closePopover()
        NSApp.activate(ignoringOtherApps: true)

        if settingsWindowController == nil {
            let hosting = NSHostingController(rootView: SettingsView())
            let window = NSWindow(contentViewController: hosting)
            window.title = "Clipper Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 440, height: 520))
            window.center()
            settingsWindowController = NSWindowController(window: window)
        }

        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func popoverWillClose(_ notification: Notification) {
        // No-op — monitor is owned by AppDelegate, not the popover.
    }
}
