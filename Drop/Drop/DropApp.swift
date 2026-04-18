import SwiftUI

@main
struct DropApp: App {
    @StateObject private var auth = AuthManager.shared
    @StateObject private var location = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(location)
                .onAppear { location.requestPermission() }
        }
    }
}
