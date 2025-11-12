import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    let year = Calendar.current.component(.year, from: Date())

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.98).ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Hero ────────────────────────────────────────────
                VStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color(red:0.25, green:0.50, blue:0.97),
                                         Color(red:0.14, green:0.33, blue:0.84)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 76, height: 76)
                            .shadow(color: Color(red:0.18,green:0.38,blue:0.88).opacity(0.32),
                                    radius: 16, y: 7)
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(appeared ? 1 : 0.75)
                    .opacity(appeared ? 1 : 0)

                    VStack(spacing: 5) {
                        Text("macRAR")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(white: 0.12))
                        Text("Version 1.0")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(white: 0.55))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.06), in: Capsule())
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 6)
                }
                .padding(.top, 36)
                .padding(.bottom, 24)

                // ── Cards ────────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {

                        // Developer
                        infoCard(delay: 0.08) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red:0.22,green:0.47,blue:0.95).opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Text("奈")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(red:0.22,green:0.47,blue:0.95))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Nigasaka Azumanga")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color(white: 0.15))
                                    Text("Developer  ·  © \(year)")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color(white: 0.55))
                                }
                                Spacer()
                                Text("All rights reserved")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(white: 0.65))
                            }
                        }

                        // About the app
                        infoCard(delay: 0.13) {
                            VStack(alignment: .leading, spacing: 7) {
                                cardLabel("About", icon: "info.circle")
                                Text("macRAR is a lightweight, native macOS app built to make .rar archives as easy as possible. Drop files in, name your archive, and get a .rar on your Desktop in seconds.")
                                    .font(.system(size: 12.5))
                                    .foregroundStyle(Color(white: 0.45))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // RAR credit
                        infoCard(delay: 0.18) {
                            VStack(alignment: .leading, spacing: 10) {
                                cardLabel("Powered by RAR", icon: "archivebox")
                                HStack(alignment: .top, spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(Color.orange.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "shippingbox.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.orange)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("RAR by RARLAB")
                                            .font(.system(size: 12.5, weight: .semibold))
                                            .foregroundStyle(Color(white: 0.2))
                                        Text("Created by Alexander Roshal. macRAR uses the RAR engine to create archives — without RARLAB's work, none of this would exist.")
                                            .font(.system(size: 11.5))
                                            .foregroundStyle(Color(white: 0.50))
                                            .lineSpacing(2.5)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Link("Visit rarlab.com ↗",
                                             destination: URL(string: "https://www.rarlab.com")!)
                                            .font(.system(size: 11.5, weight: .medium))
                                            .foregroundStyle(Color(red:0.22,green:0.47,blue:0.95))
                                            .padding(.top, 1)
                                    }
                                }
                            }
                        }

                        // Legal
                        infoCard(delay: 0.23) {
                            VStack(alignment: .leading, spacing: 6) {
                                cardLabel("Legal", icon: "doc.text")
                                Text("macRAR is an independent application by Nigasaka Azumanga. It is not affiliated with, endorsed by, or sponsored by RARLAB or WinRAR GmbH. RAR is a registered trademark of RARLAB.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(white: 0.55))
                                    .lineSpacing(2.5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                // ── Footer ───────────────────────────────────────────
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 0.5)
                    HStack {
                        Text("Made with love, Nigasaka")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(white: 0.60))
                        Spacer()
                        Button("Close") { dismiss() }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(
                                LinearGradient(
                                    colors: [Color(red:0.25,green:0.50,blue:0.97),
                                             Color(red:0.16,green:0.37,blue:0.87)],
                                    startPoint: .top, endPoint: .bottom),
                                in: RoundedRectangle(cornerRadius: 8))
                            .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .background(Color(red:0.97,green:0.97,blue:0.98))
            }
        }
        .frame(width: 380, height: 540)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(0.05)) {
                appeared = true
            }
        }
    }

    func infoCard<Content: View>(delay: Double, @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.38).delay(delay), value: appeared)
    }

    func cardLabel(_ text: String, icon: String) -> some View {
        Label(text.uppercased(), systemImage: icon)
            .font(.system(size: 9.5, weight: .semibold))
            .foregroundStyle(Color(white: 0.60))
            .tracking(0.8)
    }
}
