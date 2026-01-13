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
