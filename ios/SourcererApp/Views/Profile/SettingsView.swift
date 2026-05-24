import SwiftUI

/// Settings — toggles grouped into sections (deck / briefing / rating /
/// feeds). Most toggles are not yet wired to backend behavior — they persist
/// to `@AppStorage` so the choices stick across launches.
struct SettingsView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @AppStorage("settings.showTicker") private var showTicker: Bool = true
    @AppStorage("settings.defaultToDeck") private var defaultToDeck: Bool = true
    @AppStorage("settings.hideReadItems") private var hideReadItems: Bool = false
    @AppStorage("settings.audioBriefing") private var audioBriefing: Bool = true
    @AppStorage("settings.briefingNotify") private var briefingNotify: Bool = true
    @AppStorage("settings.skipAlreadyRated") private var skipAlreadyRated: Bool = false
    @AppStorage("settings.promptToRate") private var promptToRate: Bool = true
    @AppStorage("settings.useRatingsRerank") private var useRatingsRerank: Bool = true

    @State private var showSignOutConfirm = false

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                VStack(spacing: 0) {
                    Section(title: "the deck") {
                        Toggle("Show live ticker", isOn: $showTicker)
                            .modifier(SettingsRow(sub: "Flashing headline strip at the top of the feed"))
                        Toggle("Default to DECK", isOn: $defaultToDeck)
                            .modifier(SettingsRow(sub: "Cards over list when you open the app"))
                        Toggle("Hide read items", isOn: $hideReadItems)
                            .modifier(SettingsRow(sub: "Compress completed cards out of the list view"))
                    }

                    Section(title: "briefing") {
                        Toggle("Daily audio briefing", isOn: $audioBriefing)
                            .modifier(SettingsRow(sub: "Generated at 06:30 from your ★ 4+ items"))
                        Toggle("Notify when ready", isOn: $briefingNotify)
                            .modifier(SettingsRow(sub: "One push at 06:30, never more"))
                        Toggle("Skip already-rated", isOn: $skipAlreadyRated)
                            .modifier(SettingsRow(sub: "Don't reuse items you've rated 4+"))
                    }

                    Section(title: "rating") {
                        Toggle("Prompt to rate on read", isOn: $promptToRate)
                            .modifier(SettingsRow(sub: "Star bar inline after marking read"))
                        Toggle("Use ratings to re-rank", isOn: $useRatingsRerank)
                            .modifier(SettingsRow(sub: "Tomorrow's deck favors sources you rate 4+"))
                    }

                    Section(title: "account") {
                        Button {
                            showSignOutConfirm = true
                        } label: {
                            HStack {
                                Text("Sign out")
                                    .font(Theme.Typography.body(14, weight: .medium))
                                    .foregroundStyle(.red)
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(.red.opacity(0.6))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("DONE") { dismiss() }
                    .font(Theme.Typography.meta(11, weight: .bold))
                    .foregroundStyle(Theme.Color.accent)
            }
        }
        .confirmationDialog("Sign out?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) {
                Task { await auth.signOut() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

private struct Section<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title.uppercased())
                    .font(Theme.Typography.meta(10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Theme.Color.ink)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 8)
            .background(Theme.Color.stone100)
            .overlay(alignment: .top) { Theme.Color.stone200.frame(height: 1) }
            .overlay(alignment: .bottom) { Theme.Color.stone200.frame(height: 1) }

            content
        }
    }
}

private struct SettingsRow: ViewModifier {
    let sub: String?

    init(sub: String? = nil) { self.sub = sub }

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .toggleStyle(SettingsToggleStyle())
                .font(Theme.Typography.body(14, weight: .medium))
                .foregroundStyle(Theme.Color.ink)
            if let sub {
                Text(sub)
                    .font(Theme.Typography.meta(10))
                    .tracking(0.3)
                    .foregroundStyle(Theme.Color.stone300)
                    .padding(.trailing, 60)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Theme.Color.stone100.frame(height: 1)
        }
    }
}

/// Cobalt toggle that uses the same glow recipe as the progress bar when on.
private struct SettingsToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? Theme.Color.accent : Theme.Color.stone200)
                    .frame(width: 44, height: 26)
                    .shadow(color: configuration.isOn ? Theme.Color.accent.opacity(0.7) : .clear, radius: configuration.isOn ? 5 : 0)
                Circle()
                    .fill(.white)
                    .frame(width: 22, height: 22)
                    .padding(2)
                    .shadow(color: .black.opacity(0.20), radius: 1, y: 1)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.12)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}
