// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import AppKit
import Combine

/// Publishes a new WallpaperContext whenever dark mode or the time slot changes.
@MainActor
final class SystemContextMonitor: ObservableObject {
    @Published private(set) var context: WallpaperContext

    private var cancellables: Set<AnyCancellable> = []
    private var slotTimer: Timer?

    init() {
        context = Self.currentContext()
        observeDarkMode()
        scheduleSlotTimer()
    }

    private static func currentContext() -> WallpaperContext {
        WallpaperContext(
            timeSlot: .current(),
            appearanceMode: NSApp.effectiveAppearance.isDark ? .dark : .light
        )
    }

    private func observeDarkMode() {
        DistributedNotificationCenter.default()
            .publisher(for: Notification.Name("AppleInterfaceThemeChangedNotification"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    private func scheduleSlotTimer() {
        slotTimer?.invalidate()
        let interval = TimeSlot.current().timeUntilNextTransition()
        slotTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.refresh()
            self?.scheduleSlotTimer()
        }
    }

    private func refresh() {
        let next = Self.currentContext()
        if next != context {
            context = next
        }
    }
}

private extension NSAppearance {
    var isDark: Bool {
        bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
