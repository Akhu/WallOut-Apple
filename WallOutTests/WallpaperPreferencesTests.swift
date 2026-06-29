// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Testing
import Foundation
@testable import WallOut

@Suite("WallpaperPreferences")
struct WallpaperPreferencesTests {
    private func makeDefaults() -> UserDefaults {
        // A throwaway, isolated domain so tests never touch the real app defaults.
        let suiteName = "WallpaperPreferencesTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test("Empty defaults fall back to General + default resolution")
    func emptyDefaultsUseFallback() {
        let prefs = WallpaperPreferences.load(from: makeDefaults())
        #expect(prefs == .default)
        #expect(prefs.categories == .general)
        #expect(prefs.minResolution == "2560x1440")
    }

    @Test("Stored resolution is honored")
    func storedResolution() {
        let defaults = makeDefaults()
        defaults.set("3840x2160", forKey: "minResolution")
        let prefs = WallpaperPreferences.load(from: defaults)
        #expect(prefs.minResolution == "3840x2160")
    }

    @Test("Category toggles map to the WallHaven mask")
    func categoryMapping() {
        let defaults = makeDefaults()
        defaults.set(true, forKey: "categoriesGeneral")
        defaults.set(true, forKey: "categoriesAnime")
        defaults.set(false, forKey: "categoriesPeople")
        let prefs = WallpaperPreferences.load(from: defaults)
        #expect(prefs.categories.contains(.general))
        #expect(prefs.categories.contains(.anime))
        #expect(!prefs.categories.contains(.people))
    }

    @Test("All categories disabled falls back to General")
    func emptySelectionFallsBack() {
        let defaults = makeDefaults()
        defaults.set(false, forKey: "categoriesGeneral")
        defaults.set(false, forKey: "categoriesAnime")
        defaults.set(false, forKey: "categoriesPeople")
        let prefs = WallpaperPreferences.load(from: defaults)
        #expect(prefs.categories == .general)
    }
}

@Suite("WHSearchQuery mapping")
struct WHSearchQueryMappingTests {
    @Test("Preferences drive resolution and categories")
    func preferencesApplied() {
        let prefs = WallpaperPreferences(minResolution: "1920x1080", categories: [.anime])
        let context = WallpaperContext(timeSlot: .morning, appearanceMode: .light)
        let query = WHSearchQuery.from(context: context, preferences: prefs)
        #expect(query.atleast == "1920x1080")
        #expect(query.categories == [.anime])
        #expect(query.categories.apiString == "010")
    }

    @Test("Dark appearance appends a dark keyword")
    func darkAppendsKeyword() {
        let context = WallpaperContext(timeSlot: .evening, appearanceMode: .dark)
        let query = WHSearchQuery.from(context: context, preferences: .default)
        #expect(query.query.contains("dark"))
    }

    @Test("Each time slot produces a non-empty query")
    func everySlotHasQuery() {
        for slot in TimeSlot.allCases {
            let context = WallpaperContext(timeSlot: slot, appearanceMode: .light)
            let query = WHSearchQuery.from(context: context, preferences: .default)
            #expect(!query.query.isEmpty)
        }
    }
}
