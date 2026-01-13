import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    @State private var showingCompose = false

    var pinnedNotes: [Note] {
        notes.filter { $0.isPinned }
    }

    var regularNotes: [Note] {
        notes.filter { !$0.isPinned }
    }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView {
                        Label("No Notes", systemImage: "text.badge.xmark")
                    } description: {
                        Text("Create your first note to get started")
                    } actions: {
                        Button("Create Note") {
                            showingCompose = true
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Pinned section
                            if !pinnedNotes.isEmpty {
                                Section {
                                    ForEach(pinnedNotes, id: \.id) { note in
                                        NoteCell(note: note)
                                    }
                                } header: {
                                    Text("Pinned")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                }
                            }

                            // Regular notes
                            ForEach(regularNotes, id: \.id) { note in
                                NoteCell(note: note)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        // Trigger refresh
                    }
                }
            }
            .navigationTitle("Timeline")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCompose = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCompose) {
                ComposeView()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    return TimelineView()
        .modelContainer(container)
}
