// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import SwiftUI

struct SettingsView: View {
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("minResolution") private var minResolution: String = "2560x1440"
    @AppStorage("categoriesGeneral") private var categoriesGeneral: Bool = true
    @AppStorage("categoriesAnime") private var categoriesAnime: Bool = false
    @AppStorage("categoriesPeople") private var categoriesPeople: Bool = false
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("WallHaven Account") {
                SecureField("API Key (optional)", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                Text("Required for NSFW content and higher rate limits. Get yours at wallhaven.cc/settings/account")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Wallpaper Quality") {
                Picker("Minimum resolution", selection: $minResolution) {
                    Text("1920×1080").tag("1920x1080")
                    Text("2560×1440").tag("2560x1440")
                    Text("3840×2160").tag("3840x2160")
                }
            }

            Section("Categories") {
                Toggle("General", isOn: $categoriesGeneral)
                Toggle("Anime", isOn: $categoriesAnime)
                Toggle("People", isOn: $categoriesPeople)
            }

            Section("System") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { enabled in
                        toggleLaunchAtLogin(enabled)
                    }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
        .navigationTitle("WallOut Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func toggleLaunchAtLogin(_ enabled: Bool) {
        // ServiceManagement-based launch at login is registered in WallOutApp
        NotificationCenter.default.post(
            name: .launchAtLoginChanged,
            object: enabled
        )
    }
}

extension Notification.Name {
    static let launchAtLoginChanged = Notification.Name("WallOutLaunchAtLoginChanged")
}
