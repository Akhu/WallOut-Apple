import Foundation

protocol WallpaperApplying: Sendable {
    /// Applies the image at the given local file URL as the desktop wallpaper.
    func apply(imageAt localURL: URL) async throws
}
