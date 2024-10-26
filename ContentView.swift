import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var droppedFiles: [URL] = []
    @State private var isTargeted = false
    @State private var status: AppStatus = .idle
    @State private var outputURL: URL? = nil
    @State private var archiveName: String = "archive"

    enum AppStatus {
        case idle, working, done, error(String)
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────────
            HStack {
                Image(systemName: "doc.zipper")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("macRAR")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)

            Divider()

            // ── Drop Zone ────────────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isTargeted ? Color.accentColor : Color.secondary.opacity(0.4),
                        style: StrokeStyle(lineWidth: 2, dash: [6])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isTargeted
                                  ? Color.accentColor.opacity(0.08)
                                  : Color.secondary.opacity(0.05))
                    )
                    .animation(.easeInOut(duration: 0.15), value: isTargeted)

                if droppedFiles.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("Drop files or folders here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(droppedFiles, id: \.self) { url in
                                HStack(spacing: 8) {
                                    Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
                                        .foregroundColor(url.hasDirectoryPath ? .yellow : .accentColor)
                                        .frame(width: 18)
                                    Text(url.lastPathComponent)
                                        .font(.system(size: 13))
                                        .lineLimit(1)
                                    Spacer()
                                    Button {
                                        droppedFiles.removeAll { $0 == url }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        .padding(10)
                    }
                    .frame(maxHeight: 200)
                }
            }
            .frame(minHeight: 180)
            .padding()
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }

            // ── Archive Name ─────────────────────────────────────────
            HStack {
                Text("Name:")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                TextField("archive", text: $archiveName)
                    .textFieldStyle(.roundedBorder)
                Text(".rar")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // ── Action Bar ───────────────────────────────────────────
            VStack(spacing: 8) {
                statusView

                HStack(spacing: 12) {
                    Button("Clear") {
                        droppedFiles = []
                        status = .idle
                        outputURL = nil
                    }
                    .buttonStyle(.bordered)
                    .disabled(droppedFiles.isEmpty)

                    Button {
                        createRAR()
                    } label: {
                        HStack {
                            if case .working = status {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Image(systemName: "archivebox.fill")
                            }
                            Text(buttonLabel)
                        }
                        .frame(minWidth: 130)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(droppedFiles.isEmpty || {
                        if case .working = status { return true }
                        return false
                    }())
                }
                .padding(.bottom, 14)
            }
            .padding(.top, 10)
        }
        .frame(width: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // ── Subviews ─────────────────────────────────────────────────────

    @ViewBuilder
    var statusView: some View {
        switch status {
        case .idle:
            EmptyView()
        case .working:
            Label("Creating archive…", systemImage: "hourglass")
                .font(.caption)
                .foregroundColor(.secondary)
        case .done:
            HStack(spacing: 6) {
                Label("Saved to Desktop!", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                if let url = outputURL {
                    Button("Show in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                }
            }
        case .error(let msg):
            Label(msg, systemImage: "xmark.octagon.fill")
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    var buttonLabel: String {
        switch status {
        case .working: return "Working…"
        case .done:    return "Create Another"
        default:       return "Create RAR"
        }
    }

    // ── Logic ─────────────────────────────────────────────────────────

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                DispatchQueue.main.async {
                    if !droppedFiles.contains(url) {
                        droppedFiles.append(url)
                        status = .idle
                    }
                }
            }
        }
        return true
    }

    func createRAR() {
        guard !droppedFiles.isEmpty else { return }

        // Locate the bundled `rar` binary
        guard let rarPath = Bundle.main.path(forResource: "rar", ofType: nil) else {
            status = .error("rar binary not found in app bundle.\nSee README for setup.")
            return
        }

        let name = archiveName.trimmingCharacters(in: .whitespaces).isEmpty ? "archive" : archiveName
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let output = desktop.appendingPathComponent("\(name).rar")

        status = .working

        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: rarPath)

            // rar a <output> <files...>
            var args = ["a", output.path]
            args += droppedFiles.map(\.path)
            process.arguments = args

            let pipe = Pipe()
            process.standardError = pipe
            process.standardOutput = pipe

            do {
                try process.run()
                process.waitUntilExit()

                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        outputURL = output
                        status = .done
                    } else {
                        let data = pipe.fileHandleForReading.readDataToEndOfFile()
                        let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                        status = .error("Failed: \(msg)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    status = .error(error.localizedDescription)
                }
            }
        }
    }
}
