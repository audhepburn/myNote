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
