import SwiftUI
import AppKit

@main
struct NeatdogApp: App {
    @State private var authService = AuthService.shared

    init() {
        // Required for swift run to show GUI window
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
            } else {
                LoginView()
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)
        .environment(authService)
    }
}
