// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import Foundation
import Combine
import OSLog

private let logger = Logger(subsystem: "fr.picklestudio.WallOut", category: "Scheduler")

/// Orchestrates context observation → fetch → apply.
/// Holds the only strong reference to the fetcher and applier.
@MainActor
final class WallpaperScheduler: ObservableObject {
    enum State: Equatable {
        case idle
        case fetching
        case applying
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var currentWallpaper: Wallpaper?
    @Published private(set) var lastApplied: Date?

    private let fetcher: any WallpaperFetching
    private let applier: any WallpaperApplying
    private let monitor: SystemContextMonitor

    private var cancellables: Set<AnyCancellable> = []
    private var activeTask: Task<Void, Never>?

    init(
        fetcher: some WallpaperFetching,
        applier: some WallpaperApplying,
        monitor: SystemContextMonitor
    ) {
        self.fetcher = fetcher
        self.applier = applier
        self.monitor = monitor
    }

    func start() {
        monitor.$context
            .removeDuplicates()
            .sink { [weak self] context in
                self?.triggerUpdate(for: context)
            }
            .store(in: &cancellables)
    }

    func refreshNow() {
        triggerUpdate(for: monitor.context)
    }

    private func triggerUpdate(for context: WallpaperContext) {
        activeTask?.cancel()
        activeTask = Task {
            await run(for: context)
        }
    }

    private func run(for context: WallpaperContext) async {
        guard !Task.isCancelled else { return }
        state = .fetching
        logger.info("Fetching wallpaper for \(context.timeSlot.displayName, privacy: .public) / \(context.appearanceMode == .dark ? "dark" : "light", privacy: .public)")

        do {
            let wallpaper = try await fetcher.fetchWallpaper(for: context)
            guard !Task.isCancelled else { return }

            state = .applying
            let localURL = try await fetcher.downloadImage(for: wallpaper)
            guard !Task.isCancelled else { return }

            try await applier.apply(imageAt: localURL)

            currentWallpaper = wallpaper
            lastApplied = .now
            state = .idle
            logger.info("Applied wallpaper \(wallpaper.id, privacy: .public)")
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
            logger.error("Failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
