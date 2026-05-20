import SwiftUI

struct StarredView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var rows: [(Article, Date)] = []
    @State private var loadError: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(rows, id: \.0.id) { (article, _) in
                    NavigationLink(value: article) {
                        ArticleCard(article: article)
                    }
                }
                if let loadError {
                    Text(loadError).font(.footnote).foregroundStyle(.red)
                }
            }
            .listStyle(.plain)
            .overlay {
                if rows.isEmpty && !isLoading {
                    ContentUnavailableView(
                        "Nothing starred yet",
                        systemImage: "star",
                        description: Text("Tap the star on an article to flag it for later.")
                    )
                }
            }
            .navigationTitle("Starred")
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            rows = try await env.articles.listStarred(limit: 200)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}
