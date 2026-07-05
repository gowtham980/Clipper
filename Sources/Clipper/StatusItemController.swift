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

    init(store: ClipboardStore) {
        self.store = store
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipper")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover.contentSize = NSSize(width: 380, height: 480)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: PopoverRoot(store: store))

        KeyboardShortcuts.onKeyUp(for: .togglePopover) { [weak self] in
            self?.togglePopover(nil)
        }
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func popoverWillClose(_ notification: Notification) {
        // No-op
    }
}