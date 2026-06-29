// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation

/// User-tunable wallpaper preferences, sourced from the same UserDefaults keys
/// that `SettingsView` binds to via @AppStorage.
///
/// Loaded fresh on each fetch so changes made in Settings take effect on the
/// next wallpaper update without restarting the app.
struct WallpaperPreferences: Sendable, Equatable {
    var minResolution: String
    var categories: WHSearchQuery.Categories

    static let `default` = WallpaperPreferences(
        minResolution: "2560x1440",
        categories: .general
    )

    static func load(from defaults: UserDefaults = .standard) -> WallpaperPreferences {
        let minResolution = defaults.string(forKey: "minResolution") ?? `default`.minResolution

        var categories: WHSearchQuery.Categories = []
        // `categoriesGeneral` defaults to true in SettingsView, but UserDefaults
        // holds no value until the user toggles it — mirror that default here.
        if defaults.object(forKey: "categoriesGeneral") == nil || defaults.bool(forKey: "categoriesGeneral") {
            categories.insert(.general)
        }
        if defaults.bool(forKey: "categoriesAnime") {
            categories.insert(.anime)
        }
        if defaults.bool(forKey: "categoriesPeople") {
            categories.insert(.people)
        }
        // WallHaven rejects an empty category mask; fall back to General.
        if categories.isEmpty {
            categories = .general
        }

        return WallpaperPreferences(minResolution: minResolution, categories: categories)
    }
}
