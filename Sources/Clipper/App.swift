import SwiftUI
import KeyboardShortcuts

@main
struct ClipperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private var store: ClipboardStore!

    func applicationDidFinishLaunching(_ notification: Notification) {
        store = ClipboardStore()
        statusItemController = StatusItemController(store: store)
        store.startMonitoring()
    }
}