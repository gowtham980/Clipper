import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Toggle Clipper", name: .togglePopover)
        }
        .padding()
        .frame(width: 300)
    }
}