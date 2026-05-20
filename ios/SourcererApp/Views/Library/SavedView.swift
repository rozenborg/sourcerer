import SwiftUI

struct SavedView: View {
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
                        "Nothing saved yet",
                        systemImage: "bookmark",
                        description: Text("Tap the bookmark to save articles for later.")
                    )
                }
            }
            .navigationTitle("Saved")
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
            rows = try await env.articles.listSaved(limit: 200)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}
