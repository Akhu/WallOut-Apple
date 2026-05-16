// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation

protocol WallpaperApplying: Sendable {
    /// Applies the image at the given local file URL as the desktop wallpaper.
    func apply(imageAt localURL: URL) async throws
}
