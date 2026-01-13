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
