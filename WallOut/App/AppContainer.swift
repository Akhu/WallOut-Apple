// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation
import OSLog

private let logger = Logger(subsystem: "net.globule.WallOut", category: "AppContainer")

/// Owns all long-lived objects and wires dependencies together.
/// Instantiated once and held as @StateObject in WallOutApp.
@MainActor
final class AppContainer: ObservableObject {
    let monitor: SystemContextMonitor
    let scheduler: WallpaperScheduler

    init() {
        monitor = SystemContextMonitor()

        let apiKey = UserDefaults.standard.string(forKey: "apiKey")
        let cache: WallpaperImageCache
        do {
            cache = try WallpaperImageCache()
        } catch {
            logger.error("Image cache init failed: \(error.localizedDescription, privacy: .public)")
            fatalError("Cannot initialize image cache: \(error)")
        }

        let api = WallHavenAPI(apiKey: apiKey?.isEmpty == false ? apiKey : nil)
        let repo = WallHavenRepository(api: api, imageCache: cache)
        let applier = MacOSWallpaperApplier()

        scheduler = WallpaperScheduler(fetcher: repo, applier: applier, monitor: monitor)
        scheduler.start()
    }
}
