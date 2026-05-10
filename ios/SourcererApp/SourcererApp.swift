import SwiftUI

@main
struct SourcererApp: App {
    @State private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(env)
                .environment(env.auth)
        }
    }
}

struct RootView: View {
    @Environment(AuthService.self) private var auth

    var body: some View {
        if auth.isAuthenticated {
            RootTabView()
        } else {
            AuthView()
        }
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("Feed", systemImage: "list.bullet") }
            StarredView()
                .tabItem { Label("Starred", systemImage: "star") }
            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }
        }
    }
}
