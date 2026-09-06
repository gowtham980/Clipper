import Foundation

/// Pure secret heuristics for clipboard text. UI-free.
enum SecretDetector {
    struct Match: Equatable {
        let kind: String
        let range: Range<String.Index>
    }

    /// High-confidence patterns only (default skip). False positives should be rare.
    static func findSecrets(in text: String) -> [Match] {
        var matches: [Match] = []

        func collect(_ name: String, _ regex: NSRegularExpression) {
            let full = NSRange(text.startIndex..<text.endIndex, in: text)
            regex.enumerateMatches(in: text, options: [], range: full) { result, _, _ in
                guard let result, let range = Range(result.range, in: text) else { return }
                matches.append(Match(kind: name, range: range))
            }
        }

        // AWS access key id
        collect("aws_access_key", try! NSRegularExpression(pattern: #"\bAKIA[0-9A-Z]{16}\b"#))

        // PEM / OpenSSH private key header
        collect(
            "private_key",
            try! NSRegularExpression(
                pattern: #"-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----"#
            )
        )

        // JWT (header.payload.signature), header typically starts with eyJ
        collect(
            "jwt",
            try! NSRegularExpression(
                pattern: #"\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b"#
            )
        )

        // GitHub personal access tokens
        collect("github_pat", try! NSRegularExpression(pattern: #"\bghp_[A-Za-z0-9]{36}\b"#))
        collect(
            "github_fine_grained",
            try! NSRegularExpression(pattern: #"\bgithub_pat_[A-Za-z0-9_]{22,}\b"#)
        )

        // High-entropy token-like strings (long base64/hex blobs), skip short lines
        if text.count >= 40 {
            collect(
                "high_entropy",
                try! NSRegularExpression(
                    pattern: #"\b(?:[A-Za-z0-9+/]{40,}={0,2}|[A-Fa-f0-9]{40,})\b"#
                )
            )
        }

        return matches
    }

    static func containsSecret(_ text: String) -> Bool {
        !findSecrets(in: text).isEmpty
    }

    /// Replace matched spans with a fixed redaction marker (non-overlapping, left-to-right).
    static func redact(_ text: String) -> String {
        let matches = findSecrets(in: text).sorted { $0.range.lowerBound < $1.range.lowerBound }
        guard !matches.isEmpty else { return text }

        var result = ""
        var cursor = text.startIndex
        var lastEnd = text.startIndex

        for match in matches {
            if match.range.lowerBound < lastEnd { continue } // overlap
            result += text[cursor..<match.range.lowerBound]
            result += "[redacted \(match.kind)]"
            cursor = match.range.upperBound
            lastEnd = match.range.upperBound
        }
        result += text[cursor...]
        return result
    }
}
