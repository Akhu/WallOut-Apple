// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation

/// Captures all environmental signals that influence wallpaper selection.
/// Extend this type (not its callers) when adding new signals like location or mood.
struct WallpaperContext: Equatable, Sendable {
    let timeSlot: TimeSlot
    let appearanceMode: AppearanceMode

    enum AppearanceMode: Equatable, Sendable {
        case light
        case dark
    }
}
