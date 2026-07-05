import Foundation
import AppKit

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipItem] = []
    @Published var searchText: String = ""

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    private let historyLimit = 500
    private let storageURL: URL

    var filteredItems: [ClipItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Clipper", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        storageURL = dir.appendingPathComponent("history.json")
        lastChangeCount = pasteboard.changeCount
        load()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    private func checkPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            addItem(content: string)
        }
    }

    private func addItem(content: String) {
        // Avoid duplicate of most recent item
        if let first = items.first, first.content == content { return }

        let newItem = ClipItem(content: content)
        items.insert(newItem, at: 0)

        // Enforce limit (keep pinned items)
        if items.count > historyLimit {
            let nonPinned = items.filter { !$0.isPinned }
            let pinned = items.filter { $0.isPinned }
            let excess = nonPinned.count - (historyLimit - pinned.count)
            if excess > 0 {
                items = pinned + nonPinned.dropLast(excess)
            }
        }

        save()
    }

    func recopy(_ item: ClipItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    func togglePin(_ item: ClipItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isPinned.toggle()
            save()
        }
    }

    func delete(_ item: ClipItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func clearAll() {
        items.removeAll { !$0.isPinned }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else { return }
        if let decoded = try? JSONDecoder().decode([ClipItem].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: storageURL)
        }
    }
}