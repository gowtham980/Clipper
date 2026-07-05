import Foundation

struct ClipItem: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    var isPinned: Bool

    init(content: String, timestamp: Date = Date(), isPinned: Bool = false) {
        self.id = UUID()
        self.content = content
        self.timestamp = timestamp
        self.isPinned = isPinned
    }
}