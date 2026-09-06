import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section {
                KeyboardShortcuts.Recorder("Toggle Clipper", name: .togglePopover)
            } header: {
                Text("Hotkey")
            } footer: {
                Text("Shows or hides clipboard history from any app. Default ⌘⇧V.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Picker("When a secret is detected", selection: $settings.secretMode) {
                    ForEach(SecretMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                Text(settings.secretMode.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Secret policy")
            } footer: {
                Text("Detects AWS keys, PEM private keys, JWTs, GitHub tokens, and high-entropy blobs. Default is Skip.")
                    .foregroundStyle(.secondary)
            }

            Section {
                TextEditor(text: $settings.ignoreAppsText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 100, maxHeight: 140)
                Button("Reset ignore list to defaults") {
                    settings.resetIgnoreAppsToDefaults()
                }
            } header: {
                Text("Ignore apps")
            } footer: {
                Text("Bundle identifiers, one per line (or comma-separated). Copies from these apps are never stored.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Stepper(value: $settings.historyLimit, in: 10...2000, step: 10) {
                    Text("Keep \(settings.historyLimit) clips")
                }
                TextField("Limit", value: $settings.historyLimit, format: .number)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("History limit")
            } footer: {
                Text("Oldest unpinned clips are dropped first. Pinned clips are always kept.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                if let error = settings.launchAtLoginError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("Startup")
            } footer: {
                Text("Uses macOS Login Items. Works best when Clipper is installed as Clipper.app.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 420, minHeight: 480)
        .padding(.bottom, 8)
    }
}
