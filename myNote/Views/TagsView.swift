import SwiftUI
import SwiftData

struct TagsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.useCount, order: .reverse) private var tags: [Tag]
    @State private var selectedTag: Tag?

    var body: some View {
        NavigationStack {
            Group {
                if tags.isEmpty {
                    ContentUnavailableView {
                        Label("No Tags", systemImage: "tag")
                    } description: {
                        Text("Tags will be created when you add #hashtags to your notes")
                    }
                } else {
                    List {
                        ForEach(tags, id: \.id) { tag in
                            Button {
                                selectedTag = tag
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 12, height: 12)

                                    Text(tag.name)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Text("\(tag.useCount)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteTags)
                    }
                }
            }
            .navigationTitle("Tags")
        }
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            let tag = tags[index]
            if tag.useCount == 0 {
                modelContext.delete(tag)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tag.self, configurations: config)
    return TagsView()
        .modelContainer(container)
}
