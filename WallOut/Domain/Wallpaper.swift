// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation

struct Wallpaper: Identifiable, Sendable {
    let id: String
    let imageURL: URL
    let thumbnailURL: URL
    let resolution: Resolution
    let tags: [String]
    let source: WallpaperSource

    struct Resolution: Sendable {
        let width: Int
        let height: Int

        var isWidescreen: Bool { width > height }
    }

    enum WallpaperSource: Sendable {
        case wallhaven(id: String)
    }
}
