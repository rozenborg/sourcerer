import SwiftUI

@main
struct SourcererApp: App {
    @State private var env = AppEnvironment()
#if DEBUG
    @State private var previewEnv: AppEnvironment? = nil
    @State private var debugPreview: Bool = ProcessInfo.processInfo.arguments.contains("--preview")
#endif

    var body: some Scene {
        WindowGroup {
            content
                .tint(Theme.Color.accent)
        }
    }

    @ViewBuilder
    private var content: some View {
#if DEBUG
        if debugPreview, let preview = previewEnv {
            RootTabView()
                .environment(preview)
                .environment(preview.auth)
        } else {
            RootView(debugPreview: $debugPreview)
                .environment(env)
                .environment(env.auth)
                .onAppear {
                    if debugPreview && previewEnv == nil {
                        previewEnv = .preview()
                    }
                }
                .onChange(of: debugPreview) { _, nowOn in
                    if nowOn && previewEnv == nil {
                        previewEnv = .preview()
                    }
                }
        }
#else
        RootView()
            .environment(env)
            .environment(env.auth)
#endif
    }
}

struct RootView: View {
    @Environment(AuthService.self) private var auth
#if DEBUG
    @Binding var debugPreview: Bool
    init(debugPreview: Binding<Bool>) { self._debugPreview = debugPreview }
#else
    init() {}
#endif

    var body: some View {
        if auth.isAuthenticated {
            RootTabView()
        } else {
#if DEBUG
            AuthView(debugPreview: $debugPreview)
#else
            AuthView()
#endif
        }
    }
}

struct RootTabView: View {
    @State private var selection: Int = RootTabView.initialTab()

    var body: some View {
        TabView(selection: $selection) {
            TodayView()
                .tag(0)
                .tabItem { Label("Today", systemImage: "house.fill") }

            TomorrowView()
                .tag(1)
                .tabItem { Label("Tomorrow", systemImage: "calendar") }

            LibraryView()
                .tag(2)
                .tabItem { Label("Deck", systemImage: "books.vertical") }

            BriefingView()
                .tag(3)
                .tabItem { Label("Brief", systemImage: "clock.fill") }

            ProfileView()
                .tag(4)
                .tabItem { Label("Me", systemImage: "person.fill") }
        }
        .tint(Theme.Color.accent)
    }

    private static func initialTab() -> Int {
#if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(where: { $0.hasPrefix("--tab=") }) {
            let n = args[i].dropFirst("--tab=".count)
            return Int(n) ?? 0
        }
#endif
        return 0
    }
}
