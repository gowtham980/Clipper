import Foundation
import ServiceManagement

/// UserDefaults-backed settings shared by store and Settings UI.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private enum Keys {
        static let historyLimit = "historyLimit"
        static let secretMode = "secretMode"
        static let ignoreApps = "ignoreApps"
        static let launchAtLogin = "launchAtLoginDesired"
    }

    @Published var historyLimit: Int {
        didSet { UserDefaults.standard.set(historyLimit, forKey: Keys.historyLimit) }
    }

    @Published var secretMode: SecretMode {
        didSet { UserDefaults.standard.set(secretMode.rawValue, forKey: Keys.secretMode) }
    }

    @Published var ignoreAppsText: String {
        didSet { UserDefaults.standard.set(ignoreAppsText, forKey: Keys.ignoreApps) }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
            applyLaunchAtLogin()
        }
    }

    @Published private(set) var launchAtLoginError: String?

    var ignoredBundleIds: Set<String> {
        HistoryPolicy.parseIgnoreList(ignoreAppsText)
    }

    init() {
        let defaults = UserDefaults.standard
        let limit = defaults.object(forKey: Keys.historyLimit) as? Int ?? 500
        historyLimit = min(max(limit, 10), 2000)

        if let raw = defaults.string(forKey: Keys.secretMode),
           let mode = SecretMode(rawValue: raw) {
            secretMode = mode
        } else {
            secretMode = .skip
        }

        if let stored = defaults.string(forKey: Keys.ignoreApps), !stored.isEmpty {
            ignoreAppsText = stored
        } else {
            ignoreAppsText = HistoryPolicy.serializeIgnoreList(
                Set(HistoryPolicy.defaultIgnoredBundleIds)
            )
        }

        // Reflect ServiceManagement when possible; fall back to stored desire.
        if SMAppService.mainApp.status == .enabled {
            launchAtLogin = true
        } else {
            launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        }
        launchAtLoginError = nil
    }

    func resetIgnoreAppsToDefaults() {
        ignoreAppsText = HistoryPolicy.serializeIgnoreList(
            Set(HistoryPolicy.defaultIgnoredBundleIds)
        )
    }

    private func applyLaunchAtLogin() {
        do {
            if launchAtLogin {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
            launchAtLoginError = nil
        } catch {
            launchAtLoginError =
                "Couldn’t update Login Items (\(error.localizedDescription)). Build as Clipper.app for reliable launch-at-login."
        }
    }
}
