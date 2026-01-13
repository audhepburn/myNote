# Timeline Notes App Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a personal timeline notes app (iOS 17+, SwiftUI + SwiftData) similar to X/Twitter, supporting short notes, multi-tags, multi-images, timeline browsing, pin/favorite, statistics, and data export.

**Architecture:** MVVM with SwiftUI views, SwiftData for persistence (Note, Tag, NoteImage models), pure local storage with image files in Documents directory.

**Tech Stack:** SwiftUI, SwiftData (iOS 17+), PhotosPicker, Charts, Xcode 15+

---

## Task 1: Create SwiftData Models Directory Structure

**Files:**
- Create directory: `myNote/Models/`

**Step 1: Create Models directory**

```bash
mkdir -p myNote/Models
```

**Step 2: Verify directory created**

Run: `ls -la myNote/Models`
Expected: Empty directory listing

**Step 3: Commit**

```bash
git add myNote/Models
git commit -m "chore: add Models directory structure"
```

---

## Task 2: Implement Note Model

**Files:**
- Create: `myNote/Models/Note.swift`

**Step 1: Create Note.swift with SwiftData model**

```swift
import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var content: String
    var createdAt: Date
    var isPinned: Bool
    var isFavorite: Bool
    var images: [NoteImage]
    var tags: [Tag]

    init(content: String) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.isPinned = false
        self.isFavorite = false
        self.images = []
        self.tags = []
    }
}
```

**Step 2: Add file to Xcode project**

Open `myNote.xcodeproj`, drag `Note.swift` to the `myNote` target in the project navigator.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Models/Note.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add Note SwiftData model"
```

---

## Task 3: Implement Tag Model

**Files:**
- Create: `myNote/Models/Tag.swift`

**Step 1: Create Tag.swift with SwiftData model**

```swift
import Foundation
import SwiftData
import SwiftUI

@Model
final class Tag {
    var id: UUID
    var name: String
    var colorHex: String
    var useCount: Int

    init(name: String, color: Color = .blue) {
        self.id = UUID()
        self.name = name
        self.colorHex = color.toHex() ?? "#007AFF"
        self.useCount = 0
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}
```

**Step 2: Add file to Xcode project**

Open `myNote.xcodeproj`, drag `Tag.swift` to the `myNote` target.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Models/Tag.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add Tag SwiftData model with Color helpers"
```

---

## Task 4: Implement NoteImage Model

**Files:**
- Create: `myNote/Models/NoteImage.swift`

**Step 1: Create NoteImage.swift with SwiftData model**

```swift
import Foundation
import SwiftData

@Model
final class NoteImage {
    var id: UUID
    var imagePath: String
    var orderIndex: Int
    var note: Note?

    init(imagePath: String, orderIndex: Int) {
        self.id = UUID()
        self.imagePath = imagePath
        self.orderIndex = orderIndex
        self.note = nil
    }
}
```

**Step 2: Add file to Xcode project**

Open `myNote.xcodeproj`, drag `NoteImage.swift` to the `myNote` target.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Models/NoteImage.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add NoteImage SwiftData model"
```

---

## Task 5: Configure SwiftData Container in App

**Files:**
- Modify: `myNote/myNoteApp.swift`

**Step 1: Update myNoteApp.swift with SwiftData container**

```swift
import SwiftUI
import SwiftData

@main
struct myNoteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            Tag.self,
            NoteImage.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Step 2: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add myNote/myNoteApp.swift
git commit -m "feat: configure SwiftData container with all models"
```

---

## Task 6: Create Views Directory Structure

**Files:**
- Create directory: `myNote/Views/`

**Step 1: Create Views directory**

```bash
mkdir -p myNote/Views
```

**Step 2: Verify directory created**

Run: `ls -la myNote/Views`
Expected: Empty directory listing

**Step 3: Commit**

```bash
git add myNote/Views
git commit -m "chore: add Views directory structure"
```

---

## Task 7: Implement NoteCell Component

**Files:**
- Create: `myNote/Views/NoteCell.swift`

**Step 1: Create NoteCell.swift**

```swift
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
                            AsyncImage(url: noteImage.thumbnailURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
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

extension NoteImage {
    var thumbnailURL: URL? {
        URL(fileURLWithPath: imagePath)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    let note = Note(content: "Test note with some content that spans multiple lines to see how it looks in the cell")
    return NoteCell(note: note)
        .modelContainer(container)
}
```

**Step 2: Add to Xcode project**

Drag `NoteCell.swift` to the `myNote` target.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Views/NoteCell.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add NoteCell component with actions"
```

---

## Task 8: Implement TimelineView

**Files:**
- Create: `myNote/Views/TimelineView.swift`

**Step 1: Create TimelineView.swift**

```swift
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
```

**Step 2: Add to Xcode project**

Drag `TimelineView.swift` to the `myNote` target.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Views/TimelineView.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add TimelineView with pinned/regular sections"
```

---

## Task 9: Implement ComposeView

**Files:**
- Create: `myNote/Views/ComposeView.swift`
- Create: `myNote/ViewModels/ComposeViewModel.swift`

**Step 1: Create ViewModels directory**

```bash
mkdir -p myNote/ViewModels
```

**Step 2: Create ComposeViewModel.swift**

```swift
import Foundation
import SwiftUI
import PhotosUI
import SwiftData

@Observable
class ComposeViewModel {
    var content = ""
    var selectedItems: [PhotosPickerItem] = []
    var selectedTags: Set<Tag> = []
    var allTags: [Tag] = []

    private let maxContentLength = 500
    private let maxImages = 9

    var remainingCharacters: Int {
        maxContentLength - content.count
    }

    var canPost: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isValidContent: Bool {
        content.count <= maxContentLength
    }

    func extractTags(from text: String, availableTags: [Tag], modelContext: ModelContext) -> Set<Tag> {
        var tags: Set<Tag> = []
        let pattern = "#(\\w+)"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return tags
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)

        for match in matches {
            if let range = Range(match.range(at: 1), in: text) {
                let tagName = String(text[range])

                // Find existing tag or create new
                if let existingTag = availableTags.first(where: { $0.name == tagName }) {
                    tags.insert(existingTag)
                } else {
                    let newTag = Tag(name: tagName)
                    modelContext.insert(newTag)
                    tags.insert(newTag)
                }
            }
        }

        return tags
    }
}
```

**Step 3: Create ComposeView.swift**

```swift
import SwiftUI
import SwiftData
import PhotosPicker

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
```

**Step 4: Add to Xcode project**

Drag both files to the `myNote` target.

**Step 5: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add myNote/Views/ComposeView.swift myNote/ViewModels/ComposeViewModel.swift myNote/ViewModels myNote.xcodeproj/project.pbxproj
git commit -m "feat: add ComposeView with tag extraction"
```

---

## Task 10: Implement TagsView

**Files:**
- Create: `myNote/Views/TagsView.swift`

**Step 1: Create TagsView.swift**

```swift
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
```

**Step 2: Add to Xcode project**

Drag `TagsView.swift` to the `myNote` target.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Views/TagsView.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add TagsView with usage count"
```

---

## Task 11: Implement StatsView

**Files:**
- Create: `myNote/Views/StatsView.swift`

**Step 1: Create StatsView.swift**

```swift
import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Query private var tags: [Tag]

    private var now: Date { Date() }
    private var weekAgo: Date { Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now }
    private var monthAgo: Date { Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now }

    var totalNotes: Int {
        notes.count
    }

    var weekNotes: Int {
        notes.filter { $0.createdAt > weekAgo }.count
    }

    var topTags: [Tag] {
        Array(tags.sorted(by: { $0.useCount > $1.useCount }).prefix(5))
    }

    var totalImages: Int {
        notes.reduce(0) { $0 + $1.images.count }
    }

    var avgImagesPerNote: Double {
        guard !notes.isEmpty else { return 0 }
        return Double(totalImages) / Double(notes.count)
    }

    var last30DaysData: [(Date, Int)] {
        let calendar = Calendar.current
        var data: [Date: Int] = [:]

        // Initialize all days with 0
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayStart = calendar.startOfDay(for: date)
                data[dayStart] = 0
            }
        }

        // Count notes per day
        for note in notes where note.createdAt > monthAgo {
            let dayStart = calendar.startOfDay(for: note.createdAt)
            data[dayStart, default: 0] += 1
        }

        return data.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Total notes
                    StatCard(title: "Total Notes", value: "\(totalNotes)", icon: "text.bubble")

                    // This week
                    StatCard(title: "This Week", value: "\(weekNotes)", icon: "calendar")

                    // Images
                    StatCard(title: "Total Images", value: "\(totalImages)", icon: "photo")
                    StatCard(title: "Avg Images/Note", value: String(format: "%.1f", avgImagesPerNote), icon: "chart.bar")

                    // Top tags
                    if !topTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Tags")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(topTags, id: \.id) { tag in
                                HStack {
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 10, height: 10)

                                    Text(tag.name)
                                        .font(.body)

                                    Spacer()

                                    Text("\(tag.useCount)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Activity chart
                    if !last30DaysData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last 30 Days")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(last30DaysData, id: \.0) { item in
                                BarMark(
                                    x: .value("Date", item.0),
                                    y: .value("Notes", item.1)
                                )
                            }
                            .frame(height: 150)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 40)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, Tag.self, configurations: config)
    return StatsView()
        .modelContainer(container)
}
```

**Step 2: Add to Xcode project**

Drag `StatsView.swift` to the `myNote` target.

**Step 3: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Views/StatsView.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add StatsView with charts and metrics"
```

---

## Task 12: Implement SettingsView and Export

**Files:**
- Create: `myNote/Views/SettingsView.swift`
- Create: `myNote/Utils/ExportManager.swift`

**Step 1: Create Utils directory**

```bash
mkdir -p myNote/Utils
```

**Step 2: Create ExportManager.swift**

```swift
import Foundation
import SwiftData

struct ExportManager {
    static func exportToJSON(modelContext: ModelContext) throws -> URL {
        let notesDescriptor = FetchDescriptor<Note>()
        let allNotes = try modelContext.fetch(notesDescriptor)

        let tagsDescriptor = FetchDescriptor<Tag>()
        let allTags = try modelContext.fetch(tagsDescriptor)

        let exportData = ExportData(
            notes: allNotes.map { note in
                ExportNote(
                    id: note.id.uuidString,
                    content: note.content,
                    createdAt: note.createdAt,
                    isPinned: note.isPinned,
                    isFavorite: note.isFavorite,
                    tagNames: note.tags.map { $0.name },
                    imagePaths: note.images.sorted(by: { $0.orderIndex < $1.orderIndex }).map { $0.imagePath }
                )
            },
            tags: allTags.map { tag in
                ExportTag(
                    name: tag.name,
                    colorHex: tag.colorHex,
                    useCount: tag.useCount
                )
            },
            exportedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(exportData)

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("timeline-notes")
            .appendingPathExtension("json")

        try data.write(to: tempURL)
        return tempURL
    }

    static func exportToMarkdown(modelContext: ModelContext) throws -> URL {
        let notesDescriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let allNotes = try modelContext.fetch(notesDescriptor)

        let calendar = Calendar.current
        var markdown = "# Timeline Notes\n\n"
        markdown += "Exported on: \(Date())\n\n---\n\n"

        var currentDate: Date?
        for note in allNotes {
            let noteDate = calendar.startOfDay(for: note.createdAt)

            if currentDate != noteDate {
                markdown += "\n## \(noteDate.formatted(date: .long, time: .omitted))\n\n"
                currentDate = noteDate
            }

            // Tags
            if !note.tags.isEmpty {
                let tagString = note.tags.map { "#\($0.name)" }.joined(separator: " ")
                markdown += "\(tagString) "
            }

            // Content
            markdown += note.content + "\n"

            // Images
            for noteImage in note.images.sorted(by: { $0.orderIndex < $1.orderIndex }) {
                markdown += "![Image](\(noteImage.imagePath))\n"
            }

            markdown += "\n"
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("timeline-notes")
            .appendingPathExtension("md")

        try markdown.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }
}

struct ExportData: Codable {
    let notes: [ExportNote]
    let tags: [ExportTag]
    let exportedAt: Date
}

struct ExportNote: Codable {
    let id: String
    let content: String
    let createdAt: Date
    let isPinned: Bool
    let isFavorite: Bool
    let tagNames: [String]
    let imagePaths: [String]
}

struct ExportTag: Codable {
    let name: String
    let colorHex: String
    let useCount: Int
}
```

**Step 3: Create SettingsView.swift**

```swift
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var jsonExportURL: URL?
    @State private var markdownExportURL: URL?
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        NavigationStack {
            List {
                // Export section
                Section {
                    Button {
                        exportJSON()
                    } label: {
                        Label("Export as JSON", systemImage: "doc.text")
                    }

                    Button {
                        exportMarkdown()
                    } label: {
                        Label("Export as Markdown", systemImage: "doc.plaintext")
                    }
                } header: {
                    Text("Data Export")
                }

                // App info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Data Storage")
                        Spacer()
                        Text("Local Only")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareItems.first as? URL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    private func exportJSON() {
        do {
            let url = try ExportManager.exportToJSON(modelContext: modelContext)
            shareItems = [url]
            showingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func exportMarkdown() {
        do {
            let url = try ExportManager.exportToMarkdown(modelContext: modelContext)
            shareItems = [url]
            showingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, Tag.self, configurations: config)
    return SettingsView()
        .modelContainer(container)
}
```

**Step 4: Add to Xcode project**

Drag both files to the `myNote` target.

**Step 5: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add myNote/Views/SettingsView.swift myNote/Utils/ExportManager.swift myNote/Utils myNote.xcodeproj/project.pbxproj
git commit -m "feat: add SettingsView with JSON/Markdown export"
```

---

## Task 13: Implement Main TabView Navigation

**Files:**
- Modify: `myNote/ContentView.swift`

**Step 1: Replace ContentView.swift with TabView**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "timeline")
                }

            TagsView()
                .tabItem {
                    Label("Tags", systemImage: "tag")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
```

**Step 2: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 3: Run app to verify all tabs work**

Run: `xcrun simctl boot "iPhone 16" 2>/dev/null || true`
Run: `xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/myNote-*/Build/Products/Debug-iphonesimulator/myNote.app`
Run: `xcrun simctl launch --console booted com.example.myNote`

Expected: App launches with 4 tabs

**Step 4: Commit**

```bash
git add myNote/ContentView.swift
git commit -m "feat: add main TabView navigation"
```

---

## Task 14: Implement Image Handling Service

**Files:**
- Create: `myNote/Utils/ImageManager.swift`

**Step 1: Create ImageManager.swift**

```swift
import Foundation
import UIKit
import PhotosUI

struct ImageManager {
    static let imagesDirectory = "images"

    static func createImagesDirectory() throws -> URL {
        let fm = FileManager.default
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "ImageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found"])
        }

        let imagesURL = documentsURL.appendingPathComponent(imagesDirectory)

        if !fm.fileExists(atPath: imagesURL.path) {
            try fm.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        }

        return imagesURL
    }

    static func saveImage(_ data: Data) throws -> URL {
        let imagesURL = try createImagesDirectory()
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesURL.appendingPathComponent(filename)

        // Compress image
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }

        let targetSize = CGSize(width: 1080, height: 1080)
        let scaled = image.aspectFitted(to: targetSize)

        guard let jpegData = scaled.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create JPEG"])
        }

        try jpegData.write(to: fileURL)
        return fileURL
    }

    static func deleteImage(at path: String) {
        let fm = FileManager.default
        try? fm.removeItem(atPath: path)
    }

    static func loadThumbnail(from path: String, size: CGSize = CGSize(width: 160, height: 160)) async throws -> URL {
        let fileURL = URL(fileURLWithPath: path)

        // Check if thumbnail exists in cache
        let cacheKey = fileURL.lastPathComponent
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Thumbnails")
            .appendingPathComponent(cacheKey)

        if let cacheURL = cacheURL, FileManager.default.fileExists(atPath: cacheURL.path) {
            return cacheURL
        }

        // Generate thumbnail
        guard let image = UIImage(contentsOfFile: path) else {
            throw NSError(domain: "ImageManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
        }

        let thumbnailSize = CGSize(width: size.width * 3, height: size.height * 3) // Retina
        let thumbnail = image.aspectFilled(to: thumbnailSize)

        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create thumbnail"])
        }

        let thumbnailsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Thumbnails")

        try? FileManager.default.createDirectory(at: thumbnailsURL!, withIntermediateDirectories: true)

        let finalCacheURL = thumbnailsURL!.appendingPathComponent(cacheKey)
        try thumbnailData.write(to: finalCacheURL)

        return finalCacheURL
    }
}

extension UIImage {
    func aspectFitted(to size: CGSize) -> UIImage {
        let scale = min(size.width / self.size.width, size.height / self.size.height)
        let targetSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func aspectFilled(to size: CGSize) -> UIImage {
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let targetSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        let originX = (targetSize.width - size.width) / 2
        let originY = (targetSize.height - size.height) / 2

        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: CGPoint(x: -originX, y: -originY), size: targetSize))
        }
    }
}
```

**Step 2: Update NoteImage with thumbnail support**

Modify `myNote/Models/NoteImage.swift`:

```swift
import Foundation
import SwiftData

@Model
final class NoteImage {
    var id: UUID
    var imagePath: String
    var orderIndex: Int
    var note: Note?

    init(imagePath: String, orderIndex: Int) {
        self.id = UUID()
        self.imagePath = imagePath
        self.orderIndex = orderIndex
        self.note = nil
    }

    func thumbnailURL() async throws -> URL {
        try await ImageManager.loadThumbnail(from: imagePath)
    }
}
```

**Step 3: Add to Xcode project**

Drag `ImageManager.swift` to the `myNote` target.

**Step 4: Build to verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add myNote/Utils/ImageManager.swift myNote/Models/NoteImage.swift myNote.xcodeproj/project.pbxproj
git commit -m "feat: add ImageManager with compression and thumbnails"
```

---

## Task 15: Wire Up Image Handling in ComposeView

**Files:**
- Modify: `myNote/Views/ComposeView.swift`

**Step 1: Update ComposeView to handle images**

Replace the `postNote()` function with:

```swift
    private func postNote() {
        Task {
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

            // Process images
            for (index, item) in viewModel.selectedItems.enumerated() {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let imageData = uiImage.jpegData(compressionQuality: 1.0) {

                    do {
                        let imageURL = try ImageManager.saveImage(imageData)
                        let noteImage = NoteImage(imagePath: imageURL.path, orderIndex: index)
                        noteImage.note = note
                        note.images.append(noteImage)
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                }
            }

            modelContext.insert(note)
            dismiss()
        }
    }
```

**Step 2: Build and verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add myNote/Views/ComposeView.swift
git commit -m "feat: wire up image handling in ComposeView"
```

---

## Task 16: Add Async Image Loading to NoteCell

**Files:**
- Modify: `myNote/Views/NoteCell.swift`

**Step 1: Update NoteCell with async image loading**

Replace the images section with:

```swift
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
```

**Step 2: Add AsyncThumbnailView component**

Add to the bottom of NoteCell.swift:

```swift
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
```

**Step 3: Build and verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add myNote/Views/NoteCell.swift
git commit -m "feat: add async thumbnail loading to NoteCell"
```

---

## Task 17: Add Swipe Actions to Timeline

**Files:**
- Modify: `myNote/Views/TimelineView.swift`

**Step 1: Add swipe actions to NoteCell**

Add `.swipeActions` modifier after the NoteCard in TimelineView:

```swift
                            // Regular notes
                            ForEach(regularNotes, id: \.id) { note in
                                NoteCell(note: note)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            modelContext.delete(note)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            note.isFavorite.toggle()
                                        } label: {
                                            Label(note.isFavorite ? "Unfavorite" : "Favorite", systemImage: note.isFavorite ? "star.slash" : "star")
                                        }
                                        .tint(.yellow)

                                        Button {
                                            note.isPinned.toggle()
                                        } label: {
                                            Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                                        }
                                        .tint(.blue)
                                    }
                            }
```

**Step 2: Build and verify**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add myNote/Views/TimelineView.swift
git commit -m "feat: add swipe actions to timeline notes"
```

---

## Task 18: Add Dark Mode Support

**Files:**
- Modify: All view files to use adaptive colors

**Step 1: Verify all views use system colors**

The views already use `.foregroundStyle(.secondary)`, `.background(.regularMaterial)` which automatically adapt.

**Step 2: Verify custom Tag colors work in dark mode**

Tag colors use opacity (`.opacity(0.2)`) which already works in dark mode.

**Step 3: Test dark mode in simulator**

Run: `xcrun simctl ui "iPhone 16" appearance dark`

**Step 4: Commit (no changes needed, just verification)**

```bash
git commit --allow-empty -m "test: verify dark mode support"
```

---

## Task 19: Write Unit Tests

**Files:**
- Modify: `myNoteTests/myNoteTests.swift`

**Step 1: Add model tests**

Replace `myNoteTests.swift` with:

```swift
import XCTest
import SwiftData
@testable import myNote

final class myNoteTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            Note.self,
            Tag.self,
            NoteImage.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }

    override func tearDown() async throws {
        container = nil
        context = nil
    }

    func testNoteCreation() throws {
        let note = Note(content: "Test note")
        context.insert(note)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(fetchedNotes.count, 1)
        XCTAssertEqual(fetchedNotes.first?.content, "Test note")
    }

    func testNoteContentLengthLimit() throws {
        let longContent = String(repeating: "a", count: 501)
        let note = Note(content: longContent)

        XCTAssertTrue(note.content.count <= 500, "Note content should be limited to 500 characters")
    }

    func testTagCreation() throws {
        let tag = Tag(name: "test")
        context.insert(tag)

        let fetchedTags = try context.fetch(FetchDescriptor<Tag>())
        XCTAssertEqual(fetchedTags.count, 1)
        XCTAssertEqual(fetchedTags.first?.name, "test")
    }

    func testTagUseCount() throws {
        let tag = Tag(name: "test")
        XCTAssertEqual(tag.useCount, 0)

        tag.useCount += 1
        XCTAssertEqual(tag.useCount, 1)
    }

    func testNoteImageCreation() throws {
        let note = Note(content: "Test note")
        let noteImage = NoteImage(imagePath: "/tmp/test.jpg", orderIndex: 0)
        noteImage.note = note
        note.images.append(noteImage)

        context.insert(note)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(fetchedNotes.first?.images.count, 1)
    }

    func testNoteTagRelationship() throws {
        let note = Note(content: "Test note #test")
        let tag = Tag(name: "test")

        note.tags.append(tag)
        tag.useCount += 1

        context.insert(note)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(fetchedNotes.first?.tags.count, 1)
        XCTAssertEqual(fetchedNotes.first?.tags.first?.name, "test")
    }

    func testPinnedNotesSortFirst() throws {
        let note1 = Note(content: "Note 1")
        let note2 = Note(content: "Note 2")
        note2.isPinned = true

        context.insert(note1)
        context.insert(note2)

        let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.isPinned, order: .reverse)])
        let fetchedNotes = try context.fetch(descriptor)

        XCTAssertTrue(fetchedNotes.first?.isPinned ?? false)
    }

    func testColorHexConversion() throws {
        let blue = Color.blue
        let hex = blue.toHex()
        XCTAssertNotNil(hex)

        let restoredColor = Color(hex: hex!)
        XCTAssertNotNil(restoredColor)
    }
}
```

**Step 2: Run tests**

Run: `xcodebuild test -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: All tests pass

**Step 3: Commit**

```bash
git add myNoteTests/myNoteTests.swift
git commit -m "test: add unit tests for models"
```

---

## Task 20: Final Integration Test

**Files:**
- All files

**Step 1: Clean build**

Run: `xcodebuild -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16' clean build`
Expected: BUILD SUCCEEDED

**Step 2: Run all tests**

Run: `xcodebuild test -scheme myNote -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: All tests pass

**Step 3: Manual smoke test checklist**

Run the app and verify:
- [ ] Can create a note
- [ ] Tags are extracted from #hashtags
- [ ] Can pin/favorite notes
- [ ] Can delete notes
- [ ] Timeline shows pinned notes first
- [ ] Can add images to notes
- [ ] Images display as thumbnails
- [ ] Tags view shows all tags with counts
- [ ] Stats view displays metrics
- [ ] Can export to JSON
- [ ] Can export to Markdown
- [ ] Dark mode works
- [ ] Swipe actions work

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete timeline notes app implementation"
```

---

## Summary

This implementation plan covers:

1. **SwiftData Models**: Note, Tag, NoteImage with relationships
2. **Views**: Timeline, Compose, Tags, Stats, Settings
3. **Features**: Pin/favorite, swipe actions, tag extraction
4. **Image Handling**: Compression, thumbnails, async loading
5. **Export**: JSON and Markdown formats
6. **Testing**: Unit tests for models
7. **UI**: Tab navigation, dark mode, swipe actions

**Total Tasks**: 20
**Estimated Time**: 2-3 hours for implementation
**Branch**: `feature/timeline-notes`
**Worktree**: `.worktrees/feature/timeline-notes`
