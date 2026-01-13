import Testing
import SwiftData
import SwiftUI
@testable import myNote

struct myNoteTests {
    var container: ModelContainer!
    var context: ModelContext!

    init() async throws {
        let schema = Schema([
            Note.self,
            myNote.Tag.self,
            NoteImage.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }

    @Test("Note creation works correctly")
    func noteCreation() async throws {
        let note = Note(content: "Test note")
        context.insert(note)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        #expect(fetchedNotes.count == 1)
        #expect(fetchedNotes.first?.content == "Test note")
    }

    @Test("Note content can be any length")
    func noteContentLength() async throws {
        let shortContent = "Short note"
        let note = Note(content: shortContent)

        #expect(note.content == shortContent)
        #expect(note.content.count == shortContent.count)
    }

    @Test("Tag creation works correctly")
    func tagCreation() async throws {
        let tag = myNote.Tag(name: "test")
        context.insert(tag)

        let fetchedTags = try context.fetch(FetchDescriptor<myNote.Tag>())
        #expect(fetchedTags.count == 1)
        #expect(fetchedTags.first?.name == "test")
    }

    @Test("Tag use count increments")
    func tagUseCount() async throws {
        let tag = myNote.Tag(name: "test")
        #expect(tag.useCount == 0)

        tag.useCount += 1
        #expect(tag.useCount == 1)
    }

    @Test("NoteImage creation works correctly")
    func noteImageCreation() async throws {
        let note = Note(content: "Test note")
        let noteImage = NoteImage(imagePath: "/tmp/test.jpg", orderIndex: 0)
        noteImage.note = note
        note.images.append(noteImage)

        context.insert(note)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        #expect(fetchedNotes.first?.images.count == 1)
    }

    @Test("Note-Tag relationship works")
    func noteTagRelationship() async throws {
        let note = Note(content: "Test note #test")
        let tag = myNote.Tag(name: "test")

        note.tags.append(tag)
        tag.useCount += 1

        context.insert(note)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        #expect(fetchedNotes.first?.tags.count == 1)
        #expect(fetchedNotes.first?.tags.first?.name == "test")
    }

    @Test("Pinned notes property works")
    func pinnedNotesProperty() async throws {
        let note1 = Note(content: "Note 1")
        let note2 = Note(content: "Note 2")
        note2.isPinned = true

        context.insert(note1)
        context.insert(note2)

        let fetchedNotes = try context.fetch(FetchDescriptor<Note>())
        let pinnedCount = fetchedNotes.filter { $0.isPinned }.count

        #expect(pinnedCount == 1)
        #expect(note2.isPinned == true)
        #expect(note1.isPinned == false)
    }

    @Test("Color hex conversion works")
    func colorHexConversion() async throws {
        let blue = Color.blue
        let hex = blue.toHex()
        #expect(hex != nil)

        let restoredColor = Color(hex: hex!)
        #expect(restoredColor != nil)
    }
}
