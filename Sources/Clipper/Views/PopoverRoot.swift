import SwiftUI

struct PopoverRoot: View {
    @ObservedObject var store: ClipboardStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search clipboard", text: $store.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.regularMaterial)
            .cornerRadius(8)
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider().padding(.vertical, 4)

            // List
            if store.filteredItems.isEmpty {
                VStack {
                    Spacer()
                    Text(store.searchText.isEmpty ? "No clips yet" : "No matches")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(store.filteredItems) { item in
                            ClipRow(item: item, store: store)
                                .onTapGesture {
                                    store.recopy(item)
                                    dismiss()
                                }
                        }
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                Text("\(store.items.count) clips")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Settings…") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .buttonStyle(.borderless)
                Button("Clear All", role: .destructive) {
                    store.clearAll()
                }
                .buttonStyle(.borderless)
                .disabled(store.items.filter { !$0.isPinned }.isEmpty)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .onAppear {
            store.startMonitoring()
        }
    }
}