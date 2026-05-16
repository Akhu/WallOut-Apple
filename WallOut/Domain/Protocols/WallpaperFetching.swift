// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation

protocol WallpaperFetching: Sendable {
    /// Returns a wallpaper appropriate for the given context.
    /// Implementations may use context to adjust query, tags, or tone.
    func fetchWallpaper(for context: WallpaperContext) async throws -> Wallpaper

    /// Downloads the full-resolution image data for a wallpaper.
    func downloadImage(for wallpaper: Wallpaper) async throws -> URL
}
