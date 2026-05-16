@preconcurrency import AppKit

struct MacOSWallpaperApplier: WallpaperApplying {
    func apply(imageAt localURL: URL) async throws {
        try await MainActor.run {
            let screens = NSScreen.screens
            guard !screens.isEmpty else { return }
            let workspace = NSWorkspace.shared
            let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
                .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
                .allowClipping: true
            ]
            for screen in screens {
                try workspace.setDesktopImageURL(localURL, for: screen, options: options)
            }
        }
    }
}
