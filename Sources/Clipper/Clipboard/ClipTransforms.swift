import Foundation

enum ClipTransform: String, CaseIterable, Identifiable {
    case trim
    case jsonPretty
    case base64Encode
    case base64Decode
    case urlEncode
    case urlDecode

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trim: return "Trim whitespace"
        case .jsonPretty: return "JSON pretty-print"
        case .base64Encode: return "Base64 encode"
        case .base64Decode: return "Base64 decode"
        case .urlEncode: return "URL encode"
        case .urlDecode: return "URL decode"
        }
    }
}

enum ClipTransformError: Error, Equatable, LocalizedError {
    case notText
    case invalidJSON
    case invalidBase64
    case invalidURLEncoding

    var errorDescription: String? {
        switch self {
        case .notText:
            return "Transforms apply to text clips only."
        case .invalidJSON:
            return "Couldn't pretty-print JSON"
        case .invalidBase64:
            return "Couldn't decode Base64"
        case .invalidURLEncoding:
            return "Couldn't URL-decode text"
        }
    }
}

/// Pure text transforms. UI-free.
enum ClipTransforms {
    static func apply(_ transform: ClipTransform, to text: String) throws -> String {
        switch transform {
        case .trim:
            return text.trimmingCharacters(in: .whitespacesAndNewlines)

        case .jsonPretty:
            return try prettyJSON(text)

        case .base64Encode:
            guard let data = text.data(using: .utf8) else { return text }
            return data.base64EncodedString()

        case .base64Decode:
            let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = Data(base64Encoded: cleaned, options: [.ignoreUnknownCharacters]),
                  let out = String(data: data, encoding: .utf8)
            else {
                throw ClipTransformError.invalidBase64
            }
            return out

        case .urlEncode:
            var allowed = CharacterSet.urlQueryAllowed
            allowed.remove(charactersIn: ":/?#[]@!$&'()*+,;=")
            return text.addingPercentEncoding(withAllowedCharacters: allowed) ?? text

        case .urlDecode:
            guard let decoded = text.removingPercentEncoding else {
                throw ClipTransformError.invalidURLEncoding
            }
            return decoded
        }
    }

    private static func prettyJSON(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else {
            throw ClipTransformError.invalidJSON
        }

        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        } catch {
            throw ClipTransformError.invalidJSON
        }

        let prettyData: Data
        do {
            if JSONSerialization.isValidJSONObject(object) {
                prettyData = try JSONSerialization.data(
                    withJSONObject: object,
                    options: [.prettyPrinted, .sortedKeys]
                )
            } else {
                // Scalar fragments (string / number / bool / null)
                prettyData = try JSONSerialization.data(
                    withJSONObject: object,
                    options: [.fragmentsAllowed, .prettyPrinted]
                )
            }
        } catch {
            throw ClipTransformError.invalidJSON
        }

        guard let out = String(data: prettyData, encoding: .utf8) else {
            throw ClipTransformError.invalidJSON
        }
        return out
    }
}
