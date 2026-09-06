import SwiftUI

@main
struct ClipperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings scene keeps the standard macOS Settings menu path available.
        // Primary entry is the dedicated NSWindow from StatusItemController.
        Settings {
            SettingsView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private var store: ClipboardStore!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure shared settings exist before store reads them.
        _ = AppSettings.shared
        store = ClipboardStore(settings: .shared)
        statusItemController = StatusItemController(store: store)
        store.startMonitoring()
    }
}
