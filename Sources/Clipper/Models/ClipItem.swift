import Foundation

enum ClipKind: String, Codable, Equatable {
    case text
    case image
}

struct ClipItem: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: ClipKind
    /// Text body, or image filename under Application Support/Clipper/images/.
    let content: String
    let timestamp: Date
    var isPinned: Bool
    var sourceApp: String?
    var redacted: Bool

    init(
        id: UUID = UUID(),
        kind: ClipKind = .text,
        content: String,
        timestamp: Date = Date(),
        isPinned: Bool = false,
        sourceApp: String? = nil,
        redacted: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.content = content
        self.timestamp = timestamp
        self.isPinned = isPinned
        self.sourceApp = sourceApp
        self.redacted = redacted
    }

    /// Backward-compatible decode for history written before `kind` / `redacted`.
    enum CodingKeys: String, CodingKey {
        case id, kind, content, timestamp, isPinned, sourceApp, redacted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        kind = try container.decodeIfPresent(ClipKind.self, forKey: .kind) ?? .text
        content = try container.decode(String.self, forKey: .content)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        sourceApp = try container.decodeIfPresent(String.self, forKey: .sourceApp)
        redacted = try container.decodeIfPresent(Bool.self, forKey: .redacted) ?? false
    }
}

extension Array where Element == ClipItem {
    /// Newest-first. Drops oldest unpinned items until `count <= limit`.
    /// Pinned items are kept even if that exceeds the limit.
    func clippedToHistoryLimit(_ limit: Int) -> [ClipItem] {
        guard limit >= 0, count > limit else { return self }
        var result = self
        while result.count > limit {
            guard let index = result.lastIndex(where: { !$0.isPinned }) else { break }
            result.remove(at: index)
        }
        return result
    }
}
