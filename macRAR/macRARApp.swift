import SwiftUI

@main
struct macRARApp: App {
    @State private var showingAbout = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showingAbout) {
                    AboutView()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                Button("About macRAR") {
                    showingAbout = true
                }
            }
        }
    }
}
