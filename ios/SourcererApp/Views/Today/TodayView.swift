import SwiftUI

/// Today's deck — the daily ritual. DECK and LIST are two views of the same
/// deck. Toggle in the header.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AuthService.self) private var auth

    @State private var mode: HomeMode = TodayView.initialMode()
    @State private var articles: [Article] = []
    @State private var clearedIds: Set<Int64> = []
    @State private var loadError: String?
    @State private var isLoading = false
    @State private var path: [Article] = []

    /// Generous ceiling on the query, not a UX cap. The real bound on the
    /// deck's size is the time window below — the deck is the day's fresh
    /// batch, so it has a natural, completable end.
    private let fetchLimit = 250

    /// The deck shows recently-fetched content rather than an unbounded
    /// backlog. Tune this if days feel too sparse or too heavy.
    private let deckWindow: TimeInterval = 48 * 3600

    /// How many cards ahead a postponed card reinserts — far enough that it
    /// isn't the very next thing you see, close enough to resurface this
    /// session. Session-scoped: postpone never persists.
    private let postponeDepth = 10

    /// Real total — every card still in today's deck.
    private var total: Int { articles.count }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                PageBackground(atmosphere: .calm)
                VStack(spacing: 0) {
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
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            PageMasthead(title: "today's deck", dayOfWeek: nil, inboundCount: total)
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
                        total: total,
                        onSkip: { article in Task { await skip(article) } },
                        onSave: { article in Task { await save(article) } },
                        onPostpone: { article in postpone(article) },
                        onOpen: { article in path.append(article) }
                    )
        case .list:  TodayListMode(
                        articles: visibleDeckArticles,
                        statusFor: status(for:),
                        onTap: { article in path.append(article) }
                    )
        }
    }

    private var visibleDeckArticles: [Article] {
        // Filter out cleared (skipped/saved), keep order stable.
        articles.filter { !clearedIds.contains($0.id) }
    }

    private func status(for article: Article) -> RowStatus {
        if clearedIds.contains(article.id) { return .read }
        return .unread
    }

    // MARK: - Data

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let since = Date().addingTimeInterval(-deckWindow)
            let raw = try await env.articles.listFeed(beforeFetchedAt: nil, since: since, limit: fetchLimit)
            articles = Self.interleaveBySource(raw)
            clearedIds.removeAll()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    /// Round-robin the feed across sources so no single source (e.g. the
    /// scholarly fetchers, which ingest last and so sort to the top by
    /// fetched_at) ever clusters at the front of the deck. Source order is
    /// shuffled each refresh so the deck feels fresh; within a source the
    /// newest-first order is preserved.
    static func interleaveBySource(_ articles: [Article]) -> [Article] {
        var buckets: [String: [Article]] = [:]
        var order: [String] = []
        for a in articles {
            if buckets[a.sourceId] == nil {
                buckets[a.sourceId] = []
                order.append(a.sourceId)
            }
            buckets[a.sourceId]?.append(a)
        }
        order.shuffle()

        var result: [Article] = []
        var round = 0
        var pulled = true
        while pulled {
            pulled = false
            for key in order {
                if let bucket = buckets[key], round < bucket.count {
                    result.append(bucket[round])
                    pulled = true
                }
            }
            round += 1
        }
        return result
    }

    // MARK: - Actions
    //
    // The triage economy — the deck is a fast triage surface, nothing heavier:
    //   ← skip      → passed_at        → not for me, gone from the deck
    //   → save      → saved_at         → keep it; shows up in the Me tab
    //   ↑ postpone  → (no persistence) → reshuffle ~10 deeper; "ask me later"
    //   tap         → open detail (the longer summary)
    //
    // Rating (stars + note) is deliberately NOT a deck gesture — it's a
    // considered act that lives in the detail view, after you've actually
    // engaged with the piece.

    private func skip(_ article: Article) async {
        markCleared(article.id)
        do { try await env.interactions.setAction(.pass, articleId: article.id) }
        catch { loadError = error.localizedDescription }
    }

    private func save(_ article: Article) async {
        markCleared(article.id)
        do { try await env.interactions.setAction(.save, articleId: article.id) }
        catch { loadError = error.localizedDescription }
    }

    /// Move the card ~`postponeDepth` *visible* cards deeper in the deck.
    /// Session-scoped only — nothing is written. If the deck ages out before
    /// you return to it, it ages out like everything else (no backlog).
    private func postpone(_ article: Article) {
        guard let from = articles.firstIndex(where: { $0.id == article.id }) else { return }
        articles.remove(at: from)

        var seen = 0
        var insertAt = articles.count
        var i = from
        while i < articles.count {
            if !clearedIds.contains(articles[i].id) { seen += 1 }
            if seen >= postponeDepth { insertAt = i + 1; break }
            i += 1
        }
        articles.insert(article, at: min(insertAt, articles.count))
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
