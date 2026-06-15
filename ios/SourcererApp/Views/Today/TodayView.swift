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
    @State private var feedbackArticle: Article? = nil
    /// Verdicts for cards in this session — the single source of truth for the
    /// card footer highlight. Seeded from the DB on load, updated on every
    /// thumb tap and sheet save so the card never diverges from what's stored.
    @State private var sessionVerdicts: [Int64: Verdict] = [:]

    /// Safety ceiling on the query, not a UX cap — at ~20 ingested/day it's
    /// effectively never hit. The deck is naturally bounded by ingest volume
    /// and by `feed_articles` hiding anything you've already triaged, so it
    /// lands around a day's batch on its own without a hard time filter.
    private let fetchLimit = 250

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
                // Fill the height and pin to the top so the masthead sits at
                // the same height in DECK and LIST mode. Without this the ZStack
                // centers the (shorter) deck column and the header drifts down.
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
            .sheet(item: $feedbackArticle) { article in
                FeedbackSheet(article: article, initialVerdict: sessionVerdicts[article.id]) { verdict, comment in
                    Task { await saveFeedback(article, verdict, comment) }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .overlay(alignment: .bottom) {
                if let loadError {
                    Text(loadError)
                        .font(Theme.Typography.meta(11))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.red.opacity(0.9), in: Capsule())
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
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
                        total: total,
                        onSkip: { article in Task { await skip(article) } },
                        onSave: { article in Task { await save(article) } },
                        onPostpone: { article in postpone(article) },
                        onOpen: { article in path.append(article) },
                        onVerdict: { article, verdict in handleVerdict(article, verdict) },
                        verdictFor: { article in sessionVerdicts[article.id] }
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

    /// Load any verdicts the user already gave these articles (prior session,
    /// or via the detail view), so the card footer thumbs reflect them.
    private func seedVerdicts() async {
        do {
            let raw = try await env.ratings.verdicts(forArticleIds: articles.map(\.id))
            sessionVerdicts = raw.reduce(into: [:]) { acc, pair in
                if let v = Verdict(rawValue: pair.value) { acc[pair.key] = v }
            }
        } catch {
            // Non-fatal: the deck just won't show pre-existing verdicts.
        }
    }

    // MARK: - Data

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // No hard time filter — pass nil. The `since:` plumbing stays for
            // a future "since I last cleared" bound, which needs persisted
            // session state we don't have yet.
            let raw = try await env.articles.listFeed(beforeFetchedAt: nil, since: nil, limit: fetchLimit)
            articles = Self.interleaveBySource(raw)
            clearedIds.removeAll()
            loadError = nil
            await seedVerdicts()
        } catch {
            surface(error)
        }
    }

    /// Show an error to the user — but ignore task cancellations, which are
    /// expected when a request is superseded by navigation or a re-render
    /// (they aren't real failures). Auto-dismiss so a transient error can't
    /// linger on screen.
    private func surface(_ error: Error) {
        if error is CancellationError { return }
        if let urlError = error as? URLError, urlError.code == .cancelled { return }
        let message = error.localizedDescription
        withAnimation { loadError = message }
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if loadError == message { withAnimation { loadError = nil } }
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
        catch { surface(error) }
    }

    private func save(_ article: Article) async {
        markCleared(article.id)
        do { try await env.interactions.setAction(.save, articleId: article.id) }
        catch { surface(error) }
    }

    /// A thumb tap on the card: reflect it on the card immediately, persist the
    /// verdict (the thumb IS the rating), then open the feedback sheet to
    /// optionally attach a comment. Rating is pure tuning signal — it does NOT
    /// clear the card from the deck.
    private func handleVerdict(_ article: Article, _ verdict: Verdict) {
        sessionVerdicts[article.id] = verdict
        feedbackArticle = article
        Task {
            do { try await env.ratings.setVerdict(articleId: article.id, verdict: verdict.rawValue) }
            catch { surface(error) }
        }
    }

    /// Sheet save: write verdict + comment (the comment can be cleared here),
    /// and keep the card highlight in sync with the (possibly changed) verdict.
    private func saveFeedback(_ article: Article, _ verdict: Verdict, _ comment: String?) async {
        sessionVerdicts[article.id] = verdict
        do { try await env.ratings.setFeedback(articleId: article.id, verdict: verdict.rawValue, comment: comment) }
        catch { surface(error) }
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
