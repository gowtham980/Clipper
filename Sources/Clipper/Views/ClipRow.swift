import SwiftUI
import AppKit

struct ClipRow: View {
    let item: ClipItem
    @ObservedObject var store: ClipboardStore
    var onCopy: () -> Void = {}

    private var textPreview: String {
        if item.redacted {
            return item.content
        }
        let lines = item.content.split(separator: "\n", omittingEmptySubsequences: false)
        let first = String(lines.first ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if lines.count > 1 {
            let second = String(lines.dropFirst().first ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !second.isEmpty {
                return first.isEmpty ? second : "\(first)\n\(second)"
            }
        }
        return first.isEmpty ? "(empty)" : first
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                store.recopy(item)
                onCopy()
            } label: {
                HStack(alignment: .top, spacing: 8) {
                    leadingPreview
                    VStack(alignment: .leading, spacing: 2) {
                        primaryLabel
                        HStack(spacing: 6) {
                            Text(item.timestamp, style: .relative)
                            if item.redacted {
                                Text("redacted")
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(3)
                            }
                            if let app = item.sourceApp, !app.isEmpty {
                                Text(shortBundle(app))
                                    .lineLimit(1)
                            }
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                store.togglePin(item)
            } label: {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(item.isPinned ? Color.accentColor : .secondary)
            .help(item.isPinned ? "Unpin" : "Pin")
            .accessibilityLabel(item.isPinned ? "Unpin clip" : "Pin clip")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .contextMenu {
            Button("Copy") {
                store.recopy(item)
                onCopy()
            }
            Button(item.isPinned ? "Unpin" : "Pin") {
                store.togglePin(item)
            }
            if item.kind == .text {
                Divider()
                Menu("Transform") {
                    ForEach(ClipTransform.allCases) { rule in
                        Button(rule.title) {
                            store.transform(item, using: rule)
                        }
                    }
                }
            }
            Divider()
            Button("Delete", role: .destructive) {
                store.delete(item)
            }
        }
    }

    @ViewBuilder
    private var leadingPreview: some View {
        switch item.kind {
        case .image:
            if let thumb = store.loadThumbnail(for: item, maxSide: 32) {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .cornerRadius(4)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.secondary)
                    .help("Image unavailable")
            }
        case .text:
            EmptyView()
        }
    }

    @ViewBuilder
    private var primaryLabel: some View {
        switch item.kind {
        case .text:
            Text(textPreview)
                .lineLimit(2)
                .font(.body)
                .multilineTextAlignment(.leading)
        case .image:
            Text(store.imageURL(for: item).flatMap { url in
                FileManager.default.fileExists(atPath: url.path) ? "Image" : "Image unavailable"
            } ?? "Image unavailable")
                .font(.body)
                .foregroundStyle(.primary)
        }
    }

    private func shortBundle(_ id: String) -> String {
        id.split(separator: ".").last.map(String.init) ?? id
    }
}
