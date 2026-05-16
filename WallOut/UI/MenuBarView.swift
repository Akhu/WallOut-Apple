// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 WallOut contributors
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var scheduler: WallpaperScheduler
    @ObservedObject var monitor: SystemContextMonitor
    @AppStorage("apiKey") private var apiKey: String = ""

    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusHeader
            Divider()
            contextInfo
            Divider()
            actions
        }
        .padding(.vertical, 4)
        .frame(minWidth: 260)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var statusHeader: some View {
        HStack(spacing: 8) {
            statusIcon
            VStack(alignment: .leading, spacing: 2) {
                Text("WallOut")
                    .font(.headline)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var statusIcon: some View {
        Group {
            switch scheduler.state {
            case .idle:
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(.green)
            case .fetching, .applying:
                ProgressView()
                    .controlSize(.small)
            case .error:
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }
        }
        .frame(width: 24, height: 24)
    }

    private var statusText: String {
        switch scheduler.state {
        case .idle:
            if let date = scheduler.lastApplied {
                return "Updated \(date.formatted(.relative(presentation: .named)))"
            }
            return "Ready"
        case .fetching:   return "Fetching wallpaper…"
        case .applying:   return "Applying wallpaper…"
        case .error(let msg): return msg
        }
    }

    private var contextInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            contextRow(
                icon: monitor.context.timeSlot == .night ? "moon.stars" : "sun.max",
                label: "Time slot",
                value: monitor.context.timeSlot.displayName
            )
            contextRow(
                icon: monitor.context.appearanceMode == .dark ? "moon" : "sun.min",
                label: "Appearance",
                value: monitor.context.appearanceMode == .dark ? "Dark" : "Light"
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func contextRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 16)
                .foregroundStyle(.secondary)
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.caption)
                .bold()
        }
    }

    private var actions: some View {
        VStack(spacing: 0) {
            Button {
                scheduler.refreshNow()
            } label: {
                Label("Refresh Now", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .disabled(scheduler.state == .fetching || scheduler.state == .applying)

            Button {
                showSettings = true
            } label: {
                Label("Settings…", systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.vertical, 4)

            Button(role: .destructive) {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit WallOut", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
    }
}
