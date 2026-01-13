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
