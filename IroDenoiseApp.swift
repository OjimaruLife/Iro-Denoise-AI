import SwiftUI

@main
struct IroDenoiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1200, height: 960)
        .commands {
            CommandGroup(replacing: .help) {
                Button("Iro Denoise AI ヘルプ") {
                    openAboutWindow()
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
    }

    private func openAboutWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 640),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Iro Denoise AI について"
        window.contentView = NSHostingView(rootView: AboutView())
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}
