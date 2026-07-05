import SwiftUI

struct ClipRow: View {
    let item: ClipItem
    @ObservedObject var store: ClipboardStore

    private var preview: String {
        let lines = item.content.split(separator: "\n")
        return String(lines.first ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(preview)
                    .lineLimit(2)
                    .font(.body)
                Text(item.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                store.togglePin(item)
            } label: {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(item.isPinned ? Color.accentColor : .secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Copy") {
                store.recopy(item)
            }
            Button(item.isPinned ? "Unpin" : "Pin") {
                store.togglePin(item)
            }
            Divider()
            Button("Delete", role: .destructive) {
                store.delete(item)
            }
        }
    }
}