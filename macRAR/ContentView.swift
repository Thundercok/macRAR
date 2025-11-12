import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var droppedFiles: [URL] = []
    @State private var isTargeted = false
    @State private var archiveName = ""
    @State private var status: Status = .idle
    @State private var outputURL: URL? = nil
    @State private var showAbout = false

    enum Status: Equatable {
        case idle, working, done, error(String)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Seamless light background
            Color(red: 0.97, green: 0.97, blue: 0.98)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                titleBar
                dropZone
                bottomSection
            }
        }
        .frame(width: 420)
        .sheet(isPresented: $showAbout) { AboutView() }
    }

    // MARK: – Title bar

    var titleBar: some View {
        HStack(spacing: 9) {
            // Custom icon — gradient rounded square
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color(red:0.22, green:0.47, blue:0.95),
                                 Color(red:0.14, green:0.35, blue:0.85)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 24, height: 24)
                    .shadow(color: Color(red:0.18, green:0.38, blue:0.88).opacity(0.35),
                            radius: 5, y: 2)
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("macRAR")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(white: 0.15))

            Spacer()

            Button { showAbout = true } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(white: 0.55))
            }
            .buttonStyle(.plain)
            .help("About macRAR")
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: – Drop zone

    var dropZone: some View {
        ZStack {
            // Card
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(isTargeted ? 0.10 : 0.06),
                        radius: isTargeted ? 16 : 10, y: isTargeted ? 6 : 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            isTargeted
                                ? Color(red:0.22, green:0.47, blue:0.95).opacity(0.5)
                                : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .animation(.easeInOut(duration: 0.18), value: isTargeted)

            if droppedFiles.isEmpty {
                emptyHint
            } else {
                fileList
            }
        }
        .frame(minHeight: 190)
        .padding(.horizontal, 14)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: handleDrop)
    }

    var emptyHint: some View {
        VStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(Color(red:0.22, green:0.47, blue:0.95).opacity(0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color(red:0.22, green:0.47, blue:0.95).opacity(0.75))
            }
            VStack(spacing: 4) {
                Text("Drop files or folders")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.25))
                Text("Everything goes into one .rar")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(white: 0.60))
            }
        }
        .padding(.vertical, 28)
    }

    var fileList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 3) {
                ForEach(droppedFiles, id: \.self) { url in
                    HStack(spacing: 10) {
                        Image(systemName: url.hasDirectoryPath ? "folder.fill" : "doc.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(url.hasDirectoryPath
                                             ? Color.orange.opacity(0.85)
                                             : Color(red:0.22, green:0.47, blue:0.95).opacity(0.8))
                            .frame(width: 20)

                        Text(url.lastPathComponent)
                            .font(.system(size: 12.5))
                            .foregroundStyle(Color(white: 0.2))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button {
                            withAnimation(.easeOut(duration: 0.15)) {
                                droppedFiles.removeAll { $0 == url }
                                if droppedFiles.isEmpty { status = .idle }
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(white: 0.55))
                                .frame(width: 18, height: 18)
                                .background(Color(white: 0.91), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(white: 0.975), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
            .padding(12)
        }
        .frame(maxHeight: 190)
    }

    // MARK: – Bottom section

    var bottomSection: some View {
        VStack(spacing: 0) {
            // Thin separator
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 14)

            VStack(spacing: 10) {
                // Name field
                HStack(spacing: 0) {
                    TextField("Name your archive", text: $archiveName)
                        .font(.system(size: 13))
                        .textFieldStyle(.plain)
                        .padding(.leading, 12)
                        .padding(.vertical, 9)

                    Text(".rar")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(white: 0.50))
                        .padding(.trailing, 12)
                }
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.09), lineWidth: 1)
                )

                // Status
                if status != .idle {
                    statusRow
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Buttons
                HStack(spacing: 8) {
                    if !droppedFiles.isEmpty {
                        Button("Clear") {
                            withAnimation(.easeOut(duration: 0.2)) {
                                droppedFiles = []
                                status = .idle
                                outputURL = nil
                                archiveName = ""
                            }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(white: 0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.black.opacity(0.09), lineWidth: 1))
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button(action: createRAR) {
                        HStack(spacing: 7) {
                            if status == .working {
                                ProgressView()
                                    .scaleEffect(0.70)
                                    .tint(.white)
                            } else {
                                Image(systemName: "archivebox.fill")
                                    .font(.system(size: 12))
                            }
                            Text(createButtonLabel)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(droppedFiles.isEmpty || status == .working
                                    ? LinearGradient(colors: [Color(white:0.78), Color(white:0.73)],
                                                     startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [Color(red:0.25, green:0.50, blue:0.97),
                                                              Color(red:0.16, green:0.37, blue:0.87)],
                                                     startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(color: droppedFiles.isEmpty ? .clear
                                : Color(red:0.18, green:0.38, blue:0.88).opacity(0.30),
                                radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                    .disabled(droppedFiles.isEmpty || status == .working)
                    .animation(.easeInOut(duration: 0.15), value: droppedFiles.isEmpty)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .animation(.easeOut(duration: 0.2), value: status)

            // Credit
            HStack {
                Button { showAbout = true } label: {
                    Text("Made with love, Nigasaka")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(white: 0.68))
                }
                .buttonStyle(.plain)
                .help("About macRAR")
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    // MARK: – Status row

    @ViewBuilder
    var statusRow: some View {
        switch status {
        case .idle:
            EmptyView()
        case .working:
            HStack(spacing: 6) {
                Image(systemName: "hourglass")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(white: 0.55))
                Text("Creating archive…")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(white: 0.50))
            }
        case .done:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red:0.18, green:0.72, blue:0.45))
                Text("Saved to Desktop")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(white: 0.35))
                if let url = outputURL {
                    Text("·").foregroundStyle(Color(white:0.7))
                    Button("Show in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                    .font(.system(size: 12))
                    .buttonStyle(.link)
                    .foregroundStyle(Color(red:0.22, green:0.47, blue:0.95))
                }
            }
        case .error(let msg):
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.red)
                Text(msg)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.red.opacity(0.85))
                    .lineLimit(2)
            }
        }
    }

    var createButtonLabel: String {
        switch status {
        case .working: return "Working…"
        case .done:    return "Create Another"
        default:       return "Create RAR"
        }
    }

    // MARK: – Logic

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
        let magic = Array(data.prefix(4))
        return magic == [0xCF,0xFA,0xED,0xFE] || magic == [0xCE,0xFA,0xED,0xFE] ||
               magic == [0xFE,0xED,0xFA,0xCF] || magic == [0xFE,0xED,0xFA,0xCE] ||
               magic == [0xCA,0xFE,0xBA,0xBE]
    }

    func resolveRarPath() -> String? {
        if let b = Bundle.main.path(forResource: "rar", ofType: nil), isRealMachO(at: b) { return b }
        return ["/opt/homebrew/bin/rar", "/usr/local/bin/rar"].first { isRealMachO(at: $0) }
    }

    func createRAR() {
        guard !droppedFiles.isEmpty, let rarPath = resolveRarPath() else {
            if resolveRarPath() == nil { status = .error("rar not found — run: brew install rar") }
            return
        }
        let name = archiveName.trimmingCharacters(in: .whitespaces).isEmpty ? "archive" : archiveName
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let output = desktop.appendingPathComponent("\(name).rar")
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
                        withAnimation(.spring(response: 0.35)) { status = .done }
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
