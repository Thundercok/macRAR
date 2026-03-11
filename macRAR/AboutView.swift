import SwiftUI

private let blue0 = Color(red: 0.23, green: 0.49, blue: 0.96)
private let blue1 = Color(red: 0.14, green: 0.33, blue: 0.84)
private let surface = Color(red: 0.98, green: 0.98, blue: 0.99)
private let dimFg   = Color(white: 0.62)

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    let year = Calendar.current.component(.year, from: Date())

    var body: some View {
        ZStack {
            surface.ignoresSafeArea()

            VStack(spacing: 0) {
                hero
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        authorCard
                        descriptionCard
                        rarCreditCard
                        legalCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 20)
                }
                footer
            }
        }
        .frame(width: 380, height: 548)
        .onAppear {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.76).delay(0.06)) {
                appeared = true
            }
        }
    }

    // MARK: – Hero

    var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [blue0, blue1],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .shadow(color: blue1.opacity(0.35), radius: 18, y: 8)

                Image(systemName: "archivebox.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.white)
            }
            .scaleEffect(appeared ? 1.0 : 0.72)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 5) {
                Text("macRAR")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(white: 0.10))
                HStack(spacing: 6) {
                    Text("Version 1.0")
                        .font(.system(size: 11.5))
                        .foregroundStyle(dimFg)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.06), in: Capsule())
                    Text("macOS 13+")
                        .font(.system(size: 11.5))
                        .foregroundStyle(dimFg)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.06), in: Capsule())
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 6)
        }
        .padding(.top, 34)
        .padding(.bottom, 22)
    }

    // MARK: – Cards

    var authorCard: some View {
        card(delay: 0.10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(blue0.opacity(0.10))
                        .frame(width: 42, height: 42)
                    Text("奈")
                        .font(.system(size: 19))
                        .foregroundStyle(blue0)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nigasaka Azumanga")
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(Color(white: 0.13))
                    Text("Developer & Designer")
                        .font(.system(size: 11.5))
                        .foregroundStyle(dimFg)
                }
                Spacer()
                Text("© \(year)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color(white: 0.68))
            }
        }
    }

    var descriptionCard: some View {
        card(delay: 0.15) {
            VStack(alignment: .leading, spacing: 8) {
                cardHeader("About", icon: "info.circle.fill")
                Text("macRAR is a lightweight, native macOS application that turns creating .rar archives into a single drag-and-drop action. Built for people who just need it to work — without a Terminal in sight.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color(white: 0.42))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var rarCreditCard: some View {
        card(delay: 0.20) {
            VStack(alignment: .leading, spacing: 10) {
                cardHeader("Powered by RAR", icon: "archivebox.fill")
                HStack(alignment: .top, spacing: 11) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.orange.opacity(0.10))
                            .frame(width: 34, height: 34)
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.orange)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RAR by RARLAB")
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Color(white: 0.18))
                        Text("Developed by Alexander Roshal. macRAR uses the RAR binary to create archives. All RAR rights reserved by RARLAB.")
                            .font(.system(size: 11.5))
                            .foregroundStyle(Color(white: 0.48))
                            .lineSpacing(2.5)
                            .fixedSize(horizontal: false, vertical: true)
                        Link("rarlab.com ↗", destination: URL(string: "https://www.rarlab.com")!)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(blue0)
                    }
                }
            }
        }
    }

    var legalCard: some View {
        card(delay: 0.25) {
            VStack(alignment: .leading, spacing: 7) {
                cardHeader("Legal", icon: "doc.text.fill")
                Text("macRAR is an independent application developed by Nigasaka Azumanga. It is not affiliated with, endorsed by, or sponsored by RARLAB or WinRAR GmbH. RAR is a registered trademark of RARLAB.")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color(white: 0.52))
                    .lineSpacing(2.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: – Footer

    var footer: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.5)
            HStack {
                Text("Made with love, Nigasaka")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(white: 0.62))
                Spacer()
                Button("Close") { dismiss() }
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(colors: [blue0, blue1],
                                                 startPoint: .top, endPoint: .bottom))
                            .shadow(color: blue1.opacity(0.28), radius: 5, y: 2)
                    )
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
        }
        .background(surface)
    }

    // MARK: – Helpers

    func card<C: View>(delay: Double, @ViewBuilder content: () -> C) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.045), radius: 8, y: 2)
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.36).delay(delay), value: appeared)
    }

    func cardHeader(_ title: String, icon: String) -> some View {
        Label(title.uppercased(), systemImage: icon)
            .font(.system(size: 9.5, weight: .bold))
            .foregroundStyle(Color(white: 0.58))
            .tracking(0.9)
    }
}
