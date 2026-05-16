import Foundation

/// Filesystem cache for downloaded wallpaper images.
/// Stored in Application Support/WallOut/Wallpapers/.
actor WallpaperImageCache {
    private let directory: URL
    private var index: [String: URL] = [:]

    init() throws {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = appSupport.appendingPathComponent("WallOut/Wallpapers", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        directory = dir
        // Populate index from existing files on disk
        let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        var built: [String: URL] = [:]
        for url in contents {
            built[url.deletingPathExtension().lastPathComponent] = url
        }
        index = built
    }

    func localURL(for wallpaperID: String) -> URL? {
        index[wallpaperID]
    }

    func store(data: Data, wallpaperID: String, fileExtension: String) throws -> URL {
        let ext = fileExtension.isEmpty ? "jpg" : fileExtension
        let fileURL = directory.appendingPathComponent("\(wallpaperID).\(ext)")
        try data.write(to: fileURL, options: .atomic)
        index[wallpaperID] = fileURL
        return fileURL
    }

    func evictAll() throws {
        for url in index.values {
            try? FileManager.default.removeItem(at: url)
        }
        index.removeAll()
    }

}
