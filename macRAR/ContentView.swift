import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var droppedFiles: [URL] = []
    @State private var isTargeted = false
    @State private var archiveName = ""
    @State private var status: Status = .idle
    @State private var outputURL: URL? = nil

    enum Status: Equatable {
        case idle, working, done, error(String)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider()
            dropZone
            Divider()
            bottomBar
        }
        .frame(width: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Title Bar

    var titleBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.zipper")
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 15, weight: .semibold))
            Text("macRAR")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Drop Zone

    var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.25),
                    style: StrokeStyle(lineWidth: 2, dash: isTargeted ? [] : [7])
                )
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isTargeted
                              ? Color.accentColor.opacity(0.07)
                              : Color.secondary.opacity(0.03))
                )
                .animation(.easeInOut(duration: 0.12), value: isTargeted)

            if droppedFiles.isEmpty {
                emptyDropHint
            } else {
                fileList
            }
        }
        .frame(minHeight: 190)
        .padding(16)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: handleDrop)
    }

    var emptyDropHint: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Drop files or folders here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Any number of files — all go into one .rar")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    var fileList: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(droppedFiles, id: \.self) { url in
                    HStack(spacing: 8) {
                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
                            .foregroundStyle(url.hasDirectoryPath ? .yellow : Color.accentColor)
                            .frame(width: 16)
                        Text(url.lastPathComponent)
                            .font(.system(size: 13))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button {
                            droppedFiles.removeAll { $0 == url }
                            if droppedFiles.isEmpty { status = .idle }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.secondary.opacity(0.07),
                                in: RoundedRectangle(cornerRadius: 7))
                }
            }
            .padding(10)
        }
        .frame(maxHeight: 190)
    }

    // MARK: - Bottom Bar

    var bottomBar: some View {
        VStack(spacing: 10) {
            // Archive name
            HStack(spacing: 8) {
                Image(systemName: "doc.badge.plus")
                    .foregroundStyle(.secondary)
                    .frame(width: 16)
                TextField("archive name", text: $archiveName)
                    .textFieldStyle(.roundedBorder)
                Text(".rar")
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }

            // Status
            statusRow

            // Buttons
            HStack {
                if !droppedFiles.isEmpty {
                    Button("Clear") {
                        droppedFiles = []
                        status = .idle
                        outputURL = nil
                        archiveName = ""
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
                Button(action: createRAR) {
                    HStack(spacing: 6) {
                        if status == .working {
                            ProgressView().scaleEffect(0.75)
                        } else {
                            Image(systemName: "archivebox.fill")
                        }
                        Text(createButtonLabel)
                    }
                    .frame(minWidth: 140)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(droppedFiles.isEmpty || status == .working)
            }
        }
        .padding(16)
    }

    @ViewBuilder
    var statusRow: some View {
        switch status {
        case .idle:
            EmptyView()
        case .working:
            Label("Creating archive…", systemImage: "hourglass")
                .font(.caption).foregroundStyle(.secondary)
        case .done:
            HStack(spacing: 8) {
                Label("Saved to Desktop!", systemImage: "checkmark.circle.fill")
                    .font(.caption).foregroundStyle(.green)
                if let url = outputURL {
                    Button("Show in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                    .font(.caption).buttonStyle(.link)
                }
            }
        case .error(let msg):
            Label(msg, systemImage: "xmark.octagon.fill")
                .font(.caption).foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }

    var createButtonLabel: String {
        switch status {
        case .working: return "Working…"
        case .done:    return "Create Another"
        default:       return "Create RAR"
        }
    }

    // MARK: - Logic

    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                DispatchQueue.main.async {
                    guard !droppedFiles.contains(url) else { return }
                    droppedFiles.append(url)
                    status = .idle
                    // Auto-name from first file dropped
                    if droppedFiles.count == 1 {
                        archiveName = url.deletingPathExtension().lastPathComponent
                    }
                }
            }
        }
        return true
    }

    func createRAR() {
        guard !droppedFiles.isEmpty else { return }

        // rar binary is bundled inside the app
        guard let rarPath = Bundle.main.path(forResource: "rar", ofType: nil) else {
            status = .error("Bundled rar not found. See README to add it.")
            return
        }

        let name = archiveName.trimmingCharacters(in: .whitespaces).isEmpty
            ? "archive" : archiveName
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let output = desktop.appendingPathComponent("\(name).rar")

        status = .working

        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: rarPath)
            process.arguments = ["a", output.path] + droppedFiles.map(\.path)

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()
                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        outputURL = output
                        status = .done
                    } else {
                        let raw = pipe.fileHandleForReading.readDataToEndOfFile()
                        let msg = String(data: raw, encoding: .utf8) ?? "Unknown error"
                        status = .error(String(msg.prefix(140)))
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
