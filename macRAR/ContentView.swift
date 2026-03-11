import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var droppedFiles: [URL] = []
    @State private var isTargeted   = false
    @State private var archiveName  = ""
    @State private var status: AppStatus = .idle
    @State private var outputURL: URL?   = nil
    @State private var showAbout = false

    enum AppStatus: Equatable {
        case idle, working, done, error(String)
    }

    let accentBlue = Color(red: 0.23, green: 0.49, blue: 0.96)

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
        .sheet(isPresented: $showAbout) { AboutView() }
    }

    // MARK: - Title bar

    var titleBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "archivebox.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(accentBlue)
            Text("macRAR")
                .font(.system(size: 13, weight: .bold))
            Spacer()
            Button { showAbout = true } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    // MARK: - Drop zone

    var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(NSColor.controlBackgroundColor))
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isTargeted ? accentBlue : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 1.5, dash: isTargeted ? [] : [6, 3])
                )
                .animation(.easeInOut(duration: 0.15), value: isTargeted)

            if droppedFiles.isEmpty {
                emptyHint
            } else {
                fileList
            }
        }
        .frame(minHeight: 190)
        .padding(14)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: handleDrop)
    }

    var emptyHint: some View {
        VStack(spacing: 12) {
            Image(systemName: isTargeted ? "arrow.down.doc.fill" : "arrow.down.doc")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(isTargeted ? accentBlue : .secondary)
                .animation(.easeInOut(duration: 0.15), value: isTargeted)
            VStack(spacing: 4) {
                Text("Drop files or folders")
                    .font(.system(size: 14, weight: .semibold))
                Text("All items combined into one .rar")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 28)
    }

    var fileList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 4) {
                ForEach(droppedFiles, id: \.self) { url in
                    HStack(spacing: 10) {
                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
                            .font(.system(size: 13))
                            .foregroundColor(url.hasDirectoryPath ? .orange : accentBlue)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(url.lastPathComponent)
                                .font(.system(size: 12.5, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(url.hasDirectoryPath ? "Folder" : url.pathExtension.uppercased() + " File")
                                .font(.system(size: 10.5))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            droppedFiles.removeAll { $0 == url }
                            if droppedFiles.isEmpty { status = .idle }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(8)
                }
            }
            .padding(10)
        }
        .frame(maxHeight: 190)
    }

    // MARK: - Bottom bar

    var bottomBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "doc.badge.plus")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                TextField("Name your archive", text: $archiveName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                Text(".rar")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }

            if status != .idle { statusRow }

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
                            ProgressView().scaleEffect(0.75).tint(.white)
                        } else {
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 12))
                        }
                        Text(createButtonLabel)
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(droppedFiles.isEmpty || status == .working)
            }

            HStack {
                Button { showAbout = true } label: {
                    Text("Made with love, Nigasaka")
                        .font(.system(size: 10.5))
                        .foregroundColor(Color.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(14)
    }

    // MARK: - Status row

    @ViewBuilder
    var statusRow: some View {
        switch status {
        case .idle:
            EmptyView()
        case .working:
            Label("Creating archive…", systemImage: "hourglass")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        case .done:
            HStack(spacing: 6) {
                Label("Saved to Desktop", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                if let url = outputURL {
                    Text("·").foregroundColor(.secondary)
                    Button("Reveal in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                    .font(.system(size: 12))
                    .buttonStyle(.link)
                }
            }
        case .error(let msg):
            Label(msg, systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
                .foregroundColor(.red)
                .lineLimit(2)
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
        for p in providers {
            p.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                DispatchQueue.main.async {
                    guard !droppedFiles.contains(url) else { return }
                    droppedFiles.append(url)
                    status = .idle
                    if droppedFiles.count == 1 {
                        archiveName = url.deletingPathExtension().lastPathComponent
                    }
                }
            }
        }
        return true
    }

    func isRealMachO(at path: String) -> Bool {
        guard FileManager.default.isExecutableFile(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              data.count >= 4 else { return false }
        let m = Array(data.prefix(4))
        return m == [0xCF,0xFA,0xED,0xFE] || m == [0xCE,0xFA,0xED,0xFE] ||
               m == [0xFE,0xED,0xFA,0xCF] || m == [0xFE,0xED,0xFA,0xCE] ||
               m == [0xCA,0xFE,0xBA,0xBE]
    }

    func resolveRarPath() -> String? {
        if let b = Bundle.main.path(forResource: "rar", ofType: nil), isRealMachO(at: b) { return b }
        return ["/opt/homebrew/bin/rar", "/usr/local/bin/rar"].first { isRealMachO(at: $0) }
    }

    func createRAR() {
        guard !droppedFiles.isEmpty else { return }
        guard let rarPath = resolveRarPath() else {
            status = .error("rar not found — run: brew install rar")
            return
        }
        let name = archiveName.trimmingCharacters(in: .whitespaces).isEmpty ? "archive" : archiveName
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let output  = desktop.appendingPathComponent("\(name).rar")
        status = .working

        DispatchQueue.global(qos: .userInitiated).async {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: rarPath)
            p.arguments = ["a", "-ep1", output.path] + droppedFiles.map(\.path)
            let pipe = Pipe()
            p.standardOutput = pipe; p.standardError = pipe
            do {
                try p.run(); p.waitUntilExit()
                DispatchQueue.main.async {
                    if p.terminationStatus == 0 {
                        outputURL = output
                        withAnimation { status = .done }
                    } else {
                        let msg = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                                        encoding: .utf8) ?? "Unknown error"
                        status = .error(String(msg.prefix(100)))
                    }
                }
            } catch {
                DispatchQueue.main.async { status = .error(error.localizedDescription) }
            }
        }
    }
}
