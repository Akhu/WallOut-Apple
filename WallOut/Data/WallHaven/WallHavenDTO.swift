// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation

// MARK: - Search response

struct WHSearchResponse: Decodable, Sendable {
    let data: [WHWallpaper]
    let meta: WHMeta
}

struct WHMeta: Decodable, Sendable {
    let total: Int
    let perPage: Int
    let currentPage: Int
    let lastPage: Int
    let seed: String?

    enum CodingKeys: String, CodingKey {
        case total
        case perPage  = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case seed
    }
}

struct WHWallpaper: Decodable, Sendable {
    let id: String
    let url: String
    let shortURL: String
    let views: Int
    let favorites: Int
    let source: String
    let purity: String
    let category: String
    let dimensionX: Int
    let dimensionY: Int
    let fileSize: Int
    let fileType: String
    let createdAt: String
    let colors: [String]
    let path: String
    let thumbs: WHThumb
    let tags: [WHTag]?

    enum CodingKeys: String, CodingKey {
        case id, url, views, favorites, source, purity, category, colors, path, thumbs, tags
        case shortURL    = "short_url"
        case dimensionX  = "dimension_x"
        case dimensionY  = "dimension_y"
        case fileSize    = "file_size"
        case fileType    = "file_type"
        case createdAt   = "created_at"
    }
}

struct WHThumb: Decodable, Sendable {
    let large: String
    let original: String
    let small: String
}

struct WHTag: Decodable, Sendable {
    let id: Int
    let name: String
    let alias: String
    let categoryID: Int
    let category: String
    let purity: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, alias, category, purity
        case categoryID  = "category_id"
        case createdAt   = "created_at"
    }
}

// MARK: - Domain mapping

extension WHWallpaper {
    func toDomain() throws -> Wallpaper {
        guard let imageURL = URL(string: path),
              let thumbURL = URL(string: thumbs.large) else {
            throw WallHavenError.invalidWallpaperData(id: id)
        }
        return Wallpaper(
            id: id,
            imageURL: imageURL,
            thumbnailURL: thumbURL,
            resolution: Wallpaper.Resolution(width: dimensionX, height: dimensionY),
            tags: tags?.map(\.name) ?? [],
            source: .wallhaven(id: id)
        )
    }
}

enum WallHavenError: LocalizedError {
    case invalidAPIKey
    case rateLimited
    case noResultsFound
    case invalidWallpaperData(id: String)
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:              return "Invalid WallHaven API key"
        case .rateLimited:                return "WallHaven rate limit reached"
        case .noResultsFound:             return "No wallpapers found for the current context"
        case .invalidWallpaperData(let id): return "Malformed data for wallpaper \(id)"
        case .httpError(let code):        return "HTTP \(code) from WallHaven"
        }
    }
}
