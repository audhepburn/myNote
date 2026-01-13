import SwiftUI
import SwiftData

struct NoteCell: View {
    let note: Note
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Time
            Text(note.createdAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Content
            Text(note.content)
                .font(.body)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            // Images (thumbnails)
            if !note.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(note.images.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.id) { noteImage in
                            AsyncThumbnailView(noteImage: noteImage)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            // Tags
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(note.tags, id: \.id) { tag in
                            Text("#\(tag.name)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tag.color.opacity(0.2))
                                .foregroundStyle(tag.color)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Actions
            HStack(spacing: 16) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: note.isFavorite ? "star.fill" : "star")
                }

                Button {
                    togglePin()
                } label: {
                    Image(systemName: note.isPinned ? "pin.fill" : "pin")
                }

                Spacer()

                Button {
                    deleteNote()
                } label: {
                    Image(systemName: "trash")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func toggleFavorite() {
        note.isFavorite.toggle()
    }

    private func togglePin() {
        note.isPinned.toggle()
    }

    private func deleteNote() {
        modelContext.delete(note)
    }
}

struct AsyncThumbnailView: View {
    let noteImage: NoteImage
    @State private var imageURL: URL?

    var body: some View {
        Group {
            if let imageURL = imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .task {
            do {
                imageURL = try await noteImage.thumbnailURL()
            } catch {
                print("Failed to load thumbnail: \(error)")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    let note = Note(content: "Test note with some content that spans multiple lines to see how it looks in the cell")
    return NoteCell(note: note)
        .modelContainer(container)
}
