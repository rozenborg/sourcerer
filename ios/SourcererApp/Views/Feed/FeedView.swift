import SwiftUI
import Inject

struct FeedView: View {
    @ObserveInjection var inject
    @Environment(AppEnvironment.self) private var env
    @Environment(AuthService.self) private var auth

    @State private var articles: [Article] = []
    @State private var isLoading = false
    @State private var loadError: String?
    @State private var endReached = false
    @State private var showSignOutConfirm = false

    private let pageSize = 30

    var body: some View {
        NavigationStack {
            List {
                ForEach(articles) { article in
                    NavigationLink(value: article) {
                        ArticleCard(article: article)
                    }
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .onAppear {
                        if article.id == articles.last?.id { Task { await loadMore() } }
                    }
                }

                if isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .listRowSeparator(.hidden)
                }

                if let loadError {
                    Text(loadError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSignOutConfirm = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    .accessibilityLabel("Account")
                }
            }
            .confirmationDialog(
                "Sign out?",
                isPresented: $showSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Sign out", role: .destructive) {
                    Task { await auth.signOut() }
                }
                Button("Cancel", role: .cancel) {}
            }
            .refreshable { await refresh() }
            .task {
                if articles.isEmpty { await refresh() }
            }
        }
        .enableInjection()
    }

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            articles = try await env.articles.listFeed(beforeFetchedAt: nil, limit: pageSize)
            endReached = articles.count < pageSize
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func loadMore() async {
        guard !isLoading, !endReached, let cursor = articles.last?.fetchedAt else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let next = try await env.articles.listFeed(beforeFetchedAt: cursor, limit: pageSize)
            if next.isEmpty { endReached = true }
            articles.append(contentsOf: next)
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    let env = AppEnvironment.preview()
    return FeedView()
        .environment(env)
        .environment(env.auth)
}
