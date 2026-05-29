import SwiftUI

/// Today's deck — the daily ritual. DECK and LIST are two views of the same
/// bounded deck (PRODUCT_SPEC §1). Toggle in the header.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AuthService.self) private var auth

    @State private var mode: HomeMode = TodayView.initialMode()
    @State private var articles: [Article] = []
    @State private var clearedIds: Set<Int64> = []
    @State private var sparkedIds: Set<Int64> = []
    @State private var savedIds: Set<Int64> = []
    @State private var ratingArticle: Article? = nil
    @State private var loadError: String?
    @State private var isLoading = false
    @State private var path: [Article] = []

    /// Bounded deck size — design says ~18 (PRODUCT_SPEC §1).
    private let deckCap = 18

    private var deckCount: Int { min(articles.count, deckCap) }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                PageBackground(atmosphere: .calm)
                VStack(spacing: 0) {
                    TickerBar(items: tickerItems)
                    StreakRibbon(streak: streakEstimate, cleared: clearedIds.count, total: deckCount)
                    header
                        .padding(.horizontal, 22)
                        .padding(.top, 14)
                        .padding(.bottom, 8)

                    content
                }

                if isLoading && articles.isEmpty {
                    ProgressView().tint(Theme.Color.accent)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .task { if articles.isEmpty { await refresh() } }
            .refreshable { await refresh() }
            .sheet(item: $ratingArticle) { article in
                RatingSheet(article: article) { sparks, note in
                    Task { await applyRating(article: article, sparks: sparks, note: note) }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            PageMasthead(title: "today's deck", dayOfWeek: nil, inboundCount: articles.count)
            Spacer()
            ModeToggle(mode: $mode)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .deck:  DeckPileView(
                        articles: visibleDeckArticles,
                        sparkedIds: sparkedIds,
                        savedIds: savedIds,
                        total: deckCount,
                        onPass: { article in Task { await pass(article) } },
                        onSpark: { article in
                            ratingArticle = article
                        },
                        onSave: { article in Task { await save(article) } },
                        onOpen: { article in path.append(article) }
                    )
        case .list:  TodayListMode(
                        articles: deckArticles,
                        statusFor: status(for:),
                        onTap: { article in path.append(article) }
                    )
        }
    }

    private var visibleDeckArticles: [Article] {
        // Filter out cleared, but keep order stable.
        deckArticles.filter { !clearedIds.contains($0.id) }
    }

    private var deckArticles: [Article] {
        Array(articles.prefix(deckCap))
    }

    private var tickerItems: [(Topic, String)] {
        let pool = deckArticles.prefix(6)
        return pool.compactMap { a in
            guard let t = a.title, !t.isEmpty else { return nil }
            return (a.topic, t)
        }
    }

    // Stub streak — PRODUCT_SPEC §7 makes this real once daily_session ships.
    private var streakEstimate: Int { max(1, clearedIds.count) }

    private func status(for article: Article) -> RowStatus {
        if savedIds.contains(article.id) { return .saved }
        if sparkedIds.contains(article.id) { return .sparked }
        if clearedIds.contains(article.id) { return .read }
        return .unread
    }

    // MARK: - Data

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            articles = try await env.articles.listFeed(beforeFetchedAt: nil, limit: deckCap)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    // MARK: - Actions
    //
    // Mapping until the rating schema ships (PRODUCT_SPEC §3):
    //   pass  → passed_at  → card leaves the deck
    //   spark → starred_at → card stays as "sparked"
    //   save  → saved_at   (+ starred if ≥4 sparks)
    //
    // All three count as "cleared" toward the bounded-session arc (§2).

    private func pass(_ article: Article) async {
        markCleared(article.id)
        do { try await env.interactions.setAction(.pass, articleId: article.id) }
        catch { loadError = error.localizedDescription }
    }

    private func save(_ article: Article) async {
        markCleared(article.id)
        savedIds.insert(article.id)
        do { try await env.interactions.setAction(.save, articleId: article.id) }
        catch { loadError = error.localizedDescription }
    }

    private func applyRating(article: Article, sparks: Int, note: String?) async {
        guard sparks > 0 else { return }
        markCleared(article.id)
        do {
            if sparks <= 2 {
                try await env.interactions.setAction(.pass, articleId: article.id)
            } else {
                try await env.interactions.setAction(.star, articleId: article.id)
                sparkedIds.insert(article.id)
                if sparks >= 4 {
                    try await env.interactions.setAction(.save, articleId: article.id)
                    savedIds.insert(article.id)
                }
            }
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func markCleared(_ id: Int64) {
        clearedIds.insert(id)
    }

    private static func initialMode() -> HomeMode {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--list-mode") { return .list }
#endif
        return .deck
    }
}
