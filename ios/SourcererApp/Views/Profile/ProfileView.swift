import SwiftUI

/// Me — the simple record of what you kept. Everything you've swiped right
/// (saved) lands here, newest first. Settings live behind the gear.
///
/// The old activity grid + milestone bars were stripped in the refocus: they
/// ran on faked/proxy data (saves-as-cleared, hardcoded "member since"), which
/// set dishonest expectations. They can return once `daily_session` aggregates
/// actually exist.
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var env

    @State private var savedRows: [(Article, Date)] = []
    @State private var loadError: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                PageBackground(atmosphere: .calm)
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 22)
                        .padding(.top, 14)
                        .padding(.bottom, 8)
                    Divider().overlay(Theme.Color.stone200)
                    content
                }

                if isLoading && savedRows.isEmpty {
                    ProgressView().tint(Theme.Color.accent)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.Color.ink)
                    }
                }
            }
            .task { if savedRows.isEmpty { await load() } }
            .refreshable { await load() }
        }
    }

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            PageMasthead(title: "saved")
            Spacer()
        }
    }

    @ViewBuilder
    private var content: some View {
        if savedRows.isEmpty && !isLoading {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(savedRows.enumerated()), id: \.element.0.id) { i, row in
                        NavigationLink(value: row.0) {
                            ListRowCard(article: row.0, index: i + 1, status: .saved)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("nothing saved yet")
                .font(Theme.Typography.display(22))
                .kerning(-0.4)
                .foregroundStyle(Theme.Color.ink)
            Text("Swipe a card right in today's deck to keep it. Saved pieces collect here.")
                .font(Theme.Typography.serif(14).italic())
                .foregroundStyle(Theme.Color.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            savedRows = try await env.articles.listSaved(limit: 200)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}
