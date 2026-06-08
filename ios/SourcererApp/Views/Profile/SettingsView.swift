import SwiftUI

/// Settings — pared down to what's actually wired. The old deck / briefing /
/// rating toggle banks were stripped in the refocus: they persisted to
/// @AppStorage but were never read, and most pointed at features that no
/// longer exist (ticker, audio briefing, re-rank). Toggles return as the
/// behaviors behind them ship.
struct SettingsView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var showSignOutConfirm = false

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                VStack(spacing: 0) {
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
