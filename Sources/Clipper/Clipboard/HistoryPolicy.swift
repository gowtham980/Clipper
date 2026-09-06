import Foundation

enum SecretMode: String, CaseIterable, Identifiable {
    case skip
    case redact
    case keep

    var id: String { rawValue }

    var title: String {
        switch self {
        case .skip: return "Skip secrets"
        case .redact: return "Redact secrets"
        case .keep: return "Keep everything"
        }
    }

    var detail: String {
        switch self {
        case .skip: return "Do not store high-confidence secrets (keys, PEM, JWT, GitHub tokens)."
        case .redact: return "Store the clip with secret spans replaced by markers."
        case .keep: return "Store plaintext including secrets (not recommended)."
        }
    }
}

enum CaptureDecision: Equatable {
    case skip(reason: String)
    case capture(text: String, redacted: Bool)
}

/// Decides whether a clipboard snapshot should enter history.
enum HistoryPolicy {
    /// Default password-manager / vault bundle ids.
    static let defaultIgnoredBundleIds: [String] = [
        "com.1password.1password",
        "com.1password.1password-launcher",
        "com.1password.safari",
        "com.agilebits.onepassword7",
        "com.agilebits.onepassword-safari",
        "com.bitwarden.desktop",
        "com.bitwarden.desktop.safari",
        "com.lastpass.LastPass",
        "com.dashlane.dashlanephonefinal",
        "com.dashlane.Dashlane",
        "com.apple.Passwords",
        "com.apple.PasswordManagerBrowserExtensionHelper",
        "com.keepassx.keepassxc",
        "org.keepassxc.keepassxc",
    ]

    static func decision(
        text: String,
        sourceBundleId: String?,
        ignoredBundleIds: Set<String>,
        secretMode: SecretMode,
        pasteboardIsConcealedOrTransient: Bool
    ) -> CaptureDecision {
        if pasteboardIsConcealedOrTransient {
            return .skip(reason: "concealed_or_transient")
        }

        if let bundle = sourceBundleId, ignoredBundleIds.contains(bundle) {
            return .skip(reason: "ignored_app")
        }

        let hasSecret = SecretDetector.containsSecret(text)
        guard hasSecret else {
            return .capture(text: text, redacted: false)
        }

        switch secretMode {
        case .skip:
            return .skip(reason: "secret")
        case .redact:
            return .capture(text: SecretDetector.redact(text), redacted: true)
        case .keep:
            return .capture(text: text, redacted: false)
        }
    }

    /// Parse a user-edited ignore list (comma / newline separated).
    static func parseIgnoreList(_ raw: String) -> Set<String> {
        let parts = raw
            .split(whereSeparator: { $0 == "," || $0 == "\n" || $0 == ";" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Set(parts)
    }

    static func serializeIgnoreList(_ ids: Set<String>) -> String {
        ids.sorted().joined(separator: "\n")
    }
}
