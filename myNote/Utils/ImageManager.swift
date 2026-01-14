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

    static func deleteImage(at path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
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
