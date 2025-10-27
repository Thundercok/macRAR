import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    let year = Calendar.current.component(.year, from: Date())

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ───────────────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.85), Color.accentColor.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "doc.zipper")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 4) {
                        Text("macRAR")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(.vertical, 36)
            }

            // ── Body ─────────────────────────────────────────────────
            VStack(spacing: 24) {

                // Author
                infoCard {
                    VStack(spacing: 6) {
                        label("Developed by", icon: "person.fill")
                        Text("Nigasaka Azumanga")
                            .font(.title3.bold())
                        Text("© \(year) Nigasaka Azumanga. All rights reserved.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Description
                infoCard {
                    VStack(alignment: .leading, spacing: 8) {
                        label("About", icon: "info.circle.fill")
                        Text("macRAR is a lightweight, native macOS application designed to make creating RAR archives effortless. Simply drop your files or folders in, choose a name, and get a ready-to-submit .rar file on your Desktop in seconds.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Acknowledgements
                infoCard {
                    VStack(alignment: .leading, spacing: 10) {
                        label("Acknowledgements", icon: "heart.fill")

                        acknowledgementRow(
                            title: "RAR by RARLAB",
                            detail: "This application uses the RAR archiving engine, developed by Alexander Roshal and distributed by RARLAB. RAR is proprietary software — all rights reserved by RARLAB.",
                            url: "https://www.rarlab.com"
                        )
                    }
                }

                // Legal
                Text("macRAR is an independent application and is not affiliated with, endorsed by, or sponsored by RARLAB or WinRAR GmbH.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
            .padding(24)

            Divider()

            // ── Footer ────────────────────────────────────────────────
            HStack {
                Text("Made with ♥ on a Mac")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .frame(width: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Helpers

    @ViewBuilder
    func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }

    func label(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    func acknowledgementRow(title: String, detail: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.callout.bold())
                Spacer()
                Link("Visit site ↗", destination: URL(string: url)!)
                    .font(.caption)
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
