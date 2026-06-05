import SwiftUI

/// Today's deck — the daily ritual. DECK and LIST are two views of the same
/// deck (PRODUCT_SPEC §1). Toggle in the header.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AuthService.self) private var auth

    @State private var mode: HomeMode = TodayView.initialMode()
    @State private var articles: [Article] = []
    @State private var clearedIds: Set<Int64> = []
    @State private var divedIds: Set<Int64> = []
    @State private var ratingArticle: Article? = nil
    @State private var loadError: String?
    @State private var isLoading = false
    @State private var path: [Article] = []

    /// How many unseen articles to pull. No deck cap anymore — we show the
    /// whole day's queue and the real count (the user wants to see what's
    /// left to get through). This is a generous ceiling, not a UX cap.
    private let fetchLimit = 250

    /// Real total — every unseen card, not a bounded slice.
    private var total: Int { articles.count }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                PageBackground(atmosphere: .calm)
                VStack(spacing: 0) {
                    TickerBar(items: tickerItems)
                    StreakRibbon(streak: streakEstimate, cleared: clearedIds.count, total: total)
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
                        divedIds: divedIds,
                        total: total,
                        onPass: { article in Task { await pass(article, liked: false) } },
                        onLike: { article in Task { await pass(article, liked: true) } },
                        onDive: { article in Task { await dive(article) } },
                        onRate: { article in ratingArticle = article },
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

    private var deckArticles: [Article] { articles }

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
        if divedIds.contains(article.id) { return .sparked }
        if clearedIds.contains(article.id) { return .read }
        return .unread
    }

    // MARK: - Data

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let raw = try await env.articles.listFeed(beforeFetchedAt: nil, limit: fetchLimit)
            articles = Self.interleaveBySource(raw)
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
    // Swipe economy (PRODUCT_SPEC §2/§3):
    //   ← pass  → passed_at + meta rating "down"  → guilt-free clear
    //   → like  → passed_at + meta rating "up"    → logged taste, still clears
    //   ↑ dive  → starred_at                      → the scarce shortlist
    //   hold    → rating sheet (sparks + note → meta; ≥4 also dives)
    //
    // Any interaction removes the card from `feed_articles`, so a swipe always
    // clears. "Save for later" stays a deliberate button in the detail view,
    // not a swipe — that's what kept the old deck producing a giant pile.

    private func pass(_ article: Article, liked: Bool) async {
        markCleared(article.id)
        let meta = ["rating": liked ? "up" : "down"]
        do { try await env.interactions.setAction(.pass, articleId: article.id, meta: meta) }
        catch { loadError = error.localizedDescription }
    }

    private func dive(_ article: Article) async {
        markCleared(article.id)
        divedIds.insert(article.id)
        do { try await env.interactions.setAction(.star, articleId: article.id) }
        catch { loadError = error.localizedDescription }
    }

    private func applyRating(article: Article, sparks: Int, note: String?) async {
        guard sparks > 0 else { return }
        markCleared(article.id)
        var meta: [String: String] = ["sparks": String(sparks)]
        if let note, !note.isEmpty { meta["note"] = note }
        do {
            // A strong rating (≥4) promotes to the dive list; otherwise the
            // rating is pure feed-tuning signal and the card just clears.
            if sparks >= 4 {
                try await env.interactions.setAction(.star, articleId: article.id, meta: meta)
                divedIds.insert(article.id)
            } else {
                try await env.interactions.setAction(.pass, articleId: article.id, meta: meta)
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
