import SwiftUI

struct PopoverRoot: View {
    @ObservedObject var store: ClipboardStore
    var onClose: () -> Void = {}
    var onOpenSettings: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                TextField("Search clipboard", text: $store.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.regularMaterial)
            .cornerRadius(8)
            .padding(.horizontal, 8)
            .padding(.top, 8)

            if let error = store.transformError {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        store.clearTransformError()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Dismiss")
                }
                .padding(8)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(6)
                .padding(.horizontal, 8)
                .padding(.top, 6)
            }

            Divider().padding(.vertical, 4)

            if store.filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: store.searchText.isEmpty ? "doc.on.clipboard" : "magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text(
                        store.searchText.isEmpty
                            ? "No clips yet — copy something."
                            : "No matches"
                    )
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(store.filteredItems) { item in
                            ClipRow(item: item, store: store, onCopy: onClose)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.items.count) clips")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if store.secretsSkippedThisSession > 0 {
                        Text("skipped \(store.secretsSkippedThisSession) secrets")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel(
                                "Skipped \(store.secretsSkippedThisSession) secrets this session"
                            )
                    }
                }
                Spacer()
                Button("Settings…") {
                    onOpenSettings()
                }
                .buttonStyle(.borderless)
                .help("Open settings")
                Button("Clear unpinned", role: .destructive) {
                    store.clearUnpinned()
                }
                .buttonStyle(.borderless)
                .disabled(store.unpinnedCount == 0)
                .help("Remove all unpinned clips")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(width: 380, height: 480)
    }
}
