import Foundation

/// Translates WallpaperContext into a WallHaven query and maps results to domain models.
/// Owns the image download cache to avoid redundant network calls.
actor WallHavenRepository: WallpaperFetching {
    private let api: WallHavenAPI
    private let imageCache: WallpaperImageCache

    init(api: WallHavenAPI, imageCache: WallpaperImageCache) {
        self.api = api
        self.imageCache = imageCache
    }

    func fetchWallpaper(for context: WallpaperContext) async throws -> Wallpaper {
        let query = WHSearchQuery.from(context: context)
        let response = try await api.search(query: query)
        guard let first = response.data.first else {
            throw WallHavenError.noResultsFound
        }
        return try first.toDomain()
    }

    func downloadImage(for wallpaper: Wallpaper) async throws -> URL {
        if let cached = await imageCache.localURL(for: wallpaper.id) {
            return cached
        }
        let data = try await api.downloadData(from: wallpaper.imageURL)
        return try await imageCache.store(data: data, wallpaperID: wallpaper.id, fileExtension: wallpaper.imageURL.pathExtension)
    }
}

// MARK: - Context → query mapping

private extension WHSearchQuery {
    static func from(context: WallpaperContext) -> WHSearchQuery {
        var query = WHSearchQuery()
        query.sorting = .random
        query.atleast = "2560x1440"
        query.ratios = "16x9"
        query.categories = .general

        switch context.timeSlot {
        case .dawn:
            query.query = "sunrise dawn nature landscape"
        case .morning:
            query.query = "morning light city nature"
        case .afternoon:
            query.query = "landscape bright sunny"
        case .evening:
            query.query = "sunset golden hour"
        case .night:
            query.query = "night sky stars city night"
        }

        if context.appearanceMode == .dark {
            query.query += " dark"
        }

        return query
    }
}
