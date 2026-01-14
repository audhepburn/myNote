import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let note: Note

    @State private var showingDeleteAlert = false
    @State private var selectedImage: NoteImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with date
                Text(note.createdAt, format: .dateTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Status indicators
                HStack(spacing: 8) {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.blue)
                    }
                    if note.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }

                // Content
                Text(note.content)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Images
                if !note.images.isEmpty {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(note.images.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.id) { noteImage in
                            AsyncThumbnailView(noteImage: noteImage)
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .onTapGesture {
                                    selectedImage = noteImage
                                }
                        }
                    }
                }

                // Tags section
                if !note.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(note.tags, id: \.id) { tag in
                                TagChip(tag: tag, note: note)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteNote()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(item: $selectedImage) { noteImage in
            ImageDetailView(noteImage: noteImage)
        }
    }

    private func deleteNote() {
        // Decrement tag use counts
        for tag in note.tags {
            tag.useCount = max(0, tag.useCount - 1)
        }

        // Delete image files
        for noteImage in note.images {
            do {
                try ImageManager.deleteImage(at: noteImage.imagePath)
            } catch {
                print("⚠️ Failed to delete image at \(noteImage.imagePath): \(error)")
            }
        }

        // Delete note
        modelContext.delete(note)
        dismiss()
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: width, height: currentY + lineHeight)
        }
    }
}

// Tag chip with remove button
struct TagChip: View {
    @Environment(\.modelContext) private var modelContext
    let tag: Tag
    let note: Note

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag.name)")
                .font(.subheadline)
                .foregroundStyle(tag.color)

            Button {
                removeTag()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(tag.color.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tag.color.opacity(0.15))
        .clipShape(Capsule())
    }

    private func removeTag() {
        note.tags.removeAll { $0.id == tag.id }
        tag.useCount = max(0, tag.useCount - 1)
    }
}

// Full-screen image view
struct ImageDetailView: View {
    let noteImage: NoteImage
    @Environment(\.dismiss) private var dismiss
    @State private var imageURL: URL?
    @State private var imageLoadError: Error?

    var body: some View {
        NavigationStack {
            Group {
                if let imageURL = imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                } else if let error = imageLoadError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Failed to load image")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            imageLoadError = nil
                            loadImage()
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                loadImage()
            }
        }
    }

    private func loadImage() {
        Task {
            do {
                imageURL = try await noteImage.fullImageURL()
            } catch {
                imageLoadError = error
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, Tag.self, NoteImage.self, configurations: config)
    let note = Note(content: "Test note with some content that should display in full without truncation")
    return NavigationStack {
        NoteDetailView(note: note)
    }
    .modelContainer(container)
}
