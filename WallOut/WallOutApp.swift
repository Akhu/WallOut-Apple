import SwiftUI
import ServiceManagement
import OSLog

private let logger = Logger(subsystem: "net.globule.WallOut", category: "App")

@main
struct WallOutApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        MenuBarExtra("WallOut", systemImage: menuBarIcon) {
            MenuBarView(
                scheduler: container.scheduler,
                monitor: container.monitor
            )
            .onAppear { observeLaunchAtLoginChanges() }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarIcon: String {
        switch container.scheduler.state {
        case .idle:                return "photo.on.rectangle.angled"
        case .fetching, .applying: return "arrow.clockwise"
        case .error:               return "exclamationmark.triangle"
        }
    }

    @MainActor
    private func observeLaunchAtLoginChanges() {
        NotificationCenter.default.addObserver(
            forName: .launchAtLoginChanged,
            object: nil,
            queue: .main
        ) { notification in
            guard let enabled = notification.object as? Bool else { return }
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                logger.error("Launch-at-login: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
