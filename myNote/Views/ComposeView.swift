import SwiftUI
import SwiftData
import PhotosUI

struct ComposeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ComposeViewModel()

    @Query private var tags: [Tag]

    var body: some View {
        NavigationStack {
            Form {
                // Content input
                Section {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 100)
                } header: {
                    Text("What's on your mind?")
                } footer: {
                    HStack {
                        Text("\(viewModel.remainingCharacters) remaining")
                            .foregroundStyle(viewModel.remainingCharacters < 0 ? .red : .secondary)
                        Spacer()
                    }
                }

                // Images
                Section {
                    PhotosPicker(
                        selection: $viewModel.selectedItems,
                        maxSelectionCount: 9,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "photo.on.rectangle")
                    }

                    if !viewModel.selectedItems.isEmpty {
                        Text("\(viewModel.selectedItems.count) photo(s) selected")
                            .foregroundStyle(.secondary)
                    }
                }

                // Tags
                Section {
                    Text("Tags will be automatically extracted from #hashtags in your content")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        postNote()
                    }
                    .disabled(!viewModel.canPost || !viewModel.isValidContent)
                }
            }
        }
        .onAppear {
            viewModel.allTags = tags
        }
    }

    private func postNote() {
        let note = Note(content: viewModel.content)

        // Extract and add tags
        let extractedTags = viewModel.extractTags(
            from: viewModel.content,
            availableTags: viewModel.allTags,
            modelContext: modelContext
        )
        note.tags = Array(extractedTags)

        // Update tag use counts
        for tag in extractedTags {
            tag.useCount += 1
        }

        // Save images (placeholder for now - full implementation in Task 13)
        // TODO: Process selectedItems and save images

        modelContext.insert(note)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, Tag.self, configurations: config)
    return ComposeView()
        .modelContainer(container)
}
